# https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10

$storageAccountName = "<storage-account-name>"
$containerName      = "<container-name>"
$SASToken           = Read-Host "Enter the SAS token (without the leading '?')"

# Create a blob container
azcopy make "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken"

# Upload a single file
$Filename = "test.txt"
azcopy copy "C:\temp\$Filename" "https://$storageAccountName.blob.core.windows.net/$containerName/$Filename`?$SASToken"

# Upload multiple files using a wildcard
azcopy copy "C:\temp\*.txt" "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken"

# Upload a directory
azcopy copy "C:\temp\myfolder" "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken" --recursive

# Upload the contents of a directory (without the folder itself)
azcopy copy "C:\temp\myfolder\*" "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken" --recursive
