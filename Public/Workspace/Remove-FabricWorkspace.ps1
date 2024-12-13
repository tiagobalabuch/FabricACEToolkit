<#
.SYNOPSIS
Deletes an existing Fabric workspace by its workspace ID.

.DESCRIPTION
The `Remove-FabricWorkspace` function deletes a workspace in the Fabric platform by sending a DELETE request to the API. It validates the workspace ID and handles both success and error responses.

.PARAMETER WorkspaceId
The unique identifier of the workspace to be deleted.

.EXAMPLE
Remove-FabricWorkspace -WorkspaceId "workspace123"

Deletes the workspace with the ID "workspace123".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.
- Logs each step of the operation for debugging and monitoring purposes.
- Supports response codes `200` (OK) and `204` (No Content) as successful deletion.

Author: Tiago Balabuch  
Date: 2024-12-12
#>

function Remove-FabricWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId
    )

    try {
        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $deleteWorkspaceUrl = "{0}/workspaces/{1}" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $deleteWorkspaceUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $deleteWorkspaceUrl -Method Delete -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            # Handle successful deletion
            Write-Message -Message "Workspace '$WorkspaceId' deleted successfully!" -Level Info
            return @()
        }
        else {
            # Log unexpected response codes
            Write-Message -Message "Unexpected response code: $responseCode" -Level Error
            return $null
        }
    }
    catch {
        # Capture detailed error information
        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to delete workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
        #Write-Message -Message "Failed to delete workspace '$WorkspaceId'. Error: $_.Exception" -Level Error
    }
}
