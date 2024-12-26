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
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

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
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/assignToCapacity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Construct the request body
        $body = @{
            capacityId = $CapacityId
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4
        Write-Message -Message "Request Body: $bodyJson" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Post `
            -Body $bodyJson `
            -ContentType "application/json" `
            -ErrorAction Stop `
            -SkipHttpErrorCheck `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"

        # Step 5: Validate the response code
        if ($statusCode -ne 202) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }

        Write-Message -Message "Requested accepted for Workspace '$WorkspaceId'. Assignment in progress!" -Level Info
        [string]$operationId = $responseHeader["x-ms-operation-id"]
        Write-Message -Message "Operation ID: '$operationId'" -Level Debug
        Write-Message -Message "Getting Long Running Operation status" -Level Debug
               
        $operationStatus = Get-FabricLongRunningOperation -operationId $operationId
        Write-Message -Message "Long Running Operation status: $operationStatus" -Level Debug
        # Handle operation result
        if ($operationStatus.status -eq "Succeeded") {
            Write-Message -Message "Operation Succeeded" -Level Debug
            Write-Message -Message "Getting Long Running Operation result" -Level Debug
                
            $operationResult = Get-FabricLongRunningOperationResult -operationId $operationId
            Write-Message -Message "Long Running Operation status: $operationResult" -Level Debug
            Write-Message -Message "Workspace capacity has been successfully assigned from workspace '$WorkspaceId'." -Level Info  
            return $operationResult
        }
        else {
            Write-Message -Message "Operation Failed" -Level Debug
            return $operationStatus
        }
    }
    catch {
        # Step 6: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign workspace to capacity. Error: $errorDetails" -Level Error
    }
}
