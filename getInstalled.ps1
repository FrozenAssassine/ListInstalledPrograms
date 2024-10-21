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

        $processedLines = $processedLines | ForEach-Object {
            if ($_.DisplayName) {
                #uppercase first character of chocolatey package

                $firstChar = $_.DisplayName[0].ToString().ToUpper()
                $remainingChars = $_.DisplayName.Substring(1)
                $_.DisplayName = $firstChar + $remainingChars
            }
            $_
        }

        return $this.compareChoco($items, $processedLines)
    }

    [InstalledApp[]] compareChoco([InstalledApp[]] $installedApps, [InstalledApp[]] $chocoList) {
        $mergedApps = @{}

        $apps = $chocoList + $installedApps
        foreach ($app in $apps) {
            $key = $app.DisplayName.ToLower().Replace("-", "").Replace("_", "")

            if (-not ($mergedApps.ContainsKey($key))) {
                $mergedApps[$key] = $app
                continue;
            }

        }
        return $mergedApps.Values
    }

    [InstalledApp[]] prepareChocoListData() {
        #run the choco command + parse data into two lists
        $chocoOut = choco list
        $lines = $chocoOut | Select-Object -Skip 1 | Select-Object -SkipLast 1
        $pattern = '^(?<name>[a-zA-Z0-9.\-_]+) (?<version>[0-9][0-9a-zA-Z._]*)$'
        $allMatches = @()

        # Loop through each line and check for matches
        foreach ($line in $lines) {
            $match = [regex]::Match($line, $pattern)
            if ($match.Success) {
                $allMatches += $match
            }
        }
        
        return $matches | ForEach-Object {
            $splitted = $_.Value.Split(" ")
            [InstalledApp]::new($splitted[0], $splitted[1], "", "Chocolatey") 
        }
    }
}

$allApps = [InstalledAppManager]::new().getCSV()

#export to csv
$allApps | Export-Csv "finalList.plist" -NoTypeInformation

#add the device name
$computerName = $env:COMPUTERNAME + " | " + (Get-Date -Format "dd.MM.yyyy")
$csvContent = Get-Content "finalList.plist"
$newContent = @("$computerName") + $csvContent
$newContent | Set-Content "finalList.plist"

"Done"