#!/bin/sh

set -eu

last=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
url="https://stat.ripe.net/data/country-resource-list/data.json?resource=IR&v4_format=prefix"
filterv4='.data.resources.ipv4[]'
filterv6='.data.resources.ipv6[]'
min_ipv4_prefixes="${MIN_IPV4_PREFIXES:-1000}"
min_ipv6_prefixes="${MIN_IPV6_PREFIXES:-100}"

tmp_json=$(mktemp)
tmp_v4=$(mktemp)
tmp_v6=$(mktemp)
trap 'rm -f "$tmp_json" "$tmp_v4" "$tmp_v6"' EXIT HUP INT TERM

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --retry-all-errors \
    --connect-timeout 20 \
    --max-time 120 \
    "$url" > "$tmp_json"

if ! jq -e '
    .status == "ok" and
    (.data.resources.ipv4 | type == "array") and
    (.data.resources.ipv6 | type == "array")
' "$tmp_json" >/dev/null; then
    echo "ERROR: RIPEstat returned an invalid or unsuccessful response" >&2
    exit 1
fi

ipv4_source_count=$(jq '.data.resources.ipv4 | length' "$tmp_json")
ipv6_source_count=$(jq '.data.resources.ipv6 | length' "$tmp_json")

if [ "$ipv4_source_count" -lt "$min_ipv4_prefixes" ]; then
    echo "ERROR: RIPEstat returned only $ipv4_source_count IPv4 prefixes; minimum is $min_ipv4_prefixes" >&2
    exit 1
fi

if [ "$ipv6_source_count" -lt "$min_ipv6_prefixes" ]; then
    echo "ERROR: RIPEstat returned only $ipv6_source_count IPv6 prefixes; minimum is $min_ipv6_prefixes" >&2
    exit 1
fi

rsc_fwv4()
{
    echo "#Last update: $last"
    echo "/ip firewall address-list remove [/ip firewall address-list find list=NoNAT]"
    echo "/ip firewall address-list"
}

rsc_fwv6()
{
    echo "#Last update: $last"
    echo "/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=IRv6]"
    echo "/ipv6 firewall address-list"
}

rsc_respinav4()
{
    echo ":do { add address=5.160.0.0/16 list=NoNAT} on-error={}"
    echo ":do { add address=46.209.0.0/16 list=NoNAT} on-error={}"
    echo ":do { add address=77.104.64.0/18 list=NoNAT} on-error={}"
}

rsc_intranetv4()
{
    echo ":do { add address=10.0.0.0/8 list=NoNAT} on-error={}"
}

rsc_address_add()
{
    list_name=$1
    jq_filter=$2

    jq -r "$jq_filter" "$tmp_json" | while IFS= read -r prefix
    do
        [ -n "$prefix" ] || continue
        echo ":do { add address=$prefix list=$list_name} on-error={}"
    done
}

rsc_v4()
{
    rsc_fwv4
    rsc_respinav4
    rsc_intranetv4
    rsc_address_add NoNAT "$filterv4"
}

rsc_v6()
{
    rsc_fwv6
    rsc_address_add IRv6 "$filterv6"
}

validate_generated_file()
{
    file=$1
    list_name=$2
    minimum=$3

    if [ ! -s "$file" ]; then
        echo "ERROR: generated file $file is empty" >&2
        return 1
    fi

    entry_count=$(grep -c "add address=.* list=$list_name" "$file" || true)
    if [ "$entry_count" -lt "$minimum" ]; then
        echo "ERROR: generated file $file has only $entry_count entries; minimum is $minimum" >&2
        return 1
    fi

    if grep -Eq '(^|[[:space:]])(null|false)([[:space:]]|$)' "$file"; then
        echo "ERROR: generated file $file contains invalid values" >&2
        return 1
    fi
}

case "${1:-}" in
    v4)
        rsc_v4
        ;;
    v6)
        rsc_v6
        ;;
    split)
        rsc_v4 > "$tmp_v4"
        rsc_v6 > "$tmp_v6"

        validate_generated_file "$tmp_v4" NoNAT "$min_ipv4_prefixes"
        validate_generated_file "$tmp_v6" IRv6 "$min_ipv6_prefixes"

        mv "$tmp_v4" list-ipv4.rsc
        mv "$tmp_v6" list-ipv6.rsc
        ;;
    *)
        rsc_v6
        rsc_v4
        ;;
esac
