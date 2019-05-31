<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
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
        [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
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
            $ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServer/PowerShell/" -Authentication Kerberos -Credential $Credential
            Import-PSSession (Import-PSSession $ExSession -AllowClobber) -Global
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
    }
}