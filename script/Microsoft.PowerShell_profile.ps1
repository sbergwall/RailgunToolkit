function prompt {
    $Admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    If ($Admin) {$Administrator = "Administrator:"}

    $host.ui.RawUI.WindowTitle = "$Administrator $env:USERNAME @ $env:COMPUTERNAME : $(Get-Location)"
    
    $lastCommand = Get-History -Count 1
    $ElapstedTime = "{0:HH:mm:ss}" -f ([datetime]$($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).Ticks)

    Write-host "[$($ElapstedTime)]" -NoNewline -ForegroundColor Green
    Write-Host ":" -NoNewline 

    Write-Host (Split-Path (Get-Location) -Leaf) -NoNewline
    return "$ > "
}