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
    /tool fetch url=\$url dst-path=\$fileName check-certificate=yes-without-crl
} on-error={
    :log warning \"Iran IPv6 update: download failed; old list kept\"
    :return \"\"
}

:do {
    /import file-name=\$fileName verbose=yes dry-run
} on-error={
    :log warning \"Iran IPv6 update: validation failed; old list kept\"
    /file remove \$fileName
    :return \"\"
}

:if ([:len [/ipv6 firewall address-list find list=\$backupList]] > 0) do={
    :if ([:len [/ipv6 firewall address-list find list=\$listName]] = 0) do={
        /ipv6 firewall address-list set [find list=\$backupList] list=\$listName
    } else={
        /ipv6 firewall address-list remove [find list=\$backupList]
    }
}

/ipv6 firewall address-list set [find list=\$listName] list=\$backupList

:local updateOK true
:do { /import file-name=\$fileName } on-error={ :set updateOK false }

:if ([:len [/ipv6 firewall address-list find list=\$listName]] < \$minEntries) do={
    :set updateOK false
}

:if (\$updateOK = false) do={
    /ipv6 firewall address-list remove [find list=\$listName]
    /ipv6 firewall address-list set [find list=\$backupList] list=\$listName
    :log warning \"Iran IPv6 update: import failed validation; old list restored\"
} else={
    /ipv6 firewall address-list remove [find list=\$backupList]
    :log info \"Iran IPv6 update: IRv6 updated successfully\"
}

/file remove \$fileName"

    :if ([:len [/system script find name=$scriptName]] = 0) do={
        /system script add name=$scriptName dont-require-permissions=no policy=ftp,read,write,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    } else={
        /system script set [/system script find name=$scriptName] dont-require-permissions=no policy=ftp,read,write,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    }
}
