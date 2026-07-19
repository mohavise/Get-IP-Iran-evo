#!/bin/sh

set -eu

url="https://stat.ripe.net/data/country-resource-list/data.json?resource=IR&v4_format=prefix"
last=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
json=$(mktemp)
v4=$(mktemp)
v6=$(mktemp)
trap 'rm -f "$json" "$v4" "$v6"' EXIT

curl --fail --silent --show-error --location --retry 3 "$url" > "$json"

jq -e '
  .status == "ok" and
  (.data.resources.ipv4 | length >= 1000) and
  (.data.resources.ipv6 | length >= 100)
' "$json" >/dev/null || {
  echo "ERROR: RIPEstat data is invalid or incomplete" >&2
  exit 1
}

make_v4() {
  echo "#Last update: $last"
  echo "/ip firewall address-list remove [/ip firewall address-list find list=NoNAT]"
  echo "/ip firewall address-list"
  echo ":do { add address=5.160.0.0/16 list=NoNAT} on-error={}"
  echo ":do { add address=46.209.0.0/16 list=NoNAT} on-error={}"
  echo ":do { add address=77.104.64.0/18 list=NoNAT} on-error={}"
  echo ":do { add address=10.0.0.0/8 list=NoNAT} on-error={}"
  jq -r '.data.resources.ipv4[] | ":do { add address=\(.) list=NoNAT} on-error={}"' "$json"
}

make_v6() {
  echo "#Last update: $last"
  echo "/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=IRv6]"
  echo "/ipv6 firewall address-list"
  jq -r '.data.resources.ipv6[] | ":do { add address=\(.) list=IRv6} on-error={}"' "$json"
}

case "${1:-}" in
  v4)
    make_v4
    ;;
  v6)
    make_v6
    ;;
  split)
    make_v4 > "$v4"
    make_v6 > "$v6"
    test "$(grep -c 'list=NoNAT' "$v4")" -ge 1000
    test "$(grep -c 'list=IRv6' "$v6")" -ge 100
    mv "$v4" list-ipv4.rsc
    mv "$v6" list-ipv6.rsc
    ;;
  *)
    echo "Usage: $0 {v4|v6|split}" >&2
    exit 1
    ;;
esac
