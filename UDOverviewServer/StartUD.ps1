$Theme = New-UDTheme -Name "Temp" -Definition @{
    '.ud-dashboard' = @{
        "BackgroundColor" = "rgb(243,243,243)"
        #"font-style" = 'Calibri'
    }
    UDNavBar = @{
        "BackgroundColor" = "rgb(19,29,78)"
    }

    UDFooter = @{
        "BackgroundColor" = "rgb(19,29,78)"
    }

    UDCard = @{
        BackgroundColor = 'White'
    }
  
  }

$pages = gci "E:\Google Drive\Jobb\Script Library\UniversalDashboard\UDOverviewServer\pages" -File | ForEach-Object { & $_.FullName }

$Navigation = New-UDSideNav -Content {
    New-UDSideNavItem -Text "Home" -Url "Home" -Icon docker
    New-UDSideNavItem -Text "Disk Overview" -Url "DiskOverview" -Icon delicious
}

$dashboard = New-UDDashboard -Title "Dashboard Title" -Pages $pages -Navigation $Navigation -Theme $theme

Get-UDDashboard | Stop-UDDashboard

Start-UDDashboard -Dashboard $dashboard -Port 10000
