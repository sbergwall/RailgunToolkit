#$pages = gci "E:\Google Drive\Jobb\Script Library\Git Projects\RailgunToolkit\UDOverviewServer\pages" -File | ForEach-Object { & $_.FullName }
$pages = @()
$pages += New-UDPage -Name "home" -Icon cannabis -Content {

}


$Pages += New-UDPage -Name "DiskOverview" -Icon delicious -Content {
    New-UDRow {
        New-UDColumn -SmallOffset 1 -SmallSize 10 -Endpoint {

            $Headers = @("PSComputerName", "DeviceID", "DriveType", "VolumeName", "SizeGB", "FreeSpaceGB")
            $Properties = @("PSComputerName", "DeviceID", "DriveType", "VolumeName", "SizeGB", "FreeSpaceGB")

                New-UDGrid -Title "Disk Overview" -Headers $Headers -Properties $Properties -Endpoint {
                    $servers = "localhost"
                    Get-CimInstance -ComputerName $Servers -ClassName win32_logicaldisk | ForEach-Object {
                        [PSCustomObject]@{
                            PSComputerName = $_.PSComputerName
                            DeviceID       = $_.DeviceID
                            DriveType      = $_.DriveType
                            VolumeName     = $_.VolumeName
                            SizeGB         = ($_.Size / 1GB).ToString(".00")
                            FreeSpaceGB    = ($_.FreeSpace / 1GB).ToString(".00")
                        }
                    } | Out-UDGridData
                }
        }
    }
}

$pages += New-UDPage -Name "localUsers" -Icon docker -Content {
    New-UDElement -Id "LocalUser"-Tag div -Endpoint {
        New-UDRow -Endpoint {
            New-UDColumn -SmallOffset 1 -SmallSize 10 -Endpoint {
                $Properties = @("Name", "Enabled", "Description", "Remove", "Reset_Password")
                New-UDGrid -AutoRefresh -RefreshInterval 5 -Title "Local Users" -Headers $Properties -Properties $Properties -Endpoint {

                    Get-LocalUser | ForEach-Object {
                        [PSCustomObject]@{
                            "Name"           = $psitem.Name
                            "Enabled"        = $psitem.Enabled
                            "Description"    = $psitem.Description
                            "Remove"         = New-UDButton -Text "Remove" -OnClick {
                                Remove-LocalUser -Name $psitem.Name
                                Show-UDToast -Message "Removed"
                            }

                            "Reset_Password" = New-UDButton -Text "Reset Password" -OnClick {
                                Show-UDToast -Message "PasswordReset"
                            }
                        } 
                    } | Out-UDGridData
                }

                New-UDInput -Title "New User" -Content {
                    New-UDInputField -Type 'textbox' -Name 'Name' -Placeholder 'Name'
                    New-UDInputField -Type 'textbox' -Name 'FullName' -Placeholder 'FullName'
                    New-UDInputField -Type 'password' -Name 'pass' -Placeholder 'pass'
                } -Endpoint {
                    param ($name, $FullName, $pass)
                    $password = ConvertTo-SecureString $pass -Force -AsPlainText
                    New-LocalUser -AccountNeverExpires -PasswordNeverExpires -Name $name -FullName $FullName -Password $password
                    Sync-UDElement -Id "LocalUser"
                }
            }
        }
    }
}

$Navigation = New-UDSideNav -Content {
    New-UDSideNavItem -Text "Home" -Url "Home" -Icon docker
    New-UDSideNavItem -Text "Disk Overview" -Url "DiskOverview" -Icon delicious
    New-UDSideNavItem -Text "Local Users" -Url "localUsers" -Icon docker
}

$dashboard = New-UDDashboard -Title "Dashboard Title" -Pages $pages -Navigation $Navigation
Get-UDDashboard | Stop-UDDashboard

Start-UDDashboard -Dashboard $dashboard -Port 10000 -AutoReload
