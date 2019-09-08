<#
.Synopsis
   Sync AD Group members from Target to Source by using DistinguishedName property
.DESCRIPTION
   Sync AD Group members from Target to Source by using DistinguishedName property. Running ADSISearcher as part of search function.
   ConfirmImpact is set to Medium.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Sync-ADGroupMember {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            Position = 0)]
        [String[]]$Source,

        # Param2 help description
        [Parameter(Mandatory = $true,
            Position = 1)]
        $Target
    )

    Begin {
        $domain = New-Object System.DirectoryServices.DirectoryEntry
        $searcher = [adsisearcher]$domain
        $searcher.PageSize = 1000000
        $searcher.PropertiesToLoad.Add('SamAccountName') | Out-

        Foreach ($SourceGroup in $Source) {
            Try {
                Get-ADGroup -Identity $SourceGroup
            }
            Catch {
                $PSCmdlet.ThrowTerminatingError($psitem)
                BREAK
            }
        }

    }
    Process {
        [String]$SearchString = $Null
        Foreach ($SourceString in $Source) {
            $SearchString += "(memberOf=$SourceString)"
        }

        # Add Members
        $searcher.Filter = "(&(|$SearchString)(!memberOf=$Target))"
        $searcher.FindAll() | ForEach-Object {
            if ($pscmdlet.ShouldProcess("$Target", "Add $($_.Properties['SamAccountName'])")) {
                Add-ADGroupMember -Identity $Target -Members $($_.Properties['SamAccountName']) -ErrorAction Stop
                Write-Verbose "Add $($_.Properties['SamAccountName']) to $Target"
            }
        }


        [String]$SearchStringRemove = $Null
        Foreach ($SourceStringRemove in $Source) {
            $SearchStringRemove += "(!memberOf=$SourceStringRemove)"
        }

        # Remove Members
        $searcher.Filter = "(&$SearchStringRemove(memberOf=$Target))"
        $searcher.FindAll() | ForEach-Object {
            if ($pscmdlet.ShouldProcess("$Target", "Removing $($_.Properties['SamAccountName'])")) {
                Remove-ADGroupMember -Identity $Target -Members $($_.Properties['SamAccountName']) -ErrorAction Stop
                Write-Verbose "Remove $($_.Properties['SamAccountName']) to $Target"
            }
        }
    }
    End {
    }
}


