
Import-Module Az.Account
Set-ExecutionPolicy Unrestricted 
Import-Module .\FabricACEToolkit -Force -DisableNameChecking
Get-Command -Module FabricACEToolkit 
Set-FabricHeaders -tenantId "2ca1a04f-621b-4a1f-bad6-7ecd3ae78e25"

#$a = Get-Command -Module FabricACEToolkit 
#$a.Count

# Capacity
Get-FabricCapacity 
Get-FabricCapacity -capacityId "6b3297a9-84d0-4f51-99ac-76dda2572ba4"
Get-FabricCapacity -capacityName "tiagocapacity"
Add-FabricWorkspace -WorkspaceName "Tiago API"

# Get Workspace
Get-FabricWorkspace
Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspace -WorkspaceId "dda81258-3461-4135-b4db-71552064e50ac" # ID does not exist

# Add Workspace
Add-FabricWorkspace -WorkspaceName "Tiago API" 
Add-FabricWorkspace -WorkspaceName "Tiago API2" -WorkspaceDescription "API data workspace"
$capacity = Get-FabricCapacity -capacityName "tiagocapacity"
Add-FabricWorkspace -WorkspaceName "Tiago API3" -WorkspaceDescription "API data workspace" -CapacityId $capacity.id

# Update Workspace
$workspace = Add-FabricWorkspace -WorkspaceName "Tiago AP54" 
$workspace
Update-FabricWorkspace -WorkspaceId $workspace.id -WorkspaceName "Tiago API4 UPDATED" -WorkspaceDescription "Updated description"
#Remove-FabricWorkspace -WorkspaceId $workspace.id 

# Remove Workspace 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago AP54" 
$workspace
#####
Remove-FabricWorkspace -WorkspaceId $workspace.id 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API3"
######Remove-FabricWorkspace -WorkspaceId $workspace.id 

# Workspace Assing Capacity
$capacity = Get-FabricCapacity -capacityName "tiagocapacity"
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Assign-FabricWorkspaceCapacity -WorkspaceId $workspace.id -CapacityId $capacity.id

# Workspace Unassing Capacity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Unassign-FabricWorkspaceCapacity -WorkspaceId $workspace.id 

# Provision Workspace Identity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricWorkspaceIdentity -WorkspaceId $workspace.id 

# Deprovision Workspace Identity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Remove-FabricWorkspaceIdentity -WorkspaceId $workspace.id 

# Get Workspace Role Assignments 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id

# Workspace Add Role Assignments - Principal Id must be EntraID
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -PrincipalId "b5b9495c-685a-447a-b4d3-2d8e963e6288" -PrincipalType User -WorkspaceRole Admin

# Update Workspace Role Assignments 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id
Update-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -WorkspaceRoleAssignmentId "b5b9495c-685a-447a-b4d3-2d8e963e6288" -WorkspaceRole Contributor

# Remove Workspace Role Assignments 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id
Remove-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -WorkspaceRoleAssignmentId "b5b9495c-685a-447a-b4d3-2d8e963e6288"

# Environment

## Add Environment
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv01" -EnvironmentDescription "Development Environment"

## Get Environment 
Get-FabricEnvironment -WorkspaceId $workspace.id
Get-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv" 
Get-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId "0c06e50a-141e-4ecc-970c-121c6e07521c"

## Update Environment
$env = Get-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv" 
Update-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId $env.id -EnvironmentName "DevEnv Updated" -EnvironmentDescription "Development Environment Updated"

## Remove Environment
#Remove-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentId $env.id

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

# Eventhouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH01" -EventhouseDescription "EH Events"

# Get Tenant Setting
Get-FabricTenantSetting 
Get-FabricTenantSetting  -SettingTitle "Users can create Fabric items"



# Remove-FabricWorkspace -WorkspaceId $workspace.id

$workspace = Get-FabricWorkspace -WorkspaceName "Learning" 
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -WorkspaceRoleAssignmentId "31fb536a-c93b-4e3c-a8b7-591991da005d"  | Format-Table

## Add role assignment - Principal Id must be EntraID
$workspace = Get-FabricWorkspace -WorkspaceName "tiagoworkspace1" 
Get-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id
Add-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -PrincipalId "b5b9495c-685a-447a-b4d3-2d8e963e6288" -PrincipalType User -WorkspaceRole "Admin"
Update-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -workspaceRoleAssignmentId "b5b9495c-685a-447a-b4d3-2d8e963e6288" -WorkspaceRole Viewer
Remove-FabricWorkspaceRoleAssignment -WorkspaceId $workspace.id -WorkspaceRoleAssignmentId "b5b9495c-685a-447a-b4d3-2d8e963e6288"


# Set Workspace Capacity

$capacity = Get-FabricCapacity -capacityName "tiagocapacity"
#$workspace = Add-FabricWorkspace -WorkspaceName "Tiago API 152"
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API 152"
Set-FabricWorkspaceCapacity -WorkspaceId $workspace.id -CapacityId $capacity.id
Remove-FabricWorkspaceCapacity -WorkspaceId $workspace.id

# Provision Workspace Identity
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API 152"
Add-FabricWorkspaceIdentity -WorkspaceId $workspace.id
Remove-FabricWorkspaceIdentity -WorkspaceId $workspace.id

# Domain

## Add Domain

Add-FabricDomain -DomainName "API1" 
Add-FabricDomain -DomainName "API2" -DomainDescription "API data domain"
Add-FabricDomain -DomainName "API3" -DomainDescription "API data domain" -ParentDomainId "e2e8530e-bdad-468a-9634-7c5dd10ab703"
Add-FabricDomain -DomainName "API4" -ParentDomainId "e2e8530e-bdad-468a-9634-7c5dd10ab703"

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


# Notebook
## Add Notebook 
### It must a ipynb file
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Generate888" -NotebookDescription "Notebook Description" -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" -NotebookPathPlatformDefinition "C:\temp\API\.platform" -Debug

 ## Get Notebook
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Get-FabricNotebook -WorkspaceId $workspace.id
Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Generate Data"
Get-FabricNotebook -WorkspaceId $workspace.id -NotebookId "cbc46986-44a3-45f7-aac5-729885c50864"

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
Add-FabricNotebook -WorkspaceId $workspace.id `
    -NotebookName "Generate008" `
    -NotebookDescription "Notebook Description" `
    -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" `
    -NotebookPathPlatformDefinition "C:\temp\API\.platform" -Debug

Get-FabricNotebookDefinition -WorkspaceId $workspace.id -NotebookId "f9da8f99-36c4-4455-9251-91d86af10008"  -NotebookFormat "ipynb" -Debug   

$a.definition.parts
## Get Notebook Definition
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
$notebook = Get-FabricNotebook -WorkspaceId $workspace.id -NotebookName "Notebook120"
Update-FabricNotebookDefinition -WorkspaceId $workspace.id -NotebookId $notebook.id -NotebookPathDefinition "C:\temp\API\Generate Data.ipynb" -NotebookPathPlatformDefinition "C:\temp\API\.platform" -Debug


"https://api.fabric.microsoft.com/v1/workspaces/26cbd4ed-5920-4f2b-94ab-8e6ffbbdc48d/notebooks/f9da8f99-36c4-4455-9251-91d86af10008/getDefinition?format=ipynb"


$object = $a.definition.parts
$object 
foreach ($item in $object ) {
    $path = $item.path
    $payload = $item.payload  # Replace with actual property name

    Write-Host "Path: $path"
    Write-Host "Payload: $payload"

    Decode-FromBase64 -Base64String $payload
   <# if ($path -eq "notebook-content.py") {

        $fileDefinition = Decode-FromBase64 -Base64String $payload

        $FileFormat = "ipynb"
        $FileName = "Generate Data"

        # Determine the default Windows path
        $defaultPath = [Environment]::GetFolderPath("MyDocuments")

        # Construct the full file path
        $filePath = Join-Path -Path $defaultPath -ChildPath ("{0}.{1}" -f $FileName, $FileFormat)

        # Convert FileDefinition to string if necessary
        $fileContent = $FileDefinition -as [string]

        # Create the file and write content
        try {
            Set-Content -Path $filePath -Value $fileContent -Force
            Write-Host "File saved successfully to: $filePath"
        }
        catch {
            Write-Warning "Error saving file: $($_.Exception.Message)"
        }
    #>
}
  
#    Decode-FromBase64 -Base64String $payload

    Write-Host "---"
}

$FileDefinition = $defJson  
$FileFormat = "ipynb"
$FileName = "Generate Data"
# Determine the default Windows path
$defaultPath = [Environment]::GetFolderPath("MyDocuments")

# Construct the full file path
$filePath = Join-Path -Path $defaultPath -ChildPath ("{0}.{1}" -f $FileName, $FileFormat)

# Convert FileDefinition to string if necessary
$fileContent = $FileDefinition -as [string]

# Create the file and write content
try {
    Set-Content -Path $filePath -Value $fileContent -Force
    Write-Host "File saved successfully to: $filePath"
}
catch {
    Write-Warning "Error saving file: $($_.Exception.Message)"
}
}

$responseHeader["x-ms-operation-id"]

$responseHeader 
$statusCode
$header = @{
    
    'Authorization' = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InoxcnNZSEhKOS04bWdndDRIc1p1OEJLa0JQdyIsImtpZCI6InoxcnNZSEhKOS04bWdndDRIc1p1OEJLa0JQdyJ9.eyJhdWQiOiJodHRwczovL2FwaS5mYWJyaWMubWljcm9zb2Z0LmNvbSIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzJjYTFhMDRmLTYyMWItNGExZi1iYWQ2LTdlY2QzYWU3OGUyNS8iLCJpYXQiOjE3MzQ5NzUxNzgsIm5iZiI6MTczNDk3NTE3OCwiZXhwIjoxNzM0OTgwNDA2LCJhY2N0IjowLCJhY3IiOiIxIiwiYWlvIjoiQVZRQXEvOFlBQUFBWUFvWFRlb1RpSUEyNkhKaDJreXRiY3R3RVZUTnhXVTcyNmVlcVlieTQ0clhMd0VkU0xkQ3ZzR1J1cFRjMEEza0U3TUFVRVV6U1Y5dENzSDRmRjYzRVBYM2t2MTB4eFdJQy90VElnblJwYWs9IiwiYW1yIjpbInB3ZCIsInJzYSIsIm1mYSJdLCJhcHBpZCI6IjE5NTBhMjU4LTIyN2ItNGUzMS1hOWNmLTcxNzQ5NTk0NWZjMiIsImFwcGlkYWNyIjoiMCIsImRldmljZWlkIjoiMDY3NTQ0ODYtNGFkNS00NmRiLTg2NzgtN2IyZTI2YWQ4YzEwIiwiZmFtaWx5X25hbWUiOiJCYWxhYnVjaCIsImdpdmVuX25hbWUiOiJUaWFnbyIsImlkdHlwIjoidXNlciIsImlwYWRkciI6Ijg1LjI0Mi4yMjkuNjMiLCJuYW1lIjoiVGlhZ28gQmFsYWJ1Y2giLCJvaWQiOiI4MTNhYmI0YS00MTRjLTRhYzAtOWMyYy1iZDE3MDM2ZmQ1OGMiLCJwdWlkIjoiMTAwMzIwMDNBM0U1M0NGNiIsInB3ZF91cmwiOiJodHRwczovL3BvcnRhbC5taWNyb3NvZnRvbmxpbmUuY29tL0NoYW5nZVBhc3N3b3JkLmFzcHgiLCJyaCI6IjEuQWIwQVQ2Q2hMQnRpSDBxNjFuN05PdWVPSlFrQUFBQUFBQUFBd0FBQUFBQUFBQUFEQVh1OUFBLiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInNpZ25pbl9zdGF0ZSI6WyJrbXNpIl0sInN1YiI6ImlDemxaYWNCUkZqV0dQaUR5NEItVlM3Smx6dUg1aXJjSUZ4alhycE5mOWsiLCJ0aWQiOiIyY2ExYTA0Zi02MjFiLTRhMWYtYmFkNi03ZWNkM2FlNzhlMjUiLCJ1bmlxdWVfbmFtZSI6InRpYWdvLmJhbGFidWNoQE0zNjV4NjI2ODUzNDIub25taWNyb3NvZnQuY29tIiwidXBuIjoidGlhZ28uYmFsYWJ1Y2hATTM2NXg2MjY4NTM0Mi5vbm1pY3Jvc29mdC5jb20iLCJ1dGkiOiJTVXdlZWJxY0trS2lHNFl2WWZpZEFBIiwidmVyIjoiMS4wIiwid2lkcyI6WyI2MmU5MDM5NC02OWY1LTQyMzctOTE5MC0wMTIxNzcxNDVlMTAiLCJhOWVhODk5Ni0xMjJmLTRjNzQtOTUyMC04ZWRjZDE5MjgyNmMiLCJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwieG1zX2NjIjpbIkNQMSJdLCJ4bXNfaWRyZWwiOiIxIDQifQ.XtmZb7EVKPsZfehnay1hZZl1saDx6Wb4--P19_jbozxI3TWr_6lZSiSV33u6rAOM_aHGvSWmk65vt45uIxacfxSg-MLBa45o52l2dIo7t6c6aLOYnWuVT-x4tDPrt_4NPPhyOo51WWlpCPcf0E0sCTnEVcCMg5vcUWw3htuFMyOavZcrqVZb03qT_HMet1CqlLO_vycbKRD2iMudLmwcDqNKGwKt6TJFTypMdho59_bHthYf6WdI2g86S_oEG03pR7-p0lcpgGM8RRWpUPBht3EY4tmfH-WWnAOZ36ZGJk6kOFouOBJpJyCcZADMKUy69JJGwxdsYMulJa42Qmg-hA"
}
https://api.fabric.microsoft.com/v1/operations/16bcaa8f-c2e7-4cc9-b51e-5a1138ada56f
$apiEndpointUrl = "https://api.fabric.microsoft.com/v1/operations/16bcaa8f-c2e7-4cc9-b51e-5a1138ada56f"
$response = Invoke-RestMethod `
                -Headers $FabricConfig.FabricHeaders `
                -Uri $apiEndpointUrl `
                -Method Get `
                -ErrorAction Stop `
                -ResponseHeadersVariable responseHeader `
                -StatusCodeVariable statusCode