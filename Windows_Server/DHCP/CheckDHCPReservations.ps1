#Checks for differences in reservations on failover load balanced servers, which do not automatically replicate reservations.

[ipaddress]$Scope="192.168.1.0"
$Server1="server1"
$Server2="server2"

$DHCP01=Get-DhcpServerv4Reservation -ComputerName $Server1 -ScopeId $Scope
$DHCP02=Get-DhcpServerv4Reservation -ComputerName $Server2 -ScopeId $Scope

$01IP=$DHCP01.IPAddress
$02IP=$DHCP02.IPAddress

$Missingfrom02=$01IP | ? {$02IP -notcontains $_}

$Missingfrom01=$02IP | ? {$01IP -notcontains $_}

if($Missingfrom01){

"Missing from $Server1"

$Missingfrom01.ipaddresstostring}

if($Missingfrom02){

"Missing from $Server2"

$Missingfrom02.ipaddresstostring}

if(!$Missingfrom01 -and !$Missingfrom02){

"Reservations are synced"}