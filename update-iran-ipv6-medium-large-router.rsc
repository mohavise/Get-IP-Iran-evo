# managed-by=mohavise-mikrotik-iran-ip
# project=get-ip-iran-evo
# do-not-edit-manually

:do {
    :local scriptName "update-iran-ipv6-medium-large-router"
    :local scriptSource ":local fileName \"iran-ipv6.rsc\"
:local backupFile \"irv6-backup-before-update.rsc\"
:local url \"https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/list-ipv6.rsc\"
:local listName \"IRv6\"
:local minFileSize 1000
:local minEntries 100

:foreach file in={\$fileName;\$backupFile} do={
    :if ([:len [/file find name=\$file]] > 0) do={ /file remove \$file }
}

:do {
    /tool fetch url=\$url dst-path=\$fileName mode=https
} on-error={
    :log warning \"Iran IPv6 update: download failed; old list kept\"
    :return
}

:if (([:len [/file find name=\$fileName]] = 0) or ([/file get \$fileName size] < \$minFileSize)) do={
    :log warning \"Iran IPv6 update: downloaded file is missing or too small\"
    :if ([:len [/file find name=\$fileName]] > 0) do={ /file remove \$fileName }
    :return
}

:do {
    /import file-name=\$fileName dry-run
} on-error={
    :log warning \"Iran IPv6 update: validation failed; old list kept\"
    /file remove \$fileName
    :return
}

:do {
    /ipv6 firewall address-list export file=\$backupFile where list=\$listName
} on-error={
    :log warning \"Iran IPv6 update: backup failed; old list kept\"
    /file remove \$fileName
    :return
}

:local updateOK true
:do { /import file-name=\$fileName } on-error={ :set updateOK false }

:if ([:len [/ipv6 firewall address-list find list=\$listName]] < \$minEntries) do={
    :set updateOK false
}

:if (\$updateOK = false) do={
    /ipv6 firewall address-list remove [find list=\$listName]
    /import file-name=\$backupFile
    :log warning \"Iran IPv6 update: import failed validation; old list restored\"
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