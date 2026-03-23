#Finds all users that have the old home share and replaces with the new one.

$oldpath = "\\oldserver\share"
$newpath = "\\newserver\share"
$users = Get-ADUser -Filter * -Properties homedirectory | Where-Object { $_.homedirectory -like "$oldpath*" }

foreach ($user in $users)
{
    $sam = $user.samaccountname
    try
    {
        Set-ADUser -Identity $sam -HomeDirectory "$newpath\$sam"
    }
    catch
    {
        Write-Warning "Failed to update $sam : $_"
    }
}