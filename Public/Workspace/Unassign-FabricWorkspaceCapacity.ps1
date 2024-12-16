<#
.SYNOPSIS
Unassigns a Fabric workspace from its capacity.

.DESCRIPTION
The `Unassign-FabricWorkspaceCapacity` function sends a POST request to unassign a workspace from its assigned capacity.

.PARAMETER WorkspaceId
The unique identifier of the workspace to be unassigned from its capacity.

.EXAMPLE
Unassign-FabricWorkspaceCapacity -WorkspaceId "workspace123"

Unassigns the workspace with ID "workspace123" from its capacity.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Unassign-FabricWorkspaceCapacity {
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
        $apiEndpointUrl = "{0}/workspaces/{1}/unassignFromCapacity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 202) {
            Write-Message -Message "Workspace capacity has been successfully unassigned from workspace '$WorkspaceId'." -Level Info
            return $null
        } else {
            # Handle unexpected response codes
            Write-Message -Message "Unexpected response code: $responseCode while unassigning workspace from capacity." -Level Error
            return $null
        }
    }
    catch {
        # Log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to unassign workspace from capacity. Error: $errorDetails" -Level Error
        #throw "Error unassigning workspace from capacity: $errorDetails"
    }
}
