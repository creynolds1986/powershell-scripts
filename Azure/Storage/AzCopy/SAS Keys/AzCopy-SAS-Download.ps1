# https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-blobs-download

$storageAccountName = "<storage-account-name>"
$containerName      = "<container-name>"
$SASToken           = Read-Host "Enter the SAS token (without the leading '?')"
$LocalDirectory     = "d:\azcopytest"

# Create a blob container
azcopy make "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken"

# Download a single file
$Filename = "Test.txt"
azcopy copy "https://$storageAccountName.blob.core.windows.net/$containerName/$Filename`?$SASToken" "$LocalDirectory\$Filename"

# Download multiple files using a wildcard
azcopy copy "https://$storageAccountName.blob.core.windows.net/$containerName/*`?$SASToken" "$LocalDirectory"

# Download a directory
azcopy copy "https://$storageAccountName.blob.core.windows.net/$containerName/new folder`?$SASToken" "$LocalDirectory" --recursive

# Download the contents of a directory (without the folder itself)
azcopy copy "https://$storageAccountName.blob.core.windows.net/$containerName/new folder/*`?$SASToken" "$LocalDirectory" --recursive