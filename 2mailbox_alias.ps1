<#

.SYNOPSIS
    Reads a CSV file of email aliases and applies them to the correct Mailbox

.DESCRIPTION
    This script reads in a CSV file that contains the fields FirstName, Surname, PrimarySMTPAddress and EmailAddress.
    The semicolon separated addresses in the EmailAddress are added as aliases to the user's mailbox.

.NOTES
    Author: David Langton

#>

$UserCredential  = Get-Credential

# Connect to Exchange Online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$ExcludedDomains = @("apollofire.hs-cloud.net")

# Import user data from CSV file
$users = Import-CSV .\Book3.csv

foreach ($user in $users)
{
    # Grab the user's Mailbox
    $Mailbox = Get-Mailbox -Identity $user.PrimarySMTPAddress

    # First, add the @afdl.onmicrosoft.com alias
    if ($User.Surname -eq "")
    {
        $NewAddress = $User.FirstName + "@afdl.onmicrosoft.com"
    } else {
        $NewAddress = $User.FirstName + "." + $User.Surname + "@afdl.onmicrosoft.com"
    }

    Set-Mailbox -Identity $Mailbox.Alias -EmailAddresses @{add=$NewAddress}

    # Now add any other aliases from the csv file
    $Aliases = $user.EMailAddress.Split(";")
    foreach ($Alias in $Aliases)
    {
        if (-Not $Alias -eq "")
        {
            $SplitAlias = $Alias.split("@")
            # Check that the domain isn't in the exclusions list, if not then add it
            if ((-Not $ExcludedDomains.Contains($SplitAlias[1])))
            {
                Write-Host -ForegroundColor Green "Adding" $Alias "alias for user" $user.FirstName $user.Surname
                Set-Mailbox -Identity $Mailbox.Alias -EmailAddresses @{add=$Alias}
            }
        }
    }

}

# Disconnect the remote session
Remove-PSSession $Session