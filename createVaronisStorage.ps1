
# sign-in to Azure
Connect-AzAccount

#set location variable
$location = "westus"

#create resource group
$resourcegroup = "VaronisCodeTest"
New-AzResourceGroup -Name $resourcegroup -Location $location

#create storage account
$storageaccount = New-AzStorageAccount -ResourceGroupName $resourcegroup -Name "varonisstorageaccount" -SkuName Standard_LRS -Location $location 

$storageaccountcontext = $storageaccount.Context

#create container
$containername = "logfileblobs"
New-AzStorageContainer -Name $containername -Context $storageaccountcontext -Permission Blob





