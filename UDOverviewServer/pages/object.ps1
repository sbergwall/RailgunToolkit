labilitNew-UDPage -Url "/object/:identity" -Endpoint {
    param ($identity)
    
    $Object = Get-ADObject -Filter { Name -eq $Identity } -Properties ObjectClass -IncludeDeletedObjects

    if ($Object.ObjectClass -eq "user") {
        $Object = Get-ADUser -Filter { Name -eq $Identity } -Properties *
    }
    elseif ($Object.ObjectClass -eq "computer") {
        $Object = Get-ADComputer -Filter { Name -eq $Identity } -Properties *
    }
    elseif ($Object.ObjectClass -eq "group") {
        $Object = Get-ADGroup -Filter { Name -eq $Identity } -Properties *
    }
    else {
        $Object = Get-ADObject -Filter { Name -eq $Identity } -Properties * -IncludeDeletedObjects
    }

    if ($Object.ObjectClass -eq 'group') {

        New-UDRow -Columns {
            New-UDColumn -size 8 -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title "Add Members" -Icon plus -Content {
                        New-UDRow -Columns {
                            New-UDColumn -Size 10 -Content {
                                New-UDTextbox -Id "txtSearch" -Label "Search" -Placeholder "Search for an object" -Icon search
                            }
                            New-UDColumn -Size 2 -Content {
                                New-UDButton -Id "btnSearch" -Text "Search" -Icon search -OnClick {
                                    $Element = Get-UDElement -Id "txtSearch" 
                                    $Value = $Element.Attributes["value"]
                    
                                    Set-UDElement -Id "results" -Content {
                                        New-UDGrid -Title "Search Results for: $Value" -Headers @("Name", "Mail" ,"sAMAccountName" ,"Add") -Properties @("Name", "Mail" ,"sAMAccountName" ,"Add") -Endpoint {
                                            $Objects = Get-ADObject -Filter {anr -like $value} -Properties Name,sAMAccountName,ObjectClass,mail
                                            $Objects | ForEach-Object {
                                                $user = $_.sAMAccountName
                                                [PSCustomObject]@{
                                                    Name = $_.Name
                                                    Mail = $_.Mail
                                                    sAMAccountName = $_.sAMAccountName
                                                    Add = New-UDButton -Text "Add" -OnClick {
                                                        Add-ADGroupMember -Identity $object -Members $user
                                                    }
                                                }
                                            } | Out-UDGridData 
                                            
                                        } 
                                        
                                    }
                                    
                                }
                               
                            }
                            
                        }
                New-UDElement -Tag "div" -Id "results"
                    }
                }
            }
        }

        New-UDRow -Columns {
            New-UDColumn -SmallSize 8 -Content {
                New-UDTable -Id "members" -Headers @("Name", "Remove") -Endpoint {
                    Get-ADGroupMember -Identity $identity | ForEach-Object {
                        $member = $_
                        [PSCustomObject]@{
                            Name   = $_.name
                            Remove = New-UDButton -Text "Remove" -OnClick {
                                Remove-ADGroupMember -Identity $identity -Members $member -Confirm:$false
                            }
                        }
                    } | Out-UDTableData -Property @("Name", "Remove")
                } -AutoRefresh -RefreshInterval 5
            }
        }
    }
}