function Wait-ADObjectReplication {
    [CmdletBinding(DefaultParameterSetName = 'Identity')]

    param (
        [Parameter(Mandatory = $True,
            ParameterSetName = 'Identity')]
        [ValidateNotNullOrEmpty()]
        [string]$Identity,

        [Parameter(Mandatory = $True,
            ParameterSetName = 'LDAPFilter')]
        [ValidateNotNullOrEmpty()]
        [String]$LDAPFilter,

        [string[]]$Server,

        [ValidateNotNullOrEmpty()]
        [TimeSpan]$Timeout = '00:00:30'
    )

    begin {
        Write-Verbose -Message "Starting: $($MyInvocation.Mycommand)"

        If (!($PSBoundParameters.ContainsKey('Server'))) {
            try {
            Write-Verbose -Message "Finding All Domain Controllers"
            $Server = Get-ADDomainController -Filter { Name -like "*" } -ErrorAction Stop
            $NumberofDCs = ($Server | Measure-Object).count

            Write-Verbose -Message "Number of Domain Controllers Found: $NumberofDCs"
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($psitem)
            }
        }
    } # Begin

    process {
        foreach ($DC in $Server) {
            $GetADObjectSplatting = @(
                Identity    = If ($null -ne $Identity) {$Identity} 
                LDAPFilter  = If ($null -ne $LDAPFilter) {$LDAPFilter}
                Server      = $DC
                ErrorAction = 'Stop'
            )

            # wait for the object to replicate
            Write-Verbose "Checking $DC"

            $object = $Null
            while ($object -eq $Null) {

                # check if we've timed out
                $left = New-TimeSpan $(Get-Date) $stop
                if ($left.TotalSeconds -lt 0) {
                    # timeout
                    throw [System.TimeoutException]"Object propagation has timed out."
                }

                try {
                # wait a bit and check again
                    Start-Sleep -Milliseconds 250
                    $object = Get-ADObject @GetADObjectSplatting
                } 
                catch {
                    $PSCmdlet.WriteError($psitem)
                }
            }
        }
    } # process
}