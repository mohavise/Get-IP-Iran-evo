# managed-by=mohavise-mikrotik-iran-ip
# project=get-ip-iran-evo
# do-not-edit-manually

:do {
    :local scriptName "update-iran-ipv6-medium-large-router"
    :local scriptSource ":local fileName \"iran-ipv6.rsc\"
:local backupFile \"irv6-backup-before-update.rsc\"
:local url \"https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/list-ipv6.rsc\"
:local listName \"IRv6\"
:local minEntries 100

:foreach file in={\$fileName;\$backupFile} do={
    :if ([:len [/file find name=\$file]] > 0) do={ /file remove \$file }
}

:do {
    /tool fetch url=\$url dst-path=\$fileName mode=https
    /import file-name=\$fileName dry-run
    /ipv6 firewall address-list export file=\$backupFile where list=\$listName
} on-error={
    :log warning \"Iran IPv6 update: preparation failed; old list kept\"
    :foreach file in={\$fileName;\$backupFile} do={
        :if ([:len [/file find name=\$file]] > 0) do={ /file remove \$file }
    }
    :return
}

:local updateOK true
:do { /import file-name=\$fileName } on-error={ :set updateOK false }
:if ([:len [/ipv6 firewall address-list find list=\$listName]] < \$minEntries) do={ :set updateOK false }

:if (\$updateOK = false) do={
    /ipv6 firewall address-list remove [find list=\$listName]
    /import file-name=\$backupFile
    :log warning \"Iran IPv6 update: minimum check failed; old list restored\"
} else={
    :log info \"Iran IPv6 update: IRv6 updated successfully\"
}

/file remove \$fileName
/file remove \$backupFile"

    :if ([:len [/system script find name=$scriptName]] = 0) do={
        /system script add name=$scriptName dont-require-permissions=no policy=read,write,policy,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    } else={
        /system script set [/system script find name=$scriptName] dont-require-permissions=no policy=read,write,policy,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    }
}