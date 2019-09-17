param([string]$accountname = 'Test User',
      [string]$password = "dynW9p@&",
      [int32]$varonisusers = 20
)




#install Azure Module 
Install-Module -Name Az -AllowClobber


<#
.SYNOPSIS
    Creates 20 Azure Active Directory User accounts with the name of “Test User &lt;Counter&gt;”.
     Creates an Azure Active Directory Security group with the name of “Varonis Assignment2
        Group”.
     Adds each of the user accounts created in the previous step to the “Varonis Assignment2
    Group”, the accounts should be added separately, and not as a bulk.
    All the users must be added successfully at the end of the script execution and errors should
    be handled efficiently.
     The script should generate a customized log that includes the following details for each attempt
    to add the user account to the security group:
    o User Name
    o Timestep of the attempt to add the user to the group.
    o Result of the attempt (success\failure)
     The last step of the script should create an Azure Storage Account container and upload the log
    created in the previous step as a blob to this container via AzCopy.
     Provide a secured URL to access the log file blob.
.PARAMETER varonisusers
    Number of Varonis user accounts to create. The default is 20
.NOTES
    File Name: varonistest.ps1
    Author   : Dave Otteman
    Date     : 9/12/19
    Version  : .90
#>



#define variables
#create secure-string for password
$SecureStringPassword = ConvertTo-SecureString -String $password -AsPlainText -Force




#create password connection

#connect to Azure
$credential = Get-Credential
Connect-AzAccount -Credential $credential


#create Azure AD accounts(default 20)
#loop until value of varonisusers count has been reached

for ($i=1; $i -le $varonisusers; $i++)
{
    #loop variables
    $displayname = $accountname + $i
    $mailnickname = $displayname.Replace(' ','')
    $upn = $mailnickname + "@daveottemangmail.onmicrosoft.com"

    New-AzADUser -DisplayName $displayname -UserPrincipalName $upn -Password $SecureStringPassword -MailNickname $mailnickname

}

#create Azure AD group
$VaronisGroup = New-AzADGroup -DisplayName "Varonis Assignment2 Group" -MailNickname "VaronisAssignment2Group"


#loop and add each new Varonis Azure AD test user to test Azure AD group
for ($i=1; $i -le $varonisusers; $i++)
{

#loop variables
$memberUpn = (($accountname + $i).Replace(' ','') + "@daveottemangmail.onmicrosoft.com")
$targetgroupdisplayname = "Varonis Assignment2 Group"

Add-AzADGroupMember -MemberUserPrincipalName $memberUpn -TargetGroupDisplayName $targetgroupdisplayname
}

