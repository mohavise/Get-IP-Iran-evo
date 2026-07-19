# managed-by=mohavise-mikrotik-iran-ip
# project=get-ip-iran-evo
# do-not-edit-manually

:do {
    :local scriptName "update-iran-ipv4-small-router"
    :local scriptSource ":local fileName \"iran-ipv4.rsc\"
:local url \"https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/list-ipv4.rsc\"
:local listName \"NoNAT\"
:local backupList \"NoNAT-backup-before-update\"
:local minFileSize 1000
:local minEntries 1000

:if ([:len [/file find name=\$fileName]] > 0) do={ /file remove \$fileName }

:do {
    /tool fetch url=\$url dst-path=\$fileName mode=https
} on-error={
    :log warning \"Iran IPv4 update: download failed; old list kept\"
    :return
}

:if (([:len [/file find name=\$fileName]] = 0) or ([/file get \$fileName size] < \$minFileSize)) do={
    :log warning \"Iran IPv4 update: downloaded file is missing or too small\"
    :if ([:len [/file find name=\$fileName]] > 0) do={ /file remove \$fileName }
    :return
}

:do {
    /import file-name=\$fileName dry-run
} on-error={
    :log warning \"Iran IPv4 update: validation failed; old list kept\"
    /file remove \$fileName
    :return
}

/ip firewall address-list remove [find list=\$backupList]
:foreach item in=[/ip firewall address-list find list=\$listName] do={
    /ip firewall address-list add list=\$backupList address=[/ip firewall address-list get \$item address]
}

:local updateOK true
:do { /import file-name=\$fileName } on-error={ :set updateOK false }

:if ([:len [/ip firewall address-list find list=\$listName]] < \$minEntries) do={
    :set updateOK false
}

:if (\$updateOK = false) do={
    /ip firewall address-list remove [find list=\$listName]
    :foreach item in=[/ip firewall address-list find list=\$backupList] do={
        /ip firewall address-list add list=\$listName address=[/ip firewall address-list get \$item address]
    }
    :log warning \"Iran IPv4 update: import failed validation; old list restored\"
} else={
    :log info \"Iran IPv4 update: NoNAT updated successfully\"
}

/ip firewall address-list remove [find list=\$backupList]
/file remove \$fileName"

    :if ([:len [/system script find name=$scriptName]] = 0) do={
        /system script add name=$scriptName dont-require-permissions=no policy=read,write,policy,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    } else={
        /system script set [/system script find name=$scriptName] dont-require-permissions=no policy=read,write,policy,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    }
}