Get-WmiObject -Class Win32_Product | Select-Object -Property Name > "list.txt"



Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize > "InstalledSoftwareList.txt"