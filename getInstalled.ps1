#get the lists from the registry
$installedAppsHKLM = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Select-Object DisplayName, DisplayVersion, InstallDate
$installedAppsHKCU = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Select-Object DisplayName, DisplayVersion, InstallDate

#combine list from registry + remove duplicates
$combinedApps = $installedAppsHKLM + $installedAppsHKCU |
    Sort-Object DisplayName -Unique

$currentList = Get-WmiObject -Class Win32_Product | 
    Select-Object Name, Version | 
    Sort-Object Name -Unique

#combine app list from registry with list from WmiObject: 
$finalList = $combinedApps | Where-Object {
    -not ($currentList.DisplayName -contains $_.DisplayName)
}

$finalList | Export-Csv "finalList.plist" -NoTypeInformation
#add the name of the current device:
$computerName = $env:COMPUTERNAME
$csvContent = Get-Content "finalList.plist"
$newContent = @("$computerName") + $csvContent
$newContent | Set-Content "finalList.plist"

"Done"