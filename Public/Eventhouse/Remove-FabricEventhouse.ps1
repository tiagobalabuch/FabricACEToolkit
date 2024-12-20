<#
.SYNOPSIS
Deletes an Eventhouse from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Remove-FabricEventhouse` function sends a DELETE request to the Fabric API to remove a specified Eventhouse from a given workspace.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace containing the Eventhouse to delete.

.PARAMETER EventhouseId
(Mandatory) The ID of the Eventhouse to be deleted.

.EXAMPLE
Remove-FabricEventhouse -WorkspaceId "12345" -EventhouseId "67890"

Deletes the Eventhouse with ID "67890" from workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Validates token expiration before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Remove-FabricEventhouse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EventhouseId
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Is-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/eventhouses/{2}" -f $FabricConfig.BaseUrl, $WorkspaceId, $EventhouseId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Step 3: Send DELETE request to API
        #Write-Message -Message "Sending API request to delete Eventhouse '$EventhouseId'..." -Level Info
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Delete -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 4: Handle response
        $responseCode = $response.StatusCode
        if ($responseCode -eq 200) {
            Write-Message -Message "Eventhouse '$EventhouseId' deleted successfully from workspace '$WorkspaceId'." -Level Info
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode while attempting to delete Eventhouse '$EventhouseId'." -Level Error
        }
    }
    catch {
        # Step 5: Log and handle errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to delete Eventhouse '$EventhouseId'. Error: $errorDetails" -Level Error
    }
}
