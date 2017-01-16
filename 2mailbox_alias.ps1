# Script to bulk add mailbox alias in Exchange 365

$UserCredential  = Get-Credential

# Attempt to connect to Office 365
Connect-MsolService -Credential $UserCredential

# Attempt to connect to Exchange Online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Grab the relevant users' mailboxes
$Mailboxes = @()
$ExcludedDomains = @("apollofire.hs-cloud.net")
$users = Import-CSV .\migration.csv

foreach ($user in $users)
{
    # Grab the MsolUser and Mailbox
    $Mailbox = Get-Mailbox -Identity $user.PrimarySMTPAddress
    $MsolUser = Get-MsolUser -UserPrincipalName (($Mailbox.UserPrincipalName).toString())

    # First, add the @afdl.onmicrosoft.com alias, if it doesn't already exist
    if ($User.Surname -eq "")
    {
        $NewAddress = $User.FirstName + "@afdl.onmicrosoft.com"
    } else {
        $NewAddress = $User.FirstName + "." + $User.Surname + "@afdl.onmicrosoft.com"
    }

    if (-Not $Mailbox.EmailAddresses -contains "smtp:" + $NewAddress)
    {
        $Mailbox.EmailAddresses += $NewAddress
    }

    # Now add any other aliases from the csv file, if they don't already exist
    $Aliases = $user.EMailAddress.Split(";")
    foreach ($Alias in $Aliases)
    {
        if (-Not $Alias -eq "")
        {
            $SplitAlias = $Alias.split("@")
            # Check that the domain isn't in the exclusions list, if not then add it
            if ((-Not $ExcludedDomains.Contains($SplitAlias[1])) -and $Alias -ne $MsolUser.UserPrincipalName)
            {
                Write-Host "Adding" $Alias "alias for user" $user.FirstName $user.Surname
                
                if (-Not $Mailbox.EmailAddresses -contains "smtp:" + $Alias)
                {
                    $Mailbox.EmailAddresses += $Alias
                }
            }
        }
    }

    # Commit the changes
    Set-Mailbox -Identity $Mailbox.Alias -EmailAddresses $Mailbox.EmailAddresses -ErrorAction SilentlyContinue
}

# Disconnect the remote session
Remove-PSSession $Session