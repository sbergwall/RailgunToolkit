function Get-DotNetFrameworkVersion {
    <#
 .SYNOPSIS
    Get Dot Net version. From version 4.5 to 4.7.1.
 
 .DESCRIPTION
    Using PSSession and Invoke-Command to read the .Net registry key, and translate the key value to version.

 .PARAMETER Computer
    Name of computer you want to get version from.
 
 .EXAMPLE
    PS C:\Windows\system32> Get-DotNetFrameworkVersion
    Computername        : NODE1
    NETFrameworkVersion : 4.6.2
    PSComputerName      : localhost
    RunspaceId          : 4a307912-c1c5-4066-b429-db1e2fb3d650
 
 .LINK
    http://ilovepowershell.com/2017/02/19/what-is-your-net-framework-version-use-powershell-to-check/
 .LINK
    https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed    

 .NOTES
    General note
 #>
   
    [CmdletBinding()]
    param (
        [string[]]$Computer = $env:COMPUTERNAME
    )

    begin {}

    process {
        $ScriptBlockToRun = {
            try {
                $NetRegKeys = Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction Stop
                foreach ($NetRegKey in $NetRegKeys) {
                    $Release = $NetRegKey.GetValue("Release")
                    Switch ($Release) {
                        378389 {$NetFrameworkVersion = "4.5"}
                        378675 {$NetFrameworkVersion = "4.5.1"}
                        378758 {$NetFrameworkVersion = "4.5.1"}
                        379893 {$NetFrameworkVersion = "4.5.2"}
                        393295 {$NetFrameworkVersion = "4.6"}
                        393297 {$NetFrameworkVersion = "4.6"}
                        394254 {$NetFrameworkVersion = "4.6.1"}
                        394271 {$NetFrameworkVersion = "4.6.1"}
                        394802 {$NetFrameworkVersion = "4.6.2"}
                        394806 {$NetFrameworkVersion = "4.6.2"}
                        460798 {$NetFrameworkVersion = "4.7"}
                        460805 {$NetFrameworkVersion = "4.7"}
                        461308 {$NetFrameworkVersion = "4.7.1"}
                        461310 {$NetFrameworkVersion = "4.7.1"}
                        461808 {$NetFrameworkVersion = "4.7.2"}
                        461814 {$NetFrameworkVersion = "4.7.2"}
                        Default {$NetFrameworkVersion = "Net Framework 4.5 or later is not installed."}
                    }
                    $Object = [PSCustomObject]@{
                        Computername        = $env:COMPUTERNAME
                        NETFrameworkVersion = $NetFrameworkVersion
                        LCID                = ($NetRegKey).PSChildName
                    }
                    $Object
                }
            }
            catch {
                Write-Error -Message $_
            }
        }

        try {
            If ($Computer -eq $env:COMPUTERNAME) {
                Invoke-Command -ScriptBlock $ScriptBlockToRun
            } 
            else {
                $Session = New-PSSession $Computer
                Invoke-Command -Session $Session -ScriptBlock $ScriptBlockToRun
            }
        }
        catch {
            Write-Error -Message $_
        }
    }
    end {
        If ($Session) {
            Remove-PSSession $Session
        }
    }
}