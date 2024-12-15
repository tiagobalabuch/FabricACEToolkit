<#
.SYNOPSIS
Updates the role assignment for a specific principal in a Fabric workspace.

.DESCRIPTION
The `Update-FabricWorkspaceRoleAssignment` function updates the role assigned to a principal in a workspace by making a PATCH request to the API.

.PARAMETER WorkspaceId
The unique identifier of the workspace where the role assignment exists.

.PARAMETER WorkspaceRoleAssignmentId
The unique identifier of the role assignment to be updated.

.PARAMETER WorkspaceRole
The new role to assign to the principal. Must be one of the following:
- Admin
- Contributor
- Member
- Viewer

.EXAMPLE
Update-FabricWorkspaceRoleAssignment -WorkspaceId "workspace123" -WorkspaceRoleAssignmentId "assignment456" -WorkspaceRole "Admin"

Updates the role assignment to "Admin" for the specified workspace and role assignment.

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Update-FabricWorkspaceRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceRoleAssignmentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Admin', 'Contributor', 'Member', 'Viewer')]
        [string]$WorkspaceRole
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/roleAssignments/{2}" -f $FabricConfig.BaseUrl, $WorkspaceId, $WorkspaceRoleAssignmentId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Prepare the request body
        $body = @{
            role = $WorkspaceRole
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4 -Compress
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Send the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Patch -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Evaluate the response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            Write-Message -Message "Role assignment updated successfully in workspace '$WorkspaceId'." -Level Info
            return $response.Content | ConvertFrom-Json
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while updating role assignment." -Level Error
            return $null
        }
    }
    catch {
        # Log and handle errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to update role assignment. Error: $errorDetails" -Level Error
        #throw "Error updating role assignment: $errorDetails"
    }
}
