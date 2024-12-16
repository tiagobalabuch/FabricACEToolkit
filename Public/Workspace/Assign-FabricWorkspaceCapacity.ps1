<#
.SYNOPSIS
Assigns a Fabric workspace to a specified capacity.

.DESCRIPTION
The `Assign-FabricWorkspaceCapacity` function sends a POST request to assign a workspace to a specific capacity.

.PARAMETER WorkspaceId
The unique identifier of the workspace to be assigned.

.PARAMETER CapacityId
The unique identifier of the capacity to which the workspace should be assigned.

.EXAMPLE
Assign-FabricWorkspaceCapacity -WorkspaceId "workspace123" -CapacityId "capacity456"

Assigns the workspace with ID "workspace123" to the capacity "capacity456".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Assign-FabricWorkspaceCapacity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CapacityId
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/assignToCapacity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Prepare the request body
        $body = @{
            capacityId = $CapacityId
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4 -Compress
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 202) {
                Write-Message -Message "Workspace '$WorkspaceId' successfully assigned to capacity '$CapacityId'!" -Level Info
                return $null
        } else {
            # Unexpected response handling
            Write-Message -Message "Unexpected response code: $responseCode while assigning workspace to capacity." -Level Error
            return $null
        }
    }
    catch {
        # Log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign workspace to capacity. Error: $errorDetails" -Level Error
        #throw "Error assigning workspace to capacity: $errorDetails"
    }
}
