# Warning: This script will remove all licenses from all licensed users

function Get-LicensedUsers
{
  return Get-MgUser -Filter 'assignedLicenses/$count ne 0' `
    -ConsistencyLevel eventual -CountVariable licensedUserCount -All `
    -Select UserPrincipalName,DisplayName,AssignedLicenses
}

foreach($user in Get-LicensedUsers)
{
    $licensesToRemove = $user.AssignedLicenses | Select -ExpandProperty SkuId
    $user = Set-MgUserLicense -UserId $user.UserPrincipalName -RemoveLicenses $licensesToRemove -AddLicenses @{} 
}

$licensedUsers = Get-LicensedUsers

Write-Output "Users with licenses" $licensedUsers
