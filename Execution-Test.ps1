Import-Module .\FabricACEToolkit
#remove-module FabricACEToolkit

Get-Command -Module FabricACEToolkit

Set-FabricHeaders -tenantId "2ca1a04f-621b-4a1f-bad6-7ecd3ae78e25"
Get-FabricCapacityList