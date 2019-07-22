Function Get-ADUserLastLogon {
    param
    (
        # Take a samaccountname property
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Identity')]
        [string[]]$Username
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

        Write-Verbose -Message "[BEGIN  ] Finding All Domain Controllers"
        $ADDomainControllers = Get-ADDomainController -Filter { Name -like "*" }
        $NumberofDCs = ($ADDomainControllers | Measure-Object).count
        Write-Verbose -Message "[BEGIN  ] Number of Domain Controllers Found: $NumberofDCs"

        If ($PSBoundParameters.ContainsKey('UserName')) {

        }
        else {
            Write-Verbose "No username was specified, getting all AD accounts in domain"
            $Username = Get-ADUser -Filter * -Properties sAMAccountName | Select-Object -ExpandProperty sAMAccountName
        }
    }

    process {
        foreach ($user in $username) {
            $lastlogon = 0

            foreach ($ADDomainController in $ADDomainControllers) {
                $DCHostname = $ADDomainController.HostName
                Write-Verbose -Message "[Process] Checking on Domain Controller: $DCHostname"
                try {
                    $paramGetADUser = @{
                        Identity    = $user
                        Server      = $DCHostname
                        ErrorAction = 'Stop'
                        Properties  = 'lastLogon'
                    }

                    $ADUser = Get-ADUser @paramGetADUser
                } #Try
                Catch {
                    Write-Warning "Error on:$DCHostname. Message: $psitem"
                }
                Write-Verbose -Message "[Process]`t Converting To DateTime"
                $ADUserlastLogon = [DateTime]::FromFileTime($ADUser.lastLogon)
                Write-Verbose -Message "[Process]`t LastLogon Date: $ADUserlastLogon"

                if ($ADUserLastLogon -gt $lastLogon) {
                    $lastLogon = $ADUserlastLogon
                } # If Logon is GT
            } #ForEach DC

            [PSCustomObject]@{
                UserName  = $user
                LastLogon = $lastlogon
            }
        }
    }
}