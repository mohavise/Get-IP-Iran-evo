# managed-by=mohavise-mikrotik-iran-ip
# project=get-ip-iran-evo
# do-not-edit-manually

:do {
    :local scriptName "update-iran-ipv4-small-router"
    :local scriptSource ":local fileName \"iran-ipv4.rsc\"
:local url \"https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/list-ipv4.rsc\"
:local listName \"NoNAT\"
:local backupList \"NoNAT-backup-before-update\"
:local minEntries 1000

:if ([:len [/file find name=\$fileName]] > 0) do={ /file remove \$fileName }

:do {
    /tool fetch url=\$url dst-path=\$fileName check-certificate=yes-without-crl
} on-error={
    :log warning \"Iran IPv4 update: download failed; old list kept\"
    :return \"\"
}

:do {
    /import file-name=\$fileName verbose=yes dry-run
} on-error={
    :log warning \"Iran IPv4 update: validation failed; old list kept\"
    /file remove \$fileName
    :return \"\"
}

:if ([:len [/ip firewall address-list find list=\$backupList]] > 0) do={
    :if ([:len [/ip firewall address-list find list=\$listName]] = 0) do={
        /ip firewall address-list set [find list=\$backupList] list=\$listName
    } else={
        /ip firewall address-list remove [find list=\$backupList]
    }
}

/ip firewall address-list set [find list=\$listName] list=\$backupList

:local updateOK true
:do { /import file-name=\$fileName } on-error={ :set updateOK false }

:if ([:len [/ip firewall address-list find list=\$listName]] < \$minEntries) do={
    :set updateOK false
}

:if (\$updateOK = false) do={
    /ip firewall address-list remove [find list=\$listName]
    /ip firewall address-list set [find list=\$backupList] list=\$listName
    :log warning \"Iran IPv4 update: import failed validation; old list restored\"
} else={
    /ip firewall address-list remove [find list=\$backupList]
    :log info \"Iran IPv4 update: NoNAT updated successfully\"
}

/file remove \$fileName"

    :if ([:len [/system script find name=$scriptName]] = 0) do={
        /system script add name=$scriptName dont-require-permissions=no policy=ftp,read,write,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    } else={
        /system script set [/system script find name=$scriptName] dont-require-permissions=no policy=ftp,read,write,test source=$scriptSource comment="managed-by=mohavise-mikrotik-iran-ip project=get-ip-iran-evo"
    }
}
