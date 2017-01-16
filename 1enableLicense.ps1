$UserCredential  = Get-Credential

try {
    Connect-MsolService -Credential $UserCredential
}
catch {
    Write-Host -ForegroundColor Red "Failed to connect to Office 365"
    Exit-PSSession
}
Write-Host -ForegroundColor Green Connected
$users = Import-CSV .\migration.csv

$disabledOptions = New-MsolLicenseOptions -AccountSkuId reseller-account:O365_BUSINESS_PREMIUM -DisabledPlans YAMMER_ENTERPRISE

foreach ($user in $users)
{
    Write-Host $user.PrimarySMTPAddress
    Get-MsolUser -UserPrincipalName $user.PrimarySMTPAddress | Set-MsolUserLicense -LicenseOptions $disabledOptions
}