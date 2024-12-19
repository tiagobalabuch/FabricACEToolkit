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
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/assignToCapacity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Construct the request body
        $body = @{
            capacityId = $CapacityId
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4 -Compress
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Step 4: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 5: Validate the response code
        if ($statusCode -ne 202) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }

        Write-Message -Message "Workspace '$WorkspaceId' successfully assigned to capacity '$CapacityId'!" -Level Info
        return $null
    }
    catch {
        # Step 6: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign workspace to capacity. Error: $errorDetails" -Level Error
    }
}
