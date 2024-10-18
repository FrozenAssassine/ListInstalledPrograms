# Get lists from the registry
$installedAppsHKLM = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Select-Object DisplayName, DisplayVersion, InstallDate, @{Name = "Maintainer"; Expression = { "HKLM" } }

$installedAppsHKCU = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Select-Object DisplayName, DisplayVersion, InstallDate, @{Name = "Maintainer"; Expression = { "HKCU" } }

$installedAppsHKLMWow = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
Select-Object DisplayName, DisplayVersion, InstallDate, @{Name = "Maintainer"; Expression = { "HKLM Wow6432Node" } }

#combine lists from registry + remove duplicates
$combinedApps = $installedAppsHKLM + $installedAppsHKCU + $installedAppsHKLMWow |
Sort-Object DisplayName -Unique

#run the choco command + parse data into two lists
$chocoOut = choco list
$lines = $chocoOut -split "`n"
#skip the first and last line, because its the headline and end of the output:
$lines = $lines[1..($lines.Length - 2)]

$processedLines = $lines | ForEach-Object {
    $remIndex = $_.IndexOf(" ");
    if ($remIndex -ne -1) {
        $_.Remove($remIndex).Replace("-", " ").ToLower()
    }
    else {
        $_.Replace("-", " ").ToLower()
    }
}

$processedLines

$maintainer = "-"
$allApps = $combinedApps | ForEach-Object {
    if (![string]::IsNullOrEmpty($_.DisplayName)) {
    
        $maintainer = "-"
        foreach ($line in $processedLines) {

            if ($_.DisplayName.ToLower().Replace(" ", "-") -like "*$line*" -or 
                $_.DisplayName.ToLower().Replace(" ", "") -like "*$line*" -or 
                $_.DisplayName.ToLower().Replace("-", "") -like "*$line*"
            ) {
                $maintainer = "Chocolatey"
                break;
            }
        }

        [PSCustomObject]@{
            DisplayName    = $_.DisplayName
            DisplayVersion = $_.DisplayVersion
            InstallDate    = $_.InstallDate
            Maintainer     = if ($maintainer -eq "-") { $_.Maintainer } else { $maintainer }
        }
    }
}

#export to csv
$allApps | Export-Csv "finalList.plist" -NoTypeInformation

#add the device name
$computerName = $env:COMPUTERNAME
$csvContent = Get-Content "finalList.plist"
$newContent = @("$computerName") + $csvContent
$newContent | Set-Content "finalList.plist"

"Done"