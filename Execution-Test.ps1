
Import-Module Az.Account
Set-ExecutionPolicy Unrestricted 
Import-Module .\FabricACEToolkit -Force -DisableNameChecking
Get-Command -Module FabricACEToolkit 
Set-FabricHeaders -tenantId "2ca1a04f-621b-4a1f-bad6-7ecd3ae78e25"

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
$workspace = Add-FabricWorkspace -WorkspaceName "Tiago AP4" 
Update-FabricWorkspace -WorkspaceId $workspace.id -WorkspaceName "Tiago API4 UPDATED" -WorkspaceDescription "Updated description"
#Remove-FabricWorkspace -WorkspaceId $workspace.id 

# Remove Workspace 
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API2"
#####Remove-FabricWorkspace -WorkspaceId #$workspace.id 
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
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricEnvironment -WorkspaceId $workspace.id -EnvironmentName "DevEnv7" -EnvironmentDescription "Development Environment"


# Eventhouse
$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API"
Add-FabricEventhouse -WorkspaceId $workspace.id -EventhouseName "EH01" -EventhouseDescription "EH Events"



Get-FabricTenantSetting -SettingTitle "Users can create Fabric items"

Get-FabricWorkspace





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

# domain
Get-FabricDomain | Format-Table
$domain = Add-FabricDomain -DomainName "API" -DomainDescription "API data domain"
Update-FabricDomain -DomainId $domain.id -DomainName "API Updated" -DomainDescription "API data domain updated"
$domain = Get-FabricDomain -DomainName "API Updated"


Get-FabricDomainWorkspace -DomainId $domain.id

Remove-FabricDomain -DomainId $domain.id
#subdomain
$domain = Get-FabricDomain -DomainName "parent1"
Add-FabricDomain -DomainName "API SubDomain" -DomainDescription "API sub domain" -ParentDomainId $domain.id


# Assign domain workspace by Capacity
$capacity = Get-FabricCapacity 
Add-FabricDomainWorkspaceByCapacity -DomainId $domain.id -capacitiesIds $capacity.id

# Assign domain workspace by Id
$workspace = Get-FabricWorkspace
$workspace | Format-Table
Add-FabricDomainWorkspaceById -DomainId $domain.id -WorkspaceId $workspace.id
$body ='{
    "role": "Admin",
    "principal": {
      "type": "User",
      "id": "b5b9495c-685a-447a-b4d3-2d8e963e6288"
    }
  }'

  $body = @{
    principal =  @{
        id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"
        type = "User"
    }
    role = "Admin"
}


  $bodyJson = $body | ConvertTo-Json -Depth 2
$a =Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri "https://api.fabric.microsoft.com/v1/workspaces/26cbd4ed-5920-4f2b-94ab-8e6ffbbdc48d/roleAssignments" -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
$statusCode
$a

$A = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri "https://api.fabric.microsoft.com/v1/workspaces/915d192f-4118-4d83-bc06-781527eb42f2/roleAssignments" -Method Get -ErrorAction Stop

#GET
Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri https://api.fabric.microsoft.com/v1/admin/domains/fda27838-f479-403a-9430-75f51e0aad77/workspaces -Method Get -ErrorAction Stop
https://api.fabric.microsoft.com/v1/admin/domains

$WorkspaceIds = @( 
      "844265c8-6d6e-4d34-b9bd-678a07ffa083",
      "10fd04f9-0dc0-496b-a5a7-67e711e38817"
)

$workspace = Get-FabricWorkspace -WorkspaceName "Tiago API 152"
  $body = @{
    principals = @( @{
        id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"
        type = "User"
    })
}

$bodyJson = $body | ConvertTo-Json -Depth 2
$bodyJson
Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri "https://api.fabric.microsoft.com/v1/admin/domains/2bf5d714-4dd4-44fb-b76e-10a0ff3dbcbe/assignWorkspacesByPrincipals" -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop


    $PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c";  type = "User"},
                    @{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User"})


$domain
$PrincipalIds

Add-FabricDomainWorkspaceByPrincipal -DomainId $domain.id -PrincipalIds $PrincipalIds

Remove-FabricDomainWorkspace -DomainId $domain.id -WorkspaceId $workspace.id


AssignFabricDomainWorkspaceRoleAssignment -DomainId $domain.id -DomainRole Contributors -PrincipalIds $PrincipalIds
Unassign-FabricDomainWorkspaceRoleAssignment -DomainId $domain.id -DomainRole Contributors -PrincipalIds $PrincipalIds
# Construct the JSON body
$PrincipalIds = @( @{id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c";  type = "User"},
@{id = "b5b9495c-685a-447a-b4d3-2d8e963e6288"; type = "User"})


$body = @{
    type = "Contributors"
    principals = $PrincipalIds
}
$bodyJson = $body | ConvertTo-Json -Depth 2
$bodyJson 

# Make the API request
#Write-Message -Message "Sending API request for bulk role unassignment..." -Level Info
$DomainId = "822d6d50-da15-4e91-a310-a75caf4827dc"
Get-FabricDomain -DomainId $DomainId

Get-FabricEnvironment -WorkspaceId $workspace.id

try {
    Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri "https://api.fabric.microsoft.com/v1/workspaces/fa69c132-6e79-4d5f-9074-37894d084f5e/environments" -Method Get -ErrorAction Stop
} catch {
    $webException = $_.Exception.InnerException
    if ($webException) {
        Write-Output "WebException Message: $($webException.Message)"
        Write-Output "HTTP Status Code: $($webException.Response.StatusCode)"
        Write-Output "HTTP Status Description: $($webException.Response.StatusDescription)"
    } else {
        Write-Output "General Error: $($_.Exception.Message)"
    }
}


try {
    #Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri "https://api.fabric.microsoft.com/v1/workspaces/faa69c132-6e79-4d5f-9074-37894d084f5e/environments" -Method Get -ErrorAction Stop
    $a = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -SkipHttpErrorCheck -StatusCodeVariable "statusCode"  -Uri "https://api.fabric.microsoft.com/v1/workspacesa" -Method Get -ErrorAction Stop
    #$a.message
    #$statusCode
    #$a
 }
    catch {            
        #Write-host  $a.message
        
        Write-host 'error'
    }

$a = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -SkipHttpErrorCheck -StatusCodeVariable "statusCode"  -Uri "https://api.fabric.microsoft.com/v1/workspaces/fa69c132-6e79-4d5f-9074-37894d084f5e/environments" -Method Get -ErrorAction Stop
$statusCode
Get-FabricWorkspace
$a.value 



try {
    # Make a REST API call with -SkipHttpErrorCheck to prevent automatic error handling
    $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -SkipHttpErrorCheck -StatusCodeVariable "statusCode"  -Uri "https://api.fabric.microsoft.com/v1/workspaces/fa69c132-6e79-4d5f-9074-37894d084f5e/environments" -Method Get -ErrorAction Stop
    $statusCode
    #$response
    # Check the HTTP status code to see if there's an error
    if ($statusCode -ge 400) {
        throw
    } else {
        # Handle success case
        Write-Host "Success: $($response.Content)"
    }
} catch {
    # Catch any unexpected errors (e.g., connection failures)
    Write-Host "An unexpected error occurred: $_"
    Write-Host "HTTP Error: $($response.message)"
    Write-Host "Error Code: $($response.errorCode)"
}

