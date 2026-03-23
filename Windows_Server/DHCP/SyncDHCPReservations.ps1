#Replicates the scope reservations between failover DHCP servers set up as load balance as reservations do not automatically sync by default.

[ipaddress]$Scope="192.168.50.0"
$Server1="server1"
$Server2="server2"

$DHCP01=Get-DhcpServerv4Reservation -ComputerName $Server1 -ScopeId $Scope
$DHCP02=Get-DhcpServerv4Reservation -ComputerName $Server2 -ScopeId $Scope

$01IP=$DHCP01.IPAddress
$02IP=$DHCP02.IPAddress

$Missingfrom02=$01IP | ? {$02IP -notcontains $_}
$Missingfrom01=$02IP | ? {$01IP -notcontains $_}

if($Missingfrom01 -and !$Missingfrom02){

Invoke-DhcpServerv4FailoverReplication -ComputerName $Server2 -ScopeId $Scope -Force}

if($Missingfrom02 -and !$Missingfrom01){

Invoke-DhcpServerv4FailoverReplication -ComputerName $Server1 -ScopeId $Scope -Force}

if($Missingfrom01 -and $Missingfrom02){

foreach($IP01 in $Missingfrom01){

$01RES=Get-DhcpServerv4Reservation -IPAddress $IP01 -ComputerName $Server2

$01RESIP=$01RES.IPAddress
$01RESCLIENT=$01RES.clientid
$01RESNAME=$01RES.name
$01RESTYPE=$01RES.type

Add-DhcpServerv4Reservation -ComputerName $Server1 -ScopeId $Scope -IPAddress $01RESIP -ClientId $01RESCLIENT -Name $01RESNAME -Type $01RESTYPE

}

foreach($IP02 in $Missingfrom02){

$02RES=Get-DhcpServerv4Reservation -IPAddress $IP02 -ComputerName $Server1

$02RESIP=$02RES.IPAddress
$02RESCLIENT=$02RES.clientid
$02RESNAME=$02RES.name
$02RESTYPE=$02RES.type

Add-DhcpServerv4Reservation -ComputerName $Server2 -ScopeId $Scope -IPAddress $02RESIP -ClientId $02RESCLIENT -Name $02RESNAME -Type $02RESTYPE

}
}