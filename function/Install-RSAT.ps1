$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0

Restart-Service wuauserv

#Get-WindowsCapability -Name RSAT.* -Online | Add-WindowsCapability –Online
Get-WindowsFeature | Where-Object {$_.Name -like 'RSAT*'} | Install-WindowsFeature


Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU

Restart-Service wuauserv
