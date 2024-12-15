<#
.SYNOPSIS
Assigns a role to a principal for a specified Fabric workspace.

.DESCRIPTION
The `Add-FabricWorkspaceRoleAssignments` function assigns a role (e.g., Admin, Contributor, Member, Viewer) to a principal (e.g., User, Group, ServicePrincipal) in a Fabric workspace by making a POST request to the API.

.PARAMETER WorkspaceId
The unique identifier of the workspace.

.PARAMETER PrincipalId
The unique identifier of the principal (User, Group, etc.) to assign the role.

.PARAMETER PrincipalType
The type of the principal. Allowed values: Group, ServicePrincipal, ServicePrincipalProfile, User.

.PARAMETER WorkspaceRole
The role to assign to the principal. Allowed values: Admin, Contributor, Member, Viewer.

.EXAMPLE
Add-FabricWorkspaceRoleAssignment -WorkspaceId "workspace123" -PrincipalId "principal123" -PrincipalType "User" -WorkspaceRole "Admin"

Assigns the Admin role to the user with ID "principal123" in the workspace "workspace123".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-13
#>

function Add-FabricWorkspaceRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PrincipalId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Group', 'ServicePrincipal', 'ServicePrincipalProfile', 'User')]
        [string]$PrincipalType,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Admin', 'Contributor', 'Member', 'Viewer')]
        [string]$WorkspaceRole
    )

    try {
        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/roleAssignments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Define the role assignment body
        $body = @{
            principal = @{
                id   = $PrincipalId
                type = $PrincipalType
            }
            role = $WorkspaceRole
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 201) {
            Write-Message -Message "Role '$WorkspaceRole' assigned to principal '$PrincipalId' successfully in workspace '$WorkspaceId'." -Level Info
            return $response.Content | ConvertFrom-Json
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while assigning role." -Level Error
            return $null
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign role. Error: $errorDetails" -Level Error
        #throw "Error assigning role: $errorDetails"
    }
}
