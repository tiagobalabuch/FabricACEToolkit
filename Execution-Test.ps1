
Import-Module Az.Account
Set-ExecutionPolicy Unrestricted 
Import-Module .\FabricACEToolkit -Force -DisableNameChecking
Get-Command -Module FabricACEToolkit 
Set-FabricHeaders -tenantId "2ca1a04f-621b-4a1f-bad6-7ecd3ae78e25"

$a = Get-Command -Module FabricACEToolkit 
$a.Count

Assign-FabricDomainWorkspaceByPrincipal -DomainId $domain.id -PrincipalIds $PrincipalIds -Debug

$apiEndpointUrl = "https://api.fabric.microsoft.com/v1/operations/d90fdb4a-2dbf-44f5-9239-85d7e83aa076/result"

$response = Invoke-RestMethod `
-Headers $FabricConfig.FabricHeaders `
-Uri $apiEndpointUrl `
-Method Get `
-ErrorAction Stop `
-SkipHttpErrorCheck `
-ResponseHeadersVariable "responseHeader" `
-StatusCodeVariable "statusCode"



#################################################################
# Capacity
Get-FabricCapacity -Debug 
Get-FabricCapacity -capacityId "6b3297a9-84d0-4f51-99ac-76dda2572ba4"
Get-FabricCapacity -capacityName "tiagocapacity"
###################################################################
# Dashboard
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricDashboard -WorkspaceId $workspace.id -Debug 
###################################################################
# Data Pipeline
## Get Data Pipeline
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricDataPipeline -WorkspaceId $workspace.id -Debug

## Add Data Pipeline
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricDataPipeline -WorkspaceId $workspace.id -DataPipelineName "DataPipeline1" -DataPipelineDescription "Data Pipeline Description" -Debug

## Update Data Pipeline
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$dataPipeline = Get-FabricDataPipeline -WorkspaceId $workspace.id -DataPipelineName "DataPipeline1"
Update-FabricDataPipeline -WorkspaceId $workspace.id -DataPipelineId $dataPipeline.id -DataPipelineName "DataPipeline1 Updated" -DataPipelineDescription "Data Pipeline Description Updated" -Debug

## Remove Data Pipeline
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$dataPipeline = Get-FabricDataPipeline -WorkspaceId $workspace.id -DataPipelineName "DataPipeline1 Updated"
Remove-FabricDataPipeline -WorkspaceId $workspace.id -DataPipelineId $dataPipeline.id -Debug

###################################################################
# Datamart
## Get Datamart
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricDatamart -WorkspaceId $workspace.id -Debug

###################################################################
# Domain
## Add Domain

New-FabricDomain -DomainName "API1" 
New-FabricDomain -DomainName "API2" -DomainDescription "API data domain"
New-FabricDomain -DomainName "API3" -DomainDescription "API data domain" -ParentDomainId "227cf69a-85df-4e55-9191-186a3de2c501"
New-FabricDomain -DomainName "API4" -ParentDomainId "227cf69a-85df-4e55-9191-186a3de2c501"

## Get Domain
Get-FabricDomain 
Get-FabricDomain -DomainId "227cf69a-85df-4e55-9191-186a3de2c501"
Get-FabricDomain -DomainName "API1"

## Update Domain
$domain = Get-FabricDomain -DomainName "API4"
Update-FabricDomain -DomainId $domain.id -DomainName "API Updated" -DomainDescription "API data domain updated"

## Remove Domain
$domain = Get-FabricDomain -DomainName "API Updated"
Remove-FabricDomain -DomainId $domain.id

# Assign domain workspace by Capacity
$capacity = Get-FabricCapacity 
$domain = Get-FabricDomain -DomainName "API3"
Assign-FabricDomainWorkspaceByCapacity -DomainId $domain.id -capacitiesIds $capacity.id -Debug

# Assign domain workspace by Id
$workspace = Get-FabricWorkspace
$workspace[0] = $null # Removing My Workspace
Assign-FabricDomainWorkspaceById -DomainId $domain.id -WorkspaceId $workspace.id -Debug

## Get Domain Workspace
$domain = Get-FabricDomain -DomainName "API3"
Get-FabricDomainWorkspace -DomainId $domain.id

## Remove Domain Workspace
$workspace = Get-FabricWorkspace
$workspace[0] = $null # Removing My Workspace
$domain = Get-FabricDomain -DomainName "API3"
Unassign-FabricDomainWorkspace -DomainId $domain.id -WorkspaceIds $workspace.id -Debug

## Assign domain workspace by Principal
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"; type = "User" },
    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User" })

$domain = Get-FabricDomain -DomainName "API1"
Assign-FabricDomainWorkspaceByPrincipal -DomainId $domain.id -PrincipalIds $PrincipalIds -Debug

## Assign domain workspace by Capacity
$domain = Get-FabricDomain -DomainName "API1"
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"; type = "User" },
    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User" })
Assign-FabricDomainWorkspaceRoleAssignment -DomainId $domain.id -DomainRole Contributors -PrincipalIds $PrincipalIds -Debug

## Unassign domain workspace by Principal
$domain = Get-FabricDomain -DomainName "API1"
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"; type = "User" },
    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User" })
Unassign-FabricDomainWorkspaceRoleAssignment -DomainId $domain.id -DomainRole Admins -PrincipalIds $PrincipalIds -Debug

###################################################################



# Workspace
## Get Workspace
Get-FabricWorkspace -Debug
Get-FabricWorkspace -WorkspaceName "Tiago API" -Debug
Get-FabricWorkspace -WorkspaceId "dda81258-3461-4135-b4db-71552064e50ac" # ID does not exist

## Add Workspace
New-FabricWorkspace -WorkspaceName "Tiago API" 
New-FabricWorkspace -WorkspaceName "Tiago API2" -WorkspaceDescription "API data workspace"
$capacity = Get-FabricCapacity -capacityName "tiagocapacity"
New-FabricWorkspace -WorkspaceName "Tiago API3" -WorkspaceDescription "API data workspace" -CapacityId $capacity.id

## Update Workspace
$workspace = New-FabricWorkspace -WorkspaceName "Tiago AP54" 
$workspace
Update-FabricWorkspace -WorkspaceId $workspace.id -WorkspaceName "Tiago API4 UPDATED" -WorkspaceDescription "Updated description"
#Remove-FabricWorkspace -WorkspaceId $workspace.id 

## Remove Workspace 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago AP54" 
##### Remove-FabricWorkspace -WorkspaceId $workspace.id 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API3"
###### Remove-FabricWorkspace -WorkspaceId $workspace.id 

## Workspace Assign Capacity
$capacity = Get-FabricCapacity -capacityName "tiagocapacity"
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Assign-FabricWorkspaceCapacity -WorkspaceId $workspace.id -CapacityId $capacity.id

## Workspace Unassign Capacity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Unassign-FabricWorkspaceCapacity -WorkspaceId $workspace.id 

## Provision Workspace Identity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricWorkspaceIdentity -WorkspaceId $workspace.id 

## Deprovision Workspace Identity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Remove-FabricWorkspaceIdentity -WorkspaceId $workspace.id 

## Get Workspace Role Assignments 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -Debug

## Workspace Add Role Assignments - Principal Id must be EntraID
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -PrincipalId "b5b9495c-685a-447a-b4d3-2d8e963e6288" -PrincipalType User -WorkspaceRole Admin

## Update Workspace Role Assignments 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id
Update-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -WorkspaceRoleAssignmentId "b5b9495c-685a-447a-b4d3-2d8e963e6288" -WorkspaceRole Contributor

## Remove Workspace Role Assignments 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id
Remove-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -WorkspaceRoleAssignmentId "b5b9495c-685a-447a-b4d3-2d8e963e6288"

###################################################################
# Environment

## Add Environment
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv01" -EnvironmentDescription "Development Environment"

## Get Environment 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricEnvironment -WorkspaceId $workspace.id -Debug
Get-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv01"  -Debug
Get-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId "0c06e50a-141e-4ecc-970c-121c6e07521c" -Debug

## Update Environment
$env = Get-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv" 
Update-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId $env.id -EnvironmentName "DevEnv Updated" -EnvironmentDescription "Development Environment Updated"

## Remove Environment
Remove-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId $env.id

## Get Spark Compute
Get-FabricEnvironmentSparkCompute -WorkspaceId $workspace.id -EnvironmentId $env.id

## Get Staging  Spark Compute
Get-FabricEnvironmentStagingSparkCompute -WorkspaceId $workspace.id -EnvironmentId $env.id

## Updated Staging Spark Compute
Update-FabricEnvironmentStagingSparkCompute -WorkspaceId $workspace.id -EnvironmentId $env.id -InstancePoolName "MySparkPool" -InstancePoolType "Workspace" -DriverCores 4 -DriverMemory "28g" -ExecutorCores 4 -ExecutorMemory "28g" -DynamicExecutorAllocationEnabled $true -DynamicExecutorAllocationMinExecutors 1 -DynamicExecutorAllocationMaxExecutors 1 -RuntimeVersion "1.3" -SparkProperties @{"spark.dynamicAllocation.executorAllocationRatio" = 1.1 }    

## Publish Environment
Publish-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId $env.id

## Stop Publish Environment
Stop-FabricEnvironmentPublish -WorkspaceId $workspace.id -EnvironmentId $env.id

## Get Environment Staging Library
Get-FabricEnvironmentStagingLibrary -WorkspaceId $workspace.id -EnvironmentId $env.id

## Get Environment Library
Get-FabricEnvironmentLibrary -WorkspaceId $workspace.id -EnvironmentId $env.id

## Upload Environment Staging Library
## This is not working
Upload-FabricEnvironmentStagingLibrary -WorkspaceId $workspace.id -EnvironmentId $env.id

## Remove Environment Staging Library
Remove-FabricEnvironmentStagingLibrary -WorkspaceId $workspace.id -EnvironmentId $env.id -LibraryName "datagenerator-0.1-py3-none-any.whl"

###################################################################
# Tenant Setting
## Get Tenant Setting
Get-FabricTenantSetting -Debug
Get-FabricTenantSetting  -SettingTitle "Users can create Fabric items" -Debug

###################################################################
# Domain
## Add Domain

New-FabricDomain -DomainName "API1" 
New-FabricDomain -DomainName "API2" -DomainDescription "API data domain"
New-FabricDomain -DomainName "API3" -DomainDescription "API data domain" -ParentDomainId "e2e8530e-bdad-468a-9634-7c5dd10ab703"
New-FabricDomain -DomainName "API4" -ParentDomainId "e2e8530e-bdad-468a-9634-7c5dd10ab703"

## Get Domain
Get-FabricDomain 
Get-FabricDomain -DomainId "5a785af7-0155-4d27-b944-36c33e6c69e4"
Get-FabricDomain -DomainName "API1"

## Update Domain
$domain = Get-FabricDomain -DomainName "API4"
Update-FabricDomain -DomainId $domain.id -DomainName "API Updated" -DomainDescription "API data domain updated"

## Remove Domain
$domain = Get-FabricDomain -DomainName "API Updated"
Remove-FabricDomain -DomainId $domain.id

## Get Domain Workspace
$domain = Get-FabricDomain -DomainName "API3"
Get-FabricDomainWorkspace -DomainId $domain.id

# Assign domain workspace by Capacity
$capacity = Get-FabricCapacity 
Assign-FabricDomainWorkspaceByCapacity -DomainId $domain.id -capacitiesIds $capacity.id

# Assign domain workspace by Id
$workspace = Get-FabricWorkspace
$workspace[0] = $null # Removing My Workspace
Assign-FabricDomainWorkspaceById -DomainId $domain.id -WorkspaceId $workspace.id

## Remove Domain Workspace
$workspace = Get-FabricWorkspace
$workspace[0] = $null # Removing My Workspace
$domain = Get-FabricDomain -DomainName "API1"
Unassign-FabricDomainWorkspace -DomainId $domain.id -WorkspaceIds $workspace.id

## Assign domain workspace by Principal
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"; type = "User" },
    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User" })

$domain = Get-FabricDomain -DomainName "API1"
Assign-FabricDomainWorkspaceByPrincipal -DomainId $domain.id -PrincipalIds $PrincipalIds

## Assign domain workspace by Capacity
$domain = Get-FabricDomain -DomainName "API1"
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"; type = "User" },
    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User" })
Assign-FabricDomainWorkspaceRoleAssignment -DomainId $domain.id -DomainRole Contributors -PrincipalIds $PrincipalIds -Debug

## Unassign domain workspace by Principal
$domain = Get-FabricDomain -DomainName "API1"
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"; type = "User" },
    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User" })
Unassign-FabricDomainWorkspaceRoleAssignment -DomainId $domain.id -DomainRole Admins -PrincipalIds $PrincipalIds -Debug

###################################################################
# Notebook
## Add Notebook 
### It must a ipynb file
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Generate888" -NotebookDescription "Notebook Description" -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" -NotebookPathPlatformDefinition "C:\temp\API\.platform" -Debug

 ## Get Notebook
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricNotebook -WorkspaceId $workspace.id -Debug
Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Generate Data" -Debug
Get-FabricNotebook -WorkspaceId $workspace.id -NotebookId "8a4d9a16-c972-4a0c-b905-e133a1c282fc" -Debug

## Get Notebook Definition
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$notebook = Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Notebook85"
Get-FabricNotebookDefinition -WorkspaceId $workspace.id -NotebookId $notebook.id

## Get Notebook Definition
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$notebook = Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Notebook1"
Update-FabricNotebookDefinition `
    -WorkspaceId $workspace.id `
    -NotebookId $notebook.id `
    -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" `
    -NotebookPathPlatformDefinition "C:\temp\API\.platform" `
    -UpdateMetadata $true `
    -Debug

## Remove Notebook
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API" 
$notebook = Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Notebook1"
Remove-FabricNotebook -WorkspaceId $workspace.id -NotebookId $notebook.id -Debug

### It must a ipynb file
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricNotebook -WorkspaceId $workspace.id `
    -NotebookName "Generate008" `
    -NotebookDescription "Notebook Description" `
    -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" `
    -NotebookPathPlatformDefinition "C:\temp\API\.platform" -Debug

Get-FabricNotebookDefinition -WorkspaceId $workspace.id -NotebookId "f9da8f99-36c4-4455-9251-91d86af10008"  -NotebookFormat "ipynb" -Debug   

## Update Notebook Definition
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$notebook = Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Notebook120"
Update-FabricNotebookDefinition -WorkspaceId $workspace.id -NotebookId $notebook.id -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" -NotebookPathPlatformDefinition "C:\temp\API\.platform" -Debug

###################################################################
# Eventhouse
## Get Eventhouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricEventhouse -WorkspaceId $workspace.id -debug
Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH01" -Debug
Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseId "66ba709c-6531-4658-b189-68c7639b1ad8" -Debug

## Add Eventhouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH01" -EventhouseDescription "EH Events" -Debug
New-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH05" -EventhouseDescription "EH Events" -Debug

## Update Eventhouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$eventhouse = Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH05"
Update-FabricEventhouse -WorkspaceId $workspace.id -EventhouseId $eventhouse.id -EventhouseName "EH05 Updated" -EventhouseDescription "EH Events Updated" -Debug

## Remove Eventhouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$eventhouse = Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH05 Updated"
Remove-FabricEventhouse -WorkspaceId $workspace.id -EventhouseId $eventhouse.id -Debug

## Get Eventhouse Definition
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$eventhouse = Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH01"
Get-FabricEventhouseDefinition -WorkspaceId $workspace.id -EventhouseId $eventhouse.id -Debug

###################################################################
# Eventstream
## Add Eventstream
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricEventstream -WorkspaceId $workspace.id -EventstreamName "ES01" -EventstreamDescription "ES Events" # -EventstreamPathDefinition "C:\temp\API\Generate Data.ipynb" -EventstreamPathPlatformDefinition "C:\temp\API\.platform" -Debug
New-FabricEventstream -WorkspaceId $workspace.id -EventstreamName "ES02" -EventstreamDescription "ES Events" # -EventstreamPathDefinition "C:\temp\API\Generate Data.ipynb" -EventstreamPathPlatformDefinition "C:\temp\API\.platform" -Debug

## Get Eventstream
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricEventstream -WorkspaceId $workspace.id
Get-FabricEventstream -WorkspaceId $workspace.id -EventstreamName "ES01"
Get-FabricEventstream -WorkspaceId $workspace.id -EventstreamId "31f22ab2-9244-4fac-88ac-25a6cf3ec5a8"

## Update Eventstream
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$eventstream = Get-FabricEventstream -WorkspaceId $workspace.id -EventstreamName "ES02"
Update-FabricEventstream -WorkspaceId $workspace.id -EventstreamId $eventstream.id -EventstreamName "ES02 Updated" -EventstreamDescription "ES Events Updated" -Debug

## Remove Eventstream
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$eventstream = Get-FabricEventstream -WorkspaceId $workspace.id -EventstreamName "ES02 Updated"
Remove-FabricEventstream -WorkspaceId $workspace.id -EventstreamId $eventstream.id -Debug



#Lakehouse
## Add Lakehouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
New-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH01" -LakehouseDescription "LH Data" -Debug
New-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH02" -LakehouseDescription "LH Data" -LakehouseEnableSchemas $true -Debug
New-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH03" -LakehouseDescription "LH Data" -Debug

## Get Lakehouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricLakehouse -WorkspaceId $workspace.id -Debug
Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH01" -Debug
Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseId "92b0be44-17ec-462f-bd84-41eaaad91edf" -Debug

$lakehouses = Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH02"
$lakehouses.properties.PSObject.Properties['defaultSchema']

if ($lakehouses.properties.PSObject.Properties['defaultSchema']) {
    Write-Host "The 'defaultSchema' property exists."
} else {
    Write-Host "The 'defaultSchema' property does not exist."
}


## Update Lakehouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$lakehouse = Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH03"
Update-FabricLakehouse -WorkspaceId $workspace.id -LakehouseId $lakehouse.id -LakehouseName "LH03Updated" -LakehouseDescription "LH Data Updated" -Debug

## remove Lakehouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$lakehouse = Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH03Updated"
Remove-FabricLakehouse -WorkspaceId $workspace.id -LakehouseId $lakehouse.id -Debug

## List Lakehouse tables
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$lakehouse = Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH01"
Get-FabricLakehouseTable -WorkspaceId $workspace.id -LakehouseId $lakehouse.id -Debug

## Load Lakehouse Table
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$lakehouse = Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH01"
$lakehouse = Get-FabricLakehouse -WorkspaceId $workspace.id -LakehouseName "LH01"
Load-FabricLakehouseTable -WorkspaceId $workspace.id -LakehouseId $lakehouse.id -TableName "Table04" -PathType File `
-RelativePath "Files/test.csv" -FileFormat CSV -Mode append -CsvDelimiter "," -CsvHeader $true -Recursive $false -Debug


# KQL Database
## Get KQL Database
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricKQLDatabase -WorkspaceId $workspace.id -Debug
Get-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseName "EH02" -Debug
Get-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseId "ea5c8259-389d-4d1d-b9d6-449e075fa315" -Debug

## add KQL Database
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$eventhouse = Get-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH01"
## Create a ReadWrite KQL database example
New-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseName "MyKQL2" -KQLDatabaseDescription "KQL Database Description" -KQLDatabaseType ReadWrite -parentEventhouseId $eventhouse.id -Debug

################### 
## need to test

#Create a Shortcut KQL database to source KQL database example
$KQLDatabaseName = "TiagoKQL"
$KQLDatabaseType = "Shortcut"
$parentEventhouseId = "0000000"
$KQLSourceDatabaseName = "SourceTiagoKQL"

# Create a Shortcut KQL database to source Azure Data Explorer cluster example
$KQLDatabaseName = "TiagoKQL"
$KQLDatabaseType = "Shortcut"
$parentEventhouseId = "0000000"
$KQLSourceDatabaseName = "SourceTiagoKQL"
$KQLSourceClusterUri = "https://tiagokql.westus.kusto.windows.net"


# Create a Shortcut KQL database to source Azure Data Explorer cluster with invitation token example
$KQLDatabaseName = "TiagoKQL"
$KQLDatabaseType = "Shortcut"
$parentEventhouseId = "0000000"
$KQLInvitationToken = "1234567890"
$KQLSourceDatabaseName = "SourceTiagoKQL"
$KQLSourceClusterUri = "https://tiagokql.westus.kusto.windows.net"
###################

## update KQL Database
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$kqlDatabase = Get-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseName "MyKQL2"
Update-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseId $kqlDatabase.id -KQLDatabaseName "MyKQL2 Updated" -KQLDatabaseDescription "KQL Database Description Updated" -Debug

## remove KQL Database
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$kqlDatabase = Get-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseName "MyKQL2 Updated"
Remove-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseId $kqlDatabase.id -Debug

## Get KQL Database Definition
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$kqlDatabase = Get-FabricKQLDatabase -WorkspaceId $workspace.id -KQLDatabaseName "MyKQL"
Get-FabricKQLDatabaseDefinition -WorkspaceId $workspace.id -KQLDatabaseId $kqlDatabase.id -Debug


Load-FabricLakehouseTable `
-WorkspaceId $workspace.id `
-LakehouseId $lakehouse.id `
-TableName "Table03" `
-PathType File `
-RelativePath "Files/test.parquet" `
-FileFormat Parquet `
-Mode append `
-Recursive $false `
-Debug

$apiEndpointUrl = "https://api.fabric.microsoft.com/v1/operations/27d158cc-23e9-4ea1-b646-a3aaf274ece1/result"
Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Get `
            -ErrorAction Stop `
            -ResponseHeadersVariable responseHeader `
            -StatusCodeVariable statusCode