Import-Module .\FabricACEToolkit -Force
Get-Command -Module FabricACEToolkit

Set-FabricHeaders -tenantId "2ca1a04f-621b-4a1f-bad6-7ecd3ae78e25"


# Capacity
Get-FabricCapacity 
Get-FabricCapacity -capacityId "6b3297a9-84d0-4f51-99ac-76dda2572ba9"
Get-FabricCapacity -capacityName "tiagocapacity"

# Workspace
Get-FabricWorkspace
Get-FabricWorkspace -WorkspaceId "dda81258-3461-4135-b4db-71552064e50ac"
Get-FabricWorkspace -WorkspaceName "FinOps API TIAGO"

Add-FabricWorkspace -WorkspaceName "Tiago API"

$workspace = Add-FabricWorkspace -WorkspaceName "Tiago API2"

Update-FabricWorkspace -WorkspaceId $workspace.id -WorkspaceName "Tiago API UPDATED" -WorkspaceDescription "Updated description"

# Remove-FabricWorkspace -WorkspaceId $workspace.id

$workspace = Get-FabricWorkspace -WorkspaceName "mapereitest" 
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

Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri "https://api.fabric.microsoft.com/v1/workspaces/915d192f-4118-4d83-bc06-781527eb42f2/roleAssignments" -Method Get -ErrorAction Stop

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


$PrincipalIds = @{
    principals = @( @{
        id = "813abb4a-414c-4ac0-9c2c-bd17036fd58c"
    })
}

$domain

Add-FabricDomainWorkspaceByPrincipal -DomainId $domain.id -PrincipalIds $PrincipalIds