# Get IP Iran Evo for MikroTik

Generate and safely update Iran IPv4 and IPv6 address lists for MikroTik RouterOS.

## Data Sources

The primary lists are generated from RIPEstat:

```text
https://stat.ripe.net/data/country-resource-list/data.json?resource=IR&v4_format=prefix
```

Some active Iranian prefixes can be absent from that country-resource dataset because it is derived from RIR statistics rather than every later reassignment or routed sub-prefix. Confirmed omissions are maintained in:

```text
data/ipv4-supplements.txt
```

Every supplemental prefix must be supported by current registry and routing evidence. GitHub Actions validates the supplemental file and confirms every entry is included in the generated IPv4 output.

```text
RIPEstat + reviewed IPv4 supplements
→ scripts/get.sh
→ repository validation
→ list-ipv4.rsc / list-ipv6.rsc
→ MikroTik updater
```

## Published Files

| File | Purpose |
| --- | --- |
| `list-ipv4.rsc` | Iran IPv4 prefixes in `NoNAT` |
| `list-ipv6.rsc` | Iran IPv6 prefixes in `IRv6` |
| `data/ipv4-supplements.txt` | Reviewed Iranian IPv4 prefixes omitted by the primary source |

## Repository Validation

GitHub Actions validates generated data before publishing it:

- RIPEstat request and API status
- minimum source-prefix counts
- valid IPv4 and IPv6 CIDR networks
- correct IP family
- duplicate detection
- correct RouterOS address-list names
- valid and unique supplemental IPv4 CIDRs
- confirmation that every supplemental CIDR appears in `list-ipv4.rsc`
- protection against a sudden count reduction greater than 20%

If validation fails, the current published files remain unchanged.

| List | Minimum entries |
| --- | ---: |
| IPv4 `NoNAT` | 1,000 |
| IPv6 `IRv6` | 100 |

## MikroTik Safety Logic

Data-quality validation is handled by GitHub. RouterOS performs operational safety checks:

```text
Secure HTTPS download
→ verbose dry-run import
→ backup current list
→ import new list
→ minimum-entry check
→ restore backup on failure
→ remove temporary files
```

RouterOS fetch uses:

```routeros
check-certificate=yes-without-crl
```

RouterOS syntax validation uses:

```routeros
/import file-name=$fileName verbose=yes dry-run
```

The router does not repeat CIDR, duplicate, IP-family, or file-size validation.

## Choose an Updater

### Small routers

All updater variants keep the previous entries in a temporary address list. The active list is renamed before import, then restored if parsing or minimum-entry validation fails. This avoids duplicating thousands of entries and does not depend on filtered RouterOS exports.

| Protocol | Updaters | Temporary backup list |
| --- | --- | --- |
| IPv4 | small and medium/large | `NoNAT-backup-before-update` |
| IPv6 | small and medium/large | `IRv6-backup-before-update` |

## Recommended Safe Install

Use only the installer matching your router and protocol.

### IPv4 — small router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv4-small-router.rsc" dst-path=safe-install-iran-ipv4-small-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv4-small-router.rsc
/file remove [find name=safe-install-iran-ipv4-small-router.rsc]
```

### IPv4 — medium/large router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv4-medium-large-router.rsc" dst-path=safe-install-iran-ipv4-medium-large-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv4-medium-large-router.rsc
/file remove [find name=safe-install-iran-ipv4-medium-large-router.rsc]
```

### IPv6 — small router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv6-small-router.rsc" dst-path=safe-install-iran-ipv6-small-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv6-small-router.rsc
/file remove [find name=safe-install-iran-ipv6-small-router.rsc]
```

### IPv6 — medium/large router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv6-medium-large-router.rsc" dst-path=safe-install-iran-ipv6-medium-large-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv6-medium-large-router.rsc
/file remove [find name=safe-install-iran-ipv6-medium-large-router.rsc]
```

The safe installer validates and installs the matching updater and scheduler, removes temporary files, and runs the updater once.

## Automatic Router Updates

| Protocol | Daily time |
| --- | --- |
| IPv4 | `04:00:00` |
| IPv6 | `04:10:00` |

Updater scripts and schedulers use:

```routeros
policy=ftp,read,write,test
```

The `ftp` policy is required for fetch and file operations. The updater does not require the RouterOS `policy` permission.

## Automatic GitHub Updates

Workflow:

```text
.github/workflows/update-split-lists.yml
```

It runs daily and can also be started manually from GitHub Actions.

## Manual List Generation

```bash
./scripts/get.sh v4
./scripts/get.sh v6
./scripts/get.sh split
```

## Notes

- IPv4 address-list name: `NoNAT`
- IPv6 address-list name: `IRv6`
- Failed secure download or dry-run keeps the old list active.
- Failed import or minimum-entry check restores the previous list.
- Temporary downloaded and backup files are removed after the update.
