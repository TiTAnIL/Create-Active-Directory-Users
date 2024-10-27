Active Directory User Creation Scripts

This repository includes two PowerShell scripts designed to automate the process of creating Active Directory (AD) users. The scripts allow you to create individual AD users with customizable parameters or generate multiple random users with randomly selected first and last names.
Scripts Overview

    AddUserToAD.ps1 - Creates a single AD user with specified parameters such as First Name, Last Name, Password, and Domain.
    CreateRandomADUser.ps1 - Generates a specified number of random AD users using a predefined list of names and calls AddUserToAD.ps1 for each user.

Prerequisites

    Active Directory Module: Ensure that the Active Directory module for Windows PowerShell is installed and imported.
    Permissions: You must have permission to create users in your AD environment.

Script Usage
1. AddUserToAD.ps1

This script creates a single user in Active Directory with a specified first and last name, and additional optional parameters.
Parameters

    -FName (Required): First name of the user.
    -LName (Required): Last name of the user.
    -Desc (Optional): Description of the user. Default is "New User."
    -Delimiter (Optional): Delimiter used between the first and last name in the UserPrincipalName. Default is ..
    -Pass (Optional): Initial password for the user account. Default is P@ssWord123.
    -ADDomain (Optional): The domain for the user's UserPrincipalName. Default is titan.lab.
    -MailDomain (Optional): Mail domain for the user's email address. Default is titan.com.

Example Usage

powershell

.\AddUserToAD.ps1 -FName "John" -LName "Doe" -Desc "HR Manager" -Pass "HR#1Manager!"

Help

Run the script with the -Help switch to display parameter information:

powershell

.\AddUserToAD.ps1 -Help

2. CreateRandomADUser.ps1

This script generates multiple AD users with random names, utilizing AddUserToAD.ps1. By default, it will generate 10 users.
Parameters

    -Names (Optional): The number of random users to create. Default is 10.

Example Usage

powershell

.\CreateRandomADUser.ps1 -Names 15

This command will generate 15 random users.
Notes

    The user creation script will use a pre-defined list of first and last names for generating users.
    The script defaults to placing new users in the pre-configured Organizational Unit (OU) for new users. To modify this, you may edit the path directly in the script if required.
