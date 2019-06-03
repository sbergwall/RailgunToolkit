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
function Test-ADCredential
{
    [CmdletBinding()]

    [OutputType([bool])]

    Param (
        # Credential to test
        [Parameter(ValueFromPipelineByPropertyName = $true,
        Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin {
    }

    Process
    {
        try {
            $UserName = $Credential.GetNetworkCredential().UserName
            $Password = $Credential.GetNetworkCredential().Password

            Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            $ds = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
            $ds.ValidateCredentials($UserName, $Password)
        }
        catch {
                $PSCmdlet.ThrowTerminatingError($PSitem)
        }
    }

    End {
    }
}