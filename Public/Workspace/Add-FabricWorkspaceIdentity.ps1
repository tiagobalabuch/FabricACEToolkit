<#
.SYNOPSIS
Provisions an identity for a Fabric workspace.

.DESCRIPTION
The `Add-FabricWorkspaceIdentity` function provisions an identity for a specified workspace by making an API call.

.PARAMETER WorkspaceId
The unique identifier of the workspace for which the identity will be provisioned.

.EXAMPLE
Add-FabricWorkspaceIdentity -WorkspaceId "workspace123"

Provisions a Managed Identity for the workspace with ID "workspace123".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Add-FabricWorkspaceIdentity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/provisionIdentity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200 -or $responseCode -eq 202) {
            $statusMessage = if ($responseCode -eq 200) {
                "Workspace identity was successfully provisioned for workspace '$WorkspaceId'."
            } else {
                "Request accepted! Workspace identity provisioning is in progress for workspace '$WorkspaceId'."
            }
            Write-Message -Message $statusMessage -Level Info

            # Parse and return content if available
            if ($response.Content) {
                return $response.Content | ConvertFrom-Json
            } else {
                return $null
            }
        } else {
            # Handle unexpected response codes
            Write-Message -Message "Unexpected response code: $responseCode while provisioning workspace identity." -Level Error
            return $null
        }
    }
    catch {
        # Log and raise errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to provision workspace identity. Error: $errorDetails" -Level Error
        #throw "Error provisioning workspace identity: $errorDetails"
    }
}
