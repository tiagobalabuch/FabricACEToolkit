<#
.SYNOPSIS
Deletes an environment from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Remove-FabricEnvironment` function sends a DELETE request to the Fabric API to remove a specified environment from a given workspace.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace containing the environment to delete.

.PARAMETER EnvironmentId
(Mandatory) The ID of the environment to be deleted.

.EXAMPLE
Remove-FabricEnvironment -WorkspaceId "12345" -EnvironmentId "67890"

Deletes the environment with ID "67890" from workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Validates token expiration before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Remove-FabricEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Is-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/environments/{2}" -f $FabricConfig.BaseUrl, $WorkspaceId, $EnvironmentId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Step 3: Send DELETE request to API
        #Write-Message -Message "Sending API request to delete environment '$EnvironmentId'..." -Level Info
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Delete -ErrorAction Stop

        # Step 4: Handle response
        $responseCode = $response.StatusCode
        if ($responseCode -eq 200) {
            Write-Message -Message "Environment '$EnvironmentId' deleted successfully from workspace '$WorkspaceId'." -Level Info
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode while attempting to delete environment '$EnvironmentId'." -Level Error
        }
    }
    catch {
        # Step 5: Log and handle errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to delete environment '$EnvironmentId'. Error: $errorDetails" -Level Error
    }
}
