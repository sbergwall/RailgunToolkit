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
function Wait-ADGroup {
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
        [String]$Server,

        [int]$Wait = 3,

        [int]$Retry = 5
    )

    Begin {
    }
    Process {
        $i = 0
        $Continue = $false

        $ADParams = $PSBoundParameters
        $ADParams.Remove('Retry') | Out-Null
        $ADParams.Remove('Wait') | Out-Null
        Do {
            try {
                Get-ADGroup @ADParams -errorAction stop
            }
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                $i++
                Write-Verbose "Looking for $Identity. On Retry $i. Star sleeping $wait seconds"
                Start-Sleep -Seconds $Wait
                If ($i -eq $Retry) {
                    $Continue = $true
                }
            } 
            catch {
                $PSCmdlet.ThrowTerminatingError($PSitem)
                $Continue = $true
            }
        } while ($Continue -eq $false)
    }
    End {
    }
}