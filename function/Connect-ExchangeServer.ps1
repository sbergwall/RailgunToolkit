<#
.Synopsis
   Create a PS session to a Exchange Server and import the Exchange cmdlets.
.DESCRIPTION
   Create a PS session to a Exchange Server and import the Exchange cmdlets.
.EXAMPLE
   Connect-ExchangeServer -ExchangeServer EX01 -Credential (Get-Credential)
.EXAMPLE
   $Cred = Get-Credentia
   Connect-ExchangeServer -ExchangeServer EX01 -Credential $cred
.NOTES
   General notes
#>
function Connect-ExchangeServer {
    [CmdletBinding(ConfirmImpact = 'None')]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ExchangeServer,

        # Param3 help description
        [Parameter(ValueFromPipelineByPropertyName = $true,
        Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin {
    }
    Process {
        try {
            $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServer/PowerShell/" -Authentication Kerberos -Credential $Credential -ErrorAction Stop
            Import-PSSession (Import-PSSession $ExSession -AllowClobber) -Global
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
    }
}