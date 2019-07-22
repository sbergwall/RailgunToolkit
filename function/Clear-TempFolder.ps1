BREAK

([switch]$Elevated)
function CheckAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((CheckAdmin) -eq $false) {
    if ($elevated) {
        # could not elevate, quit
    }
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -ExecutionPolicy Bypass -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    Exit
}


$AllFolders = @(
    "C:\Windows\Temp"
    "C:\Windows\Prefetch"
    "C:\Documents and Settings\*\Local Settings\Temp"
    "C:\Users\*\Appdata\Local\Temp"
    "C:\users\*\Downloads"
    "C:\AMD"
    "C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files"
    "C:\Windows\SoftwareDistribution\Download"
)

Foreach ($Folder in $AllFolders) {
    Get-Item $Folder | Get-ChildItem -Force -Recurse | Remove-Item -Recurse -Force
}

$AllFileSystemDrives = Get-PSDrive -PSProvider 'FileSystem'
foreach ($Drive in $AllFileSystemDrives) {
    $Path = Join-Path -Path $Drive.Root -ChildPath '$Recycle.Bin'
    Get-ChildItem -Path $Path -Force -Recurse | Remove-Item -Recurse -Force
}

# For example, the following command will uninstall all previous versions of components without the scheduled task’s 30-day grace period:
Dism.exe /online /Cleanup-Image /StartComponentCleanup

#The following command will remove files needed for uninstallation of service packs. You won’t be able to uninstall any currently installed service packs after running this command:
Dism.exe /online /Cleanup-Image /SPSuperseded

#The following command will remove all old versions of every component. You won’t be able to uninstall any currently installed service packs or updates after this completes:
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase