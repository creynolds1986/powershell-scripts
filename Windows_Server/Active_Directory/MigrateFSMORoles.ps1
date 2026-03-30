#Enter the name of the server that the roles should be moved to. It moves all the roles by default.
$Server="<new server>"

#Roles and numbers
#PDCEmulator or 0
#RIDMaster or 1
#InfrastructureMaster or 2
#SchemaMaster or 3
#DomainNamingMaster or 4

Move-ADDirectoryServerOperationMasterRole $Server -OperationMasterRole 0,1,2,3,4 -Confirm:$false