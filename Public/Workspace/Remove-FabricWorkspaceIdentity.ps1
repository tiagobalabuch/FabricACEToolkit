<#
.SYNOPSIS
Deprovisions the Managed Identity for a specified Fabric workspace.

.DESCRIPTION
The `Remove-FabricWorkspaceCapacity` function deprovisions the Managed Identity from the given workspace by calling the appropriate API endpoint.

.PARAMETER WorkspaceId
The unique identifier of the workspace from which the identity will be removed.

.EXAMPLE
Remove-FabricWorkspaceCapacity -WorkspaceId "workspace123"

Deprovisions the Managed Identity for the workspace with ID "workspace123".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Remove-FabricWorkspaceIdentity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/deprovisionIdentity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 4: Handle and log the response
        switch ($statusCode) {
            200 {
                Write-Message -Message "Workspace identity was successfully deprovisioned for workspace '$WorkspaceId'." -Level Info
                return $response.value
            }
            202 {
                Write-Message -Message "Workspace identity deprovisioning accepted for workspace '$WorkspaceId'. Deprovisioning in progress!" -Level Info
                return $response.value
            }
            default {
                Write-Message -Message "Unexpected response code: $statusCode" -Level Error
                Write-Message -Message "Error details: $($response.message)" -Level Error
                throw "API request failed with status code $statusCode."
            }
        }
    }
    catch {
        # Step 5: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to deprovision workspace identity. Error: $errorDetails" -Level Error
    }
}