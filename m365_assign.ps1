# find unlicensed customers
$unlicensedUsers = Get-MgUser -Filter 'assignedLicenses/$count eq 0' -ConsistencyLevel eventual -CountVariable unlicensedUserCount -All

# customers without country assigned
$unassignedCountry = Get-MgUser -Select Id,DisplayName,Mail,UserPrincipalName,UsageLocation,UserType | where { $_.UsageLocation -eq $null -and $_.UserType -eq 'Member' }

Write-Output "Users without licenses: "
Write-Output $unlicensedUsers 
Write-Output "`nUsers without country assigned: "
Write-Output $unassignedCountry 

foreach ($user in $unassignedCountry)
{
  Write-Output "Assigning country US to $($user.DisplayName)"
  Update-MgUser -UserId $user.Id -UsageLocation US
}

# rerun to find users without country
$unassignedCountry = Get-MgUser -Select Id,DisplayName,Mail,UserPrincipalName,UsageLocation,UserType | where { $_.UsageLocation -eq $null -and $_.UserType -eq 'Member' }
# view users without country assigned again to check if country assignment was successful
Write-Output "Users without country assigned (2nd run): "
Write-Output $unassignedCountry

# find Office 365 SKU
Get-MgSubscribedSku | Select -Property Sku*, ConsumedUnits -ExpandProperty PrepaidUnits | Format-List
$skuID = Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -like "*365*"} | Select-Object -Property SkuId
$skuID = Write-Output $skuID.SkuId
Write-Output "Office 365 SKU ID:" $skuID "`n" 

# assign license to unlicensed users
foreach ($user in $unlicensedUsers)
{
  Set-MgUserLicense -UserId $user.Id -AddLicenses @{SkuId = $skuID} -RemoveLicenses @()
}

Write-Output "Done"



