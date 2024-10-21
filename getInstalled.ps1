class InstalledApp {
    [string]$DisplayName
    [string]$DisplayVersion
    [string]$InstallDate
    [string]$Maintainer

    InstalledApp([string]$displayName, [string]$displayVersion, [string]$installDate, [string]$maintainer) {
        $this.DisplayName = $displayName
        $this.DisplayVersion = $displayVersion
        $this.InstallDate = $installDate
        $this.Maintainer = $maintainer
    }
}

class InstalledAppManager {
    
    [InstalledApp[]] getAllAppsFromRegistry() {

        #get lists from the registry
        $installedAppsHKLM = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
        ForEach-Object {
            [InstalledApp]::new($_.DisplayName, $_.DisplayVersion, $_.InstallDate, "HKLM")
        }

        $installedAppsHKCU = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
        ForEach-Object {
            [InstalledApp]::new($_.DisplayName, $_.DisplayVersion, $_.InstallDate, "HKCU")
        }

        $installedAppsHKLMWow = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
        ForEach-Object {
            [InstalledApp]::new($_.DisplayName, $_.DisplayVersion, $_.InstallDate, "HKLM Wow6432Node")
        }

        #combine lists from registry + remove duplicates
        return $installedAppsHKLM + $installedAppsHKCU + $installedAppsHKLMWow |
        Sort-Object DisplayName -Unique
    }

    [InstalledApp[]] getCSV() {
        $items = $this.getAllAppsFromRegistry()        
        $processedLines = $this.prepareChocoListData()

        return $this.compareChoco($items, $processedLines)
    }

    [InstalledApp[]] compareChoco([InstalledApp[]] $installedApps, [InstalledApp[]] $processedLines) {
        $additionalApps = [System.Collections.Generic.List[InstalledApp]]::new()

        #store the lines to reduce processing:
        $lineSet = @{}
        foreach ($line in $processedLines) {
            $lineSet[$line.DisplayName.ToLower().Replace("-", "").Replace("_", "")] = $true
        }

        foreach ($app in $installedApps) {
            if ([string]::IsNullOrEmpty($app.DisplayName)) {
                continue
            }
    
            $lowerDisplayName = $app.DisplayName.ToLower().Replace("-", "").Replace("_", "").split(" ")[0]
            
            if ($lineSet.ContainsKey($lowerDisplayName)
            ) {           
                $app.Maintainer = "Chocolatey"
                $lineSet.Remove($lowerDisplayName);
            }

        }    


        foreach ($notUsed in $lineSet.Keys) {
            $additionalApps.Add([InstalledApp]::new($notUsed, "", "", "Chocolatey"))
        }

        return $installedApps + $additionalApps.ToArray()
    }

    [InstalledApp[]] prepareChocoListData() {
        #run the choco command + parse data into two lists
        $chocoOut = choco list
        $lines = $chocoOut -split "`n"  
        #skip the first and last line, because its the headline and end of the output:
        $lines = $lines[1..($lines.Length - 2)]
        
        $res = $lines | ForEach-Object {
            $splitted = $_.Split(" ")
            [InstalledApp]::new($splitted[0], $splitted[1], "", "Chocolatey")
        }
        
        return $res
    }

}

$manager = [InstalledAppManager]::new()

$allApps = $manager.getCSV()

#export to csv
$allApps | Export-Csv "finalList.plist" -NoTypeInformation
    
#add the device name
$computerName = $env:COMPUTERNAME
$csvContent = Get-Content "finalList.plist"
$newContent = @("$computerName") + $csvContent
$newContent | Set-Content "finalList.plist"
    
"Done"