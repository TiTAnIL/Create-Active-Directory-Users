param (
    [switch]$Help,
    [string]$FName,
    [string]$LName,
    [string]$Desc = "New User",
    [string]$Delimiter = ".",
    [string]$Pass = "P@ssWord123",
    [string]$ADDomain = "titan.lab",
    [string]$MailDomain = "titan.com"
   # [string]$Path = ""
    )


if($Help) {
    Write-Host "Script to create a new Active Directory user"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "-FName      : First name of the user (Required)"
    Write-Host "-LName      : Last name of the user (Required)"
    Write-Host "-Desc       : User description (Optional, Default: 'New User')"
    Write-Host "-Delimiter  : Delimiter used between first and last name for UserPrincipalName (Optional, Default: '.')"
    Write-Host "-Password   : User initial password (Optional, Default: Qwer@1234')"
    Write-Host "-ADDomain   : Active Directory domain (Optional, Default: 'titan.lab')"
    Write-Host "-MailDomain : Mail domain (optional, Default: 'titan.com')"
  #  Write-Host "-Path       : Path, (optional, Default: 'OU=New Users,OU=Organization ,DC=titan,DC=lab')"
    Write-Host ""
    Write-Host "Example Usage:"
    Write-Host "    .\AddUserToAD.ps1 -FName 'John' -LName 'Due' -Desc 'HR Manager' -Pass 'HR#1Manager!"
    return
    }

if (-not $FName -or -not $LName) {
    Write-Host "Error: -FName and -LName are required."
    return
}

$AtSign = "@"
$username = $FName.Substring(0, [Math]::Min($FName.Length, 1)) + $Delimiter + $LName
$email = "$username$mdomain"

$user = @{
    Description = $Desc
    UserPrincipalName = "$username$AtSign$ADDomain"
    Name = "$LName $FName"
    SamAccountName = $username
    Surname = $LName
    GivenName = $FName
    EmailAddress = "$email"
    ChangePasswordAtLogon = 0
    CannotChangePassword = 1
    PasswordNeverExpires = 1
    AccountPassword = ConvertTo-SecureString $Pass -AsPlainText -Force
    Enabled = 1
   # Path = $Path
    }


New-ADUser @user


Write-Host "User $username has been created succesfully"
