# managed-by=mohavise-mikrotik-iran-ip
# project=get-ip-iran-evo
# do-not-edit-manually

:do {
    :local scriptName "update-iran-ipv6-small-router"
    :local scriptSource ":local fileName \"iran-ipv6.rsc\"
:local url \"https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/list-ipv6.rsc\"
:local listName \"IRv6\"
:local backupList \"IRv6-backup-before-update\"
:local minEntries 100

:if ([:len [/file find name=\$fileName]] > 0) do={ /file remove \$fileName }

:do {
    /tool fetch url=\$url dst-path=\$fileName mode=https
    /import file-name=\$fileName dry-run
} on-error={
    :log warning \"Iran IPv6 update: download or validation failed; old list kept\"
    :if ([:len [/file find name=\$fileName]] > 0) do={ /file remove \$fileName }
    :return
}

/ipv6 firewall address-list remove [find list=\$backupList]
:foreach item in=[/ipv6 firewall address-list find list=\$listName] do={
    /ipv6 firewall address-list add list=\$backupList address=[/ipv6 firewall address-list get \$item address]
}

:local updateOK true
:do { /import file-name=\$fileName } on-error={ :set updateOK false }
:if ([:len [/ipv6 firewall address-list find list=\$listName]] < \$minEntries) do={ :set updateOK false }

:if (\$updateOK = false) do={
    /ipv6 firewall address-list remove [find list=\$listName]
    :foreach item in=[/ipv6 firewall address-list find list=\$backupList] do={
        /ipv6 firewall address-list add list=\$listName address=[/ipv6 firewall address-list get \$item address]
    }
    :log warning \"Iran IPv6 update: minimum check failed; old list restored\"
} else={
    :log info \"Iran IPv6 update: IRv6 updated successfully\"
}

/ipv6 firewall address-list remove [find list=\$backupList]
/file remove \$fileName"

    :if ([:len [/system script find name=$scriptName]] = 0) do={
        /system script add name=$scriptName dont-require-permissions=no policy=read,write,policy,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    } else={
        /system script set [/system script find name=$scriptName] dont-require-permissions=no policy=read,write,policy,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    }
}