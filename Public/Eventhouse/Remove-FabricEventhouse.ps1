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
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/eventhouses/{2}" -f $FabricConfig.BaseUrl, $WorkspaceId, $EventhouseId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Delete `
            -ErrorAction Stop `
            -SkipHttpErrorCheck `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"
        
            # Step 4: Handle response
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }

        Write-Message -Message "Eventhouse '$EventhouseId' deleted successfully from workspace '$WorkspaceId'." -Level Info  
    }
    catch {
        # Step 5: Log and handle errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to delete Eventhouse '$EventhouseId'. Error: $errorDetails" -Level Error
    }
}
