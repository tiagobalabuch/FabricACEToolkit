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
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

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
        # Step 1: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/unassignFromCapacity" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Post `
            -ContentType "application/json" `
            -ErrorAction Stop `
            -SkipHttpErrorCheck `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"


        # Step 4: Validate the response code
        if ($statusCode -ne 202) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }
        Write-Message -Message "Requested accepted for Workspace '$WorkspaceId'. Unassign in progress!" -Level Info
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
            Write-Message -Message "Workspace capacity has been successfully unassigned from workspace '$WorkspaceId'." -Level Info  
             
            return $operationResult
        }
        else {
            Write-Message -Message "Operation Failed" -Level Debug
            return $operationStatus
        }
        
    }
    catch {
        # Step 5: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to unassign workspace from capacity. Error: $errorDetails" -Level Error
    }
}
