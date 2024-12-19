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
        # Step 1: Ensure token validity
        Test-TokenExpired

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Delete -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 4: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }

        Write-Message -Message "Workspace '$WorkspaceId' deleted successfully!" -Level Info
        return $null

    }
    catch {
        # Step 5: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve capacity. Error: $errorDetails" -Level Error
        return $null
    }
}
