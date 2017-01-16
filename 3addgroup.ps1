Import-Module ActiveDirectory

$users = Import-Csv .\migration.csv

foreach ($user in $users)
{
    if ($user.Surname -ne "")
    {
        $username = $user.FirstName.Substring(0,1) + $user.Surname
        Add-ADGroupMember -Identity "Outlook 365 Autodiscover" -Members $username
    } else {
        $username = $user.FirstName
        Add-ADGroupMember -Identity "Outlook 365 Autodiscover" -Members $username
    }
}