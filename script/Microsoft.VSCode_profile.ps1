function prompt {
  $host.ui.RawUI.WindowTitle = "$env:USERNAME @ $env:COMPUTERNAME : $(Get-Location)"

  $lastCommand = Get-History -Count 1
  $ElapstedTime = "{0:HH:mm:ss}" -f ([datetime]$($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).Ticks)

  Write-host "[$($ElapstedTime)]" -NoNewline -ForegroundColor Blue
  Write-Host ":" -NoNewline

  Write-Host (Split-Path (Get-Location) -Leaf) -NoNewline
  return "$ > "
}