<#
.SYNOPSIS
Removes a role assignment from a Fabric workspace.

.DESCRIPTION
The `Remove-FabricWorkspaceRoleAssignment` function deletes a specific role assignment from a Fabric workspace by making a DELETE request to the API.

.PARAMETER WorkspaceId
The unique identifier of the workspace.

.PARAMETER WorkspaceRoleAssignmentId
The unique identifier of the role assignment to be removed.

.EXAMPLE
Remove-FabricWorkspaceRoleAssignment -WorkspaceId "workspace123" -WorkspaceRoleAssignmentId "role123"

Removes the role assignment with the ID "role123" from the workspace "workspace123".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-13
#>

function Remove-FabricWorkspaceRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceRoleAssignmentId
    )

    try {
        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/roleAssignments/{2}" -f $FabricConfig.BaseUrl, $WorkspaceId, $WorkspaceRoleAssignmentId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Delete -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            Write-Message -Message "Role assignment '$WorkspaceRoleAssignmentId' successfully removed from workspace '$WorkspaceId'." -Level Info
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while deleting the role assignment." -Level Error
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to remove role assignment. Error: $errorDetails" -Level Error
        throw "Error removing role assignment: $errorDetails"
    }
}
