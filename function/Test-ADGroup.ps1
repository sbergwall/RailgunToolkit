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
function Test-ADGroup {
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
        $Identity,

        # Param3 help description
        [String]$Server
    )

    Begin {
    }
    Process {
        try {
            $ADParams = $PSBoundParameters
            Get-adgroup @ADParams -erroraction Stop
            $true
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            $false
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
    }
}