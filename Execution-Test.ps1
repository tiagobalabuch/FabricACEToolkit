Import-Module .\FabricACEToolkit

Get-Command -Module FabricACEToolkit

Set-FabricHeaders -tenantId "2ca1a04f-621b-4a1f-bad6-7ecd3ae78e25"

Get-FabricCapacity 
Get-FabricCapacity -capacityId "6b3297a9-84d0-4f51-99ac-76dda2572ba9"
Get-FabricCapacity -capacityName "tiagocapacity"


Get-FabricWorkspace
Get-FabricWorkspace -WorkspaceId "dda81258-3461-4135-b4db-71552064e50ac"
Get-FabricWorkspace -WorkspaceName "tiagoworkspace2s"

Add-FabricWorkspace -WorkspaceName "tiagoworkspace1"
Remove-FabricWorkspace -WorkspaceId "dda81258-3461-4135-b4db-71552064e50c"
