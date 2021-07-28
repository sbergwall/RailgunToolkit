Function Compare-MultipleObjects {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$True)]
        [Array[]]$Objects
    )
    begin {
        $Start = $true
    }
    Process {
        $Objects | ForEach-Object {
            $Object = $_
            if($Start){
                $Result = $Object
                $Start = $false
                return
            }
            If(!$Result){
                Return
            }
            $Result = (Compare-Object -ReferenceObject $Result -DifferenceObject $Object -ExcludeDifferent -IncludeEqual -EA SilentlyContinue).InputObject
        }
    }
    End{
        Write-Output $Result
    }
}
