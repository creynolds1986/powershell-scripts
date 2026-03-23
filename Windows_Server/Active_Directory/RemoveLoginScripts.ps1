#Finds all users with a login script and removes it.

$users=Get-ADUser -Filter * -Properties scriptpath | Where-Object scriptpath

foreach ($user in $users)
{

$sam=$user.samaccountname

    Set-ADUser -Identity $sam -Clear scriptpath
}