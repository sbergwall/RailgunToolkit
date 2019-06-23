<#
.Synopsis
   Invoke Net.exe with View
.DESCRIPTION
   DESCRIPTION TODO
.EXAMPLE
   [string[]]$myServers = 'myServer1','myServer2'
   [psobject[]]$shares = $myServers | Get-SharedFolder
   write-host 'List of Shares' -ForegroundColor Cyan
   $shares  | ft -AutoSize
.EXAMPLE
   [string[]]$myServers = 'myServer1','myServer2'
   [psobject[]]$shares = $myServers | Get-SharedFolder
   write-host 'Shares as Get-Item output' -ForegroundColor Cyan
   $shares  | select -expand Item
.NOTES
   This function is from a answer on superuser.com (https://superuser.com/questions/769679/powershell-get-list-of-folders-shared).
   It will invoke net.exe with View on the servers you have specified. 
#>

function Invoke-NetView {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$ComputerName 
        ,
        [Parameter(Mandatory = $false)]
        [switch]$GetItem
        ,
        [Parameter(Mandatory = $false)]
        [string[]]$ColumnHeadings = @('Share name','Type','Used as','Comment')  #I suspect these differ depending on OS language?  Therefore made customisable
        ,
        [Parameter(Mandatory = $false)]
        [string]$ShareName = 'Share name' #tell us which of the properties relates to the share name
        #,
        #[Parameter(Mandatory = $false)]
        #[string[]]$Types = @('Disk') # again, likely differs with language.  Also there may be other types to include?
    )

    begin {
        [psobject[]]$Splitter = $ColumnHeadings | ForEach-Object{
            $ColumnHeading = $_
            $obj = new-object -TypeName PSObject -Property @{
                Name = $ColumnHeading
                StartIndex = 0
                Length = 0
            }
            $obj | Add-Member -Name Initialise -MemberType ScriptMethod {
                param([string]$header)
                process {
                    $_.StartIndex = $header.indexOf($_.Name)
                    $_.Length = ($header -replace ".*($($_.Name)\s*).*",'$1').Length
                }
            }
            $obj | Add-Member -Name GetValue -MemberType ScriptMethod {
                param([string]$line)
                process {
                    $line -replace ".{$($_.StartIndex)}(.{$($_.Length)}).*",'$1'
                }
            }
            $obj | Add-Member -Name Process -MemberType ScriptMethod {
                param([psobject]$obj,[string]$line)
                process {
                    $obj | Add-Member -Name $_.Name -MemberType NoteProperty -Value ($_.GetValue($line))
                }
            }
            $obj
        }
    }

    process {

        [string[]]$output = (NET.EXE VIEW $ComputerName)
        [string]$headers = $output[4] #find the data's heading row
        $output = $output[7..($output.Length-3)] #keep only the data rows
        $Splitter | %{$_.Initialise($headers)}

        foreach($line in $output) { 
            [psobject]$result = new-object -TypeName PSObject -Property @{ComputerName=$ComputerName;}
            $Splitter | %{$_.Process($result,$line)}
            $result | Add-Member '_ShareNameColumnName' -MemberType NoteProperty -Value $ShareName
            $result | Add-Member 'Path' -MemberType ScriptProperty -Value {("\\{0}\{1}" -f $this.ComputerName,$this."$($this._ShareNameColumnName)")}
            $result | Add-Member 'Item' -MemberType ScriptProperty -Value {Get-Item ($this.Path)}
            $result | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value ([System.Management.Automation.PSMemberInfo[]]@(New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]](@('ComputerName','Path') + $ColumnHeadings))))
            $result
        }
    }
}