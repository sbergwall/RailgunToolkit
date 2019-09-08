New-UDPage -Name "DiskOverview" -Icon delicious -Content {
    New-UDRow {
        New-UDColumn -SmallOffset 1 -SmallSize 10 -Endpoint {
            $Headers = @("PSComputerName", "DeviceID", "DriveType", "VolumeName", "SizeGB", "FreeSpaceGB")
            $Properties = @("PSComputerName", "DeviceID", "DriveType", "VolumeName", "SizeGB", "FreeSpaceGB")
            New-UDGrid -Title "Disk Overview" -Headers $Headers -Properties $Properties -Endpoint {
                $Servers = "localhost" 
                $data = Get-CimInstance -ComputerName $Servers -ClassName win32_logicaldisk | ForEach-Object {
                    [PSCustomObject]@{
                        PSComputerName = $_.PSComputerName
                        DeviceID       = $_.DeviceID
                        DriveType      = $_.DriveType
                        VolumeName     = $_.VolumeName
                        SizeGB         = ($_.Size/1GB).ToString(".00")
                        FreeSpaceGB    = ($_.FreeSpace/1GB).ToString(".00")
                    }
                }
                $data | Out-UDGridData
            }
        }
    }
}