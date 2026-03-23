#Exports the DHCP settings from the old server, copies them to the new one, then disables DHCP on the old server.

#DHCP source server that you're migrating from
$DHCPSource="oldserver"
#DHCP destination server that you're migrating to
$DHCPDest="newserver"
#File location of the export file
$Filepath="C:\DHCPExport.xml"

#Authorises the new server if it hasn't been already
Add-DhcpServerInDC -DnsName $DHCPDest

Export-DhcpServer -ComputerName $DHCPSource -File $Filepath -Force
Import-DhcpServer -File $Filepath -BackupPath C:\DHCPBackup -Force

Invoke-Command -ComputerName $DHCPSource -ScriptBlock {Stop-Service DHCPServer -Force
                                                       Set-Service DHCPServer -StartupType Disabled}