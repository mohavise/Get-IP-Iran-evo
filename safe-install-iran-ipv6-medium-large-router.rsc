# managed-by=mohavise-mikrotik-iran-ip
# project=get-ip-iran-evo
# do-not-edit-manually

:do {
    :local updateUrl "https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/update-iran-ipv6-medium-large-router.rsc"
    :local schedulerUrl "https://raw.githubusercontent.com/mohavise/Get-IP-Iran-evo/main/scheduler-update-iran-ipv6-medium-large-router.rsc"
    :local updateFile "update-iran-ipv6-medium-large-router.rsc"
    :local schedulerFile "scheduler-update-iran-ipv6-medium-large-router.rsc"

    :foreach file in={$updateFile;$schedulerFile} do={
        :if ([:len [/file find name=$file]] > 0) do={ /file remove $file }
    }

    :do { /tool fetch url=$updateUrl dst-path=$updateFile check-certificate=yes-without-crl } on-error={
        :log error "Iran IPv6 installer: updater download failed"
        :return ""
    }
    :do { /import file-name=$updateFile verbose=yes dry-run } on-error={
        :log error "Iran IPv6 installer: updater validation failed"
        /file remove $updateFile
        :return ""
    }
    /import file-name=$updateFile
    /file remove $updateFile

    :do { /tool fetch url=$schedulerUrl dst-path=$schedulerFile check-certificate=yes-without-crl } on-error={
        :log error "Iran IPv6 installer: scheduler download failed"
        :return ""
    }
    :do { /import file-name=$schedulerFile verbose=yes dry-run } on-error={
        :log error "Iran IPv6 installer: scheduler validation failed"
        /file remove $schedulerFile
        :return ""
    }
    /import file-name=$schedulerFile
    /file remove $schedulerFile

    /system script run update-iran-ipv6-medium-large-router
}