function Get-ADUserLastLogon {
    param
    (
        # Take a samaccountname property
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Identity')]
        [Object[]]$SamAccountName,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Property,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Filter
    )

    begin {
        Write-Verbose -Message "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
       
        Write-Verbose -Message "[BEGIN  ] Finding All Domain Controllers"
        $ADDomainControllers = Get-ADDomainController -Filter { Name -like "*" }
        $NumberofDCs = ($ADDomainControllers | Measure-Object).count

        If ($NumberofDCs -eq 0) { throw "No AD Domain Controllers could be found." }
        Write-Verbose -Message "[BEGIN  ] Number of Domain Controllers Found: $NumberofDCs"

        If (-not($PSBoundParameters.ContainsKey('SamAccountName'))) {
            try {
                Write-Verbose "[BEGIN  ] No SamAccountName was specified, getting all AD user accounts in domain"
                $adSplat = @{
                    Filter      = If ($Filter) { $Filter } else { "*" }
                    Property    = If ($Property) { $Property } else { "*" }
                    ErrorAction = "Stop"
                }

                $SamAccountName = Get-ADUser @adSplat
            } 
            catch {
                $PSCmdlet.WriteError($psitem) 
            }
        }
    } # Begin

    process {
        foreach ($user in $SamAccountName ) {
            try {
                switch ($user) {
                    { $user -is [string] } {
                        $Splatting = @{
                            Identity    = $user 
                            ErrorAction = "Stop"
                           
                        }
                        If (-not($null -eq $Property)) {
                            $Splatting.Properties = $Property
                        }

                        $user = Get-ADUser @Splatting
                    }
               
                    { $user -is [Microsoft.ActiveDirectory.Management.ADUser] } {
                        If ($PSBoundParameters.ContainsKey('Property')) { $user = Get-ADUser -Identity $user -Properties $Property }
                    }
                    default { throw "Unknown type was used." }

                } # Switch
            }  
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                # Catch if AD user cannot be found and go to next user in loop
                $PSCmdlet.WriteError($psitem)
                continue
            }

            catch {
                $PSCmdlet.WriteError($psitem)
            }

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
                    $OwningDC = $DCHostname
                } # If Logon is GT
            } #ForEach DC

            $User | Add-Member -MemberType NoteProperty -Name LastLogonExtended -Value $lastlogon -Force
            $User | Add-Member -MemberType NoteProperty -Name LastLogonExtendedDC -Value $OwningDC -Force
            $user
        } # foreach $user
    } # Process
}
