param (
    [switch]$Help,
    [switch]$ListDepartments,
    [string]$FName,
    [string]$LName,
    [string]$Desc = "New User",
    [string]$Delimiter = ".",
    [string]$Pass = "P@ssWord123",
    [string]$ADDomain = "titan.lab",
    [string]$MailDomain = "titan.com",
    [string]$Department,
    [string]$DepartmentsOU = "OU=organization,DC=titan,DC=lab"  # The parent OU where department OUs are located
)

# Show help information
if ($Help) {
    Write-Host "Script to create a new Active Directory user"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "-FName           : First name of the user (Required)"
    Write-Host "-LName           : Last name of the user (Required)"
    Write-Host "-Desc            : User description (Optional, Default: 'New User')"
    Write-Host "-Delimiter       : Delimiter used between first and last name for UserPrincipalName (Optional, Default: '.')"
    Write-Host "-Password        : User initial password (Optional, Default: 'P@ssWord123')"
    Write-Host "-ADDomain        : Active Directory domain (Optional, Default: 'titan.lab')"
    Write-Host "-MailDomain      : Mail domain (Optional, Default: 'titan.com')"
    Write-Host "-Department      : Department for the user (Optional)"
    Write-Host "-ListDepartments : List all available departments with a 'Users' sub-OU in Active Directory"
    Write-Host "-DepartmentsOU   : The parent OU under which department OUs are located (Default: 'OU=organization,DC=titan,DC=lab')"
    Write-Host ""
    Write-Host "Example Usage:"
    Write-Host "    .\AddUserToAD.ps1 -FName 'John' -LName 'Doe' -Desc 'HR Manager' -Pass 'HR#1Manager!'"
    Write-Host "    .\AddUserToAD.ps1 -ListDepartments"
    return
}

# Import Active Directory module if not already imported
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

# Retrieve departments with a 'Users' sub-OU under the specified DepartmentsOU
try {
    Write-Host "Searching for department-level 'Users' OUs under $DepartmentsOU..."

    # Find all 'Users' OUs that are exactly two levels deep under the DepartmentsOU
    $departmentOUs = Get-ADOrganizationalUnit -Filter * -SearchBase $DepartmentsOU |
        Where-Object {
            # Check if the OU's DistinguishedName matches the pattern for a department-level 'Users' sub-OU
            $_.DistinguishedName -match '^OU=Users,OU=.*,OU=organization,DC=titan,DC=lab$'
        } |
        Select-Object -ExpandProperty DistinguishedName

    # Extract the department name from each department OU
    $departments = $departmentOUs | ForEach-Object {
        ($_ -split ',')[1] -replace "^OU=", ""  # Extracts department names dynamically
    }
    
    if ($ListDepartments) {
        Write-Host "Available departments with a 'Users' sub-OU:"
        $departments | ForEach-Object { Write-Host "- $_" }
        return
    }
} catch {
    Write-Host "Error retrieving departments: $_"
    return
}

# Check for required parameters if creating a user
if (-not $FName -or -not $LName) {
    Write-Host "Error: -FName and -LName are required."
    return
}

# Validate the Department parameter if specified
if ($Department) {
    if ($departments -notcontains $Department) {
        Write-Host "Error: The specified department '$Department' is not recognized or lacks a 'Users' sub-OU."
        Write-Host "Available departments are: $($departments -join ', ')"
        return
    }
} else {
    # If no department specified, allow the user to pick from available options
    Write-Host "Please choose a department from the following list:"
    $departments | ForEach-Object { Write-Host "- $_" }
    $Department = Read-Host "Enter the department name"
    if ($departments -notcontains $Department) {
        Write-Host "Error: Invalid department selected."
        return
    }
}

# Construct username and email
$AtSign = "@"
$username = $FName.Substring(0, [Math]::Min($FName.Length, 1)) + $Delimiter + $LName
$email = "$username$AtSign$MailDomain"

# Define the new AD user properties
$user = @{
    Description = $Desc
    UserPrincipalName = "$username$AtSign$ADDomain"
    Name = "$LName $FName"
    SamAccountName = $username
    Surname = $LName
    GivenName = $FName
    EmailAddress = $email
    ChangePasswordAtLogon = $false
    CannotChangePassword = $true
    PasswordNeverExpires = $true
    AccountPassword = ConvertTo-SecureString $Pass -AsPlainText -Force
    Enabled = $true
    Department = $Department
}

# Define the OU path for the new user
$UserOUPath = "OU=Users,OU=$Department,$DepartmentsOU"

# Create the new Active Directory user with the determined OU path
try {
    New-ADUser @user -Path $UserOUPath
    Write-Host "User $username has been created successfully in OU: $UserOUPath"
} catch {
    Write-Host "Error creating user: $_"
}