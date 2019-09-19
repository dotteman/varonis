param([string]$accountname = 'Test User',
      [string]$password = "dynW9p@&",
      [int32]$varonisusers = 20
)


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


#variables 

#resource group
$resourcegroup = "VaronisCodeTest"

#storage account
$storageaccount = get-AzStorageAccount -ResourceGroupName $resourcegroup

#storage account context
$storageaccountcontext = $storageaccount.Context

#container
$containername = "logfileblobs"

#create secure-string for password
$SecureStringPassword = ConvertTo-SecureString -String $password -AsPlainText -Force

#tenant domain name
$tenantdomain = "@daveottemangmail.onmicrosoft.com"

#install Azure Module 
Install-Module -Name Az -AllowClobber


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
    $upn = $mailnickname + $tenantdomain

    try{
        New-AzADUser -DisplayName $displayname -UserPrincipalName $upn -Password $SecureStringPassword -MailNickname $mailnickname -ErrorAction Stop
    }
    catch{
        Write-Warning "The user $displayname was not created"
    }
}

#create Azure AD group if it does not exist
if (!(Get-AzADGroup -DisplayName "Varonis Assignment2 Group")){  

    $varonisGroup = New-AzADGroup -DisplayName "Varonis Assignment2 Group" -MailNickname "VaronisAssignment2Group"
}else {
       Write-Host ($varonisGroup).DisplayName" already exists!"
}

#create logfile
$logfile =  new-item c:\temp\logfile.txt -Force


#loop and add each new Varonis Azure AD test user to test Azure AD group
for ($i=1; $i -le $varonisusers; $i++)
{

    #loop variables
    $memberUpn = (($accountname + $i).Replace(' ','') + $tenantdomain)
    $targetgroupdisplayname = "Varonis Assignment2 Group"

    #add user to security group
    try{
        Add-AzADGroupMember -MemberUserPrincipalName $memberUpn -TargetGroupDisplayName $targetgroupdisplayname -ErrorAction Stop 
        $result= "success"   
    }
    catch{
        $result = "failure"
    }
    Finally{
        Get-Date   | Out-File $logfile -Append
        $memberupn | Out-File $logfile -Append
        $result    | Out-File $logfile -Append
    }
}   

#assuming that the storage account and resource group have already been created

#check if container created, if not create one 
if (!(Get-AzStorageContainer -Name $containername -Context $storageaccountcontext -ErrorAction SilentlyContinue)) {
        Write-Host "creating container $containername"
        New-AzStorageContainer -Name $containername -Context $storageaccountcontext -Permission Blob
}Else { Write-Host "Container $containername already created"
}


#azcopy copy $logfile  https://varonisstorageaccount.blob.core.windows.net/logfileblobs

write-host "uploading $logfile up to Azure container"

.\azcopy copy $logfile "https://varonisstorageaccount.blob.core.windows.net/logfileblobs?sv=2019-02-02&sr=c&sig=ch30waRMOQTBvC6tmFL0medLgpUe3gLgLZmR%2BPgo%2FNQ%3D&st=2019-09-19T21%3A48%3A19Z&se=2019-10-03T21%3A48%3A19Z&sp=rwdl"


### סיימתי !!!! ####