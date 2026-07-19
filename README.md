# Get IP Iran Evo for MikroTik

Generate and safely update Iran IPv4 and IPv6 address lists for MikroTik RouterOS.

## Data Source

The lists are generated from RIPEstat:

```text
https://stat.ripe.net/data/country-resource-list/data.json?resource=IR&v4_format=prefix
```

```text
RIPEstat
→ scripts/get.sh
→ repository validation
→ list-ipv4.rsc / list-ipv6.rsc
→ SHA-256 checksum files
→ MikroTik updater
```

## Published Files

| File | Purpose |
| --- | --- |
| `list-ipv4.rsc` | Iran IPv4 prefixes in `NoNAT` |
| `list-ipv6.rsc` | Iran IPv6 prefixes in `IRv6` |
| `list-ipv4-checksum.sha256` | SHA-256 checksum for the IPv4 list |
| `list-ipv6-checksum.sha256` | SHA-256 checksum for the IPv6 list |

## Repository Validation

GitHub Actions validates generated data before publishing it:

- RIPEstat request and API status
- minimum source-prefix counts
- valid IPv4 and IPv6 CIDR networks
- correct IP family
- duplicate detection
- correct RouterOS address-list names
- protection against a sudden count reduction greater than 20%
- SHA-256 checksum generation and verification

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

The router does not repeat CIDR, duplicate, IP-family, file-size, or SHA-256 validation.

## Choose an Updater

### Small routers

Small-router scripts keep the backup in a temporary address list.

| Protocol | Updater | Backup list |
| --- | --- | --- |
| IPv4 | `update-iran-ipv4-small-router.rsc` | `NoNAT-backup-before-update` |
| IPv6 | `update-iran-ipv6-small-router.rsc` | `IRv6-backup-before-update` |

### Medium and large routers

Medium/large-router scripts use a temporary export file.

| Protocol | Updater | Backup file |
| --- | --- | --- |
| IPv4 | `update-iran-ipv4-medium-large-router.rsc` | `nonat-ipv4-backup-before-update.rsc` |
| IPv6 | `update-iran-ipv6-medium-large-router.rsc` | `irv6-backup-before-update.rsc` |

## Recommended Safe Install

Use only the installer matching your router and protocol.

### IPv4 — small router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv4-small-router.rsc" dst-path=safe-install-iran-ipv4-small-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv4-small-router.rsc verbose=yes dry-run
/import file-name=safe-install-iran-ipv4-small-router.rsc
/file remove [find name=safe-install-iran-ipv4-small-router.rsc]
```

### IPv4 — medium/large router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv4-medium-large-router.rsc" dst-path=safe-install-iran-ipv4-medium-large-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv4-medium-large-router.rsc verbose=yes dry-run
/import file-name=safe-install-iran-ipv4-medium-large-router.rsc
/file remove [find name=safe-install-iran-ipv4-medium-large-router.rsc]
```

### IPv6 — small router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv6-small-router.rsc" dst-path=safe-install-iran-ipv6-small-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv6-small-router.rsc verbose=yes dry-run
/import file-name=safe-install-iran-ipv6-small-router.rsc
/file remove [find name=safe-install-iran-ipv6-small-router.rsc]
```

### IPv6 — medium/large router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv6-medium-large-router.rsc" dst-path=safe-install-iran-ipv6-medium-large-router.rsc check-certificate=yes-without-crl
/import file-name=safe-install-iran-ipv6-medium-large-router.rsc verbose=yes dry-run
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
