# Get IP Iran Evo for MikroTik

Generate and safely update Iran IPv4 and IPv6 address lists for MikroTik RouterOS.

## Data Source

The lists are generated from RIPEstat:

```text
https://stat.ripe.net/data/country-resource-list/data.json?resource=IR&v4_format=prefix
```

Update path:

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
| `list-ipv4.rsc` | Iran IPv4 prefixes in the `NoNAT` address list |
| `list-ipv6.rsc` | Iran IPv6 prefixes in the `IRv6` address list |
| `list-ipv4-checksum.sha256` | SHA-256 checksum for `list-ipv4.rsc` |
| `list-ipv6-checksum.sha256` | SHA-256 checksum for `list-ipv6.rsc` |

## Repository Validation

The GitHub workflow validates generated data before publishing it.

Checks include:

- RIPEstat request success and API status
- minimum source-prefix counts
- valid IPv4 and IPv6 CIDR networks
- correct IP family in each list
- duplicate-network detection
- correct RouterOS address-list names
- protection against a sudden entry-count reduction greater than 20%
- SHA-256 checksum generation and verification

If any check fails, the workflow stops and the current published files remain unchanged.

Current minimums:

| List | Minimum entries |
| --- | ---: |
| IPv4 `NoNAT` | 1,000 |
| IPv6 `IRv6` | 100 |

## MikroTik Safety Logic

Data-quality validation is performed in the repository. The MikroTik updater only performs operational safety checks.

```text
Download list
→ RouterOS dry-run import
→ Backup current address list
→ Import new list
→ Verify minimum entry count
→ Restore backup if import or minimum check fails
→ Remove temporary files
```

The router minimum checks are:

| Address list | Minimum entries |
| --- | ---: |
| `NoNAT` | 1,000 |
| `IRv6` | 100 |

The MikroTik updater does not perform file-size, CIDR, duplicate, IP-family, or SHA-256 validation. Those checks are handled before publication by GitHub Actions.

## Choose an Updater

### Small routers

Small-router scripts keep the backup in a temporary RouterOS address list.

| Protocol | Updater | Temporary backup list |
| --- | --- | --- |
| IPv4 | `update-iran-ipv4-small-router.rsc` | `NoNAT-backup-before-update` |
| IPv6 | `update-iran-ipv6-small-router.rsc` | `IRv6-backup-before-update` |

### Medium and large routers

Medium/large-router scripts use a temporary export file.

| Protocol | Updater | Temporary backup file |
| --- | --- | --- |
| IPv4 | `update-iran-ipv4-medium-large-router.rsc` | `nonat-ipv4-backup-before-update.rsc` |
| IPv6 | `update-iran-ipv6-medium-large-router.rsc` | `irv6-backup-before-update.rsc` |

## Recommended Safe Install

Use only the installer matching your router and protocol.

### IPv4 — small router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv4-small-router.rsc" dst-path=safe-install-iran-ipv4-small-router.rsc mode=https
/import file-name=safe-install-iran-ipv4-small-router.rsc
/file remove [find name=safe-install-iran-ipv4-small-router.rsc]
```

### IPv4 — medium/large router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv4-medium-large-router.rsc" dst-path=safe-install-iran-ipv4-medium-large-router.rsc mode=https
/import file-name=safe-install-iran-ipv4-medium-large-router.rsc
/file remove [find name=safe-install-iran-ipv4-medium-large-router.rsc]
```

### IPv6 — small router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv6-small-router.rsc" dst-path=safe-install-iran-ipv6-small-router.rsc mode=https
/import file-name=safe-install-iran-ipv6-small-router.rsc
/file remove [find name=safe-install-iran-ipv6-small-router.rsc]
```

### IPv6 — medium/large router

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/safe-install-iran-ipv6-medium-large-router.rsc" dst-path=safe-install-iran-ipv6-medium-large-router.rsc mode=https
/import file-name=safe-install-iran-ipv6-medium-large-router.rsc
/file remove [find name=safe-install-iran-ipv6-medium-large-router.rsc]
```

The safe installer installs the matching updater and scheduler, removes temporary installer files, and runs the updater once.

## Manual Updater Installation

Example for IPv4 medium/large routers:

```routeros
/tool fetch url="https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/update-iran-ipv4-medium-large-router.rsc" dst-path=update-iran-ipv4-medium-large-router.rsc mode=https
/import file-name=update-iran-ipv4-medium-large-router.rsc
/file remove [find name=update-iran-ipv4-medium-large-router.rsc]
/system script run update-iran-ipv4-medium-large-router
```

Replace the filename and script name with the matching IPv4/IPv6 and small/medium-large version when needed.

## Automatic Router Updates

Default scheduler times:

| Protocol | Daily time |
| --- | --- |
| IPv4 | `04:00:00` |
| IPv6 | `04:10:00` |

You can change the scheduler time in RouterOS.

## Automatic GitHub Updates

Workflow:

```text
.github/workflows/update-split-lists.yml
```

It runs daily and can also be started manually from the GitHub Actions tab.

On success it updates all four published files:

```text
list-ipv4.rsc
list-ipv6.rsc
list-ipv4-checksum.sha256
list-ipv6-checksum.sha256
```

## Manual List Generation

```bash
./scripts/get.sh v4
./scripts/get.sh v6
./scripts/get.sh split
```

| Command | Result |
| --- | --- |
| `./scripts/get.sh v4` | Print the IPv4 RouterOS list |
| `./scripts/get.sh v6` | Print the IPv6 RouterOS list |
| `./scripts/get.sh split` | Write both `.rsc` list files |

## Notes

- IPv4 RouterOS list name: `NoNAT`
- IPv6 RouterOS list name: `IRv6`
- Failed download or dry-run import keeps the old list active.
- Failed import or minimum-entry check restores the previous list.
- Temporary downloaded and backup files are removed after the update.
- Updater scripts require RouterOS policy: `read,write,policy,test`.
