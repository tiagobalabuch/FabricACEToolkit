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
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/deprovisionIdentity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 202) {
            Write-Message -Message "Workspace identity has been successfully deprovisioned from workspace '$WorkspaceId'." -Level Info
            return $null
        } 
        elseif ($responseCode -eq 202) {
            Write-Message -Message "Request accepted! Workspace identity deprovisioning is in progress for workspace '$WorkspaceId'." -Level Info
            return $null
        } 
        else {
            # Handle unexpected response codes
            Write-Message -Message "Unexpected response code: $responseCode while deprovisioning workspace identity." -Level Error
            return $null
        }
    }
    catch {
        # Log and raise errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to deprovision workspace identity. Error: $errorDetails" -Level Error
        #throw "Error deprovisioning workspace identity: $errorDetails"
    }
}
