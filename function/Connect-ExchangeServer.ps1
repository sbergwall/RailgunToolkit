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
        # Name of the Exchange Server you want to connect to
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ExchangeServer,

        # Your credentials
        [Parameter(ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        # Authentication Mechanism
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Runspaces.AuthenticationMechanism] 
        $Authentication = [System.Management.Automation.Runspaces.AuthenticationMechanism]::Kerberos
    )

    Begin {
    }
    Process {
        try {
            $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServer/PowerShell/" -Authentication $Authentication -Credential $Credential -ErrorAction Stop
            Import-PSSession (Import-PSSession $ExSession -AllowClobber) -Global
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
    }
}
