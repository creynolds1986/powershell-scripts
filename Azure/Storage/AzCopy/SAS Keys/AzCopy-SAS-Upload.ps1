# https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-blobs-upload
# Fill out the variables and then un-comment each line as required.

$storageAccountName = "<storage-account-name>"
$containerName      = "<container-name>"
$SASToken           = Read-Host "Enter the SAS token (without the leading '?')"
$LocalDirectory     = "d:\azcopytest"

### Create a blob container ###

# azcopy make "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken"

### Upload a single file ###

# $Filename = "Test.txt"
# azcopy copy "$LocalDirectory\$Filename" "https://$storageAccountName.blob.core.windows.net/$containerName/$Filename`?$SASToken"

### Upload multiple files using a wildcard ###

# azcopy copy "$LocalDirectory\*.*" "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken"

### Upload a directory ###

# azcopy copy "$LocalDirectory\new folder" "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken" --recursive

### Upload the contents of a directory (without the folder itself) ###

# azcopy copy "$LocalDirectory\new folder\*" "https://$storageAccountName.blob.core.windows.net/$containerName`?$SASToken" --recursive
