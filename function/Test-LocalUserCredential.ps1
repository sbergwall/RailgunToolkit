Function Test-LocalUserCredential {
  PARAM ($Computer = $env:COMPUTERNAME)
  
  Add-Type -AssemblyName System.DirectoryServices.AccountManagement
  $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$computer)
  $obj.ValidateCredentials($username, $password) 
}
