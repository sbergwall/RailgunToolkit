# Installation with Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$ChocoPackages = @(
    "chocolatey"
    "chocolatey-core",
    "bginfo",
    "googledrive ",
    "rsat",
    "rdcman ",
    "powershell ",
    "powershell-core ",
    "vscode",
    "sql-server-management-studio",
    "vscode-powershell ",
    "git.install ",
    "git ",
    "vscode-mssql ",
    "vscode-gitlens ",
    "ConEmu ",
    'openssh -params "/SSHAgentFeature"',
    'openssh -params "/SSHServerFeature"'
)

foreach ($ChocoPackage in $ChocoPackages) {
    choco.exe install $ChocoPackage -y
}

##  Or install Chocolatey with PowerShell
Get-PackageSource -Provider chocolatey -force
Find-Package -Source Chocolatey -Name $ChocoPackages | install-package -force -verbose -scope CurrentUser

# If RSAT has problem installing with Choco, try one of these
##Get-WindowsFeature -name *rsat* | Install-WindowsFeature -IncludeManagementTools -Restart
##Get-WindowsCapability -Online -Name RSAT.* | Add-WindowsCapability -Online

# Or test Scoop
Set-ExecutionPolicy 'RemoteSigned' -Scope Process -Force; Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')

scoop install 7zip
scoop install aria2
scoop install git
$ScoopBucketsToAdd = @(
    "Ash258 [https://github.com/Ash258/scoop-Ash258.git]"
    "jfut [https://github.com/jfut/scoop-jfut.git]"
    "extras",
    "games",
    "java",
    "jetbrains",
    "main",
    "nerd-fonts",
    "nightlies",
    "nirsoft",
    "nonportable",
    "php",
    "versions"
)
foreach ($scoopBucket in $ScoopBucketsToAdd) {
    scoop bucket add $scoopBucket
}

$ScoopAppsToInstall = @(
    #"azuredatastudio"
    #"concfg"
    #"discord"
    #"ffmpeg "
    "firefox"
    "git"
    #"mpc-hc-fork"
    #"mpc-qt"
    #"openssh"
    "pwsh"
    #"windirstat"
    #"youtube-dl"
    "pwsh-beta"
    "everything"
    #"bginfo"
    #"rsat"
    "rdcman"
    "vscode"
    #"sql-server-management-studio"
)
scoop install $ScoopAppsToInstall


# Install and update PowerShell modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -name dbatools, PSScriptAnalyzer, platyPS, Pester, ImportExcel, posh-git -Force -ErrorAction SilentlyContinue -Scope CurrentUser
Update-Module -name dbatools, PSScriptAnalyzer, platyPS, Pester, ImportExcel, posh-git -Force -ErrorAction SilentlyContinue
Update-Help -Force

Install-Module PowershellGet -Force

# Update Windows Client
Install-Module PSWindowsUpdate -Force -Confirm:$false
## You will need to register to use the Microsoft Update Service not just the default Windows Update Service.
Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false
Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot -Install -Verbose