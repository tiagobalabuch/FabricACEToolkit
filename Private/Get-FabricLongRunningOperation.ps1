<#
.SYNOPSIS
    Monitors the status of a long-running operation in Microsoft Fabric.

.DESCRIPTION
    The Get-FabricLongRunningOperation function queries the Microsoft Fabric API to check the status of a 
    long-running operation. It periodically polls the operation until it reaches a terminal state (Succeeded or Failed).

.PARAMETER operationId
    The unique identifier of the long-running operation to be monitored.

.PARAMETER retryAfter
    The interval (in seconds) to wait between polling the operation status. The default is 5 seconds.

.EXAMPLE
    PS C:\> Get-FabricLongRunningOperation -operationId "12345-abcd-67890-efgh" -retryAfter 10

    This command polls the status of the operation with the given operationId every 10 seconds until it completes.

.NOTES
    - Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.

    .AUTHOR
Tiago Balabuch

#>
function Get-FabricLongRunningOperation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$operationId,

        [Parameter(Mandatory = $false)]
        [int]$retryAfter = 5
    )

    # Step 1: Construct the API URL
    $apiEndpointUrl = "https://api.fabric.microsoft.com/v1/operations/{0}" -f $operationId
    Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug
    
    try {
        do {
            # Step 2: Make the API request
            $response = Invoke-RestMethod `
                -Headers $FabricConfig.FabricHeaders `
                -Uri $apiEndpointUrl `
                -Method Get `
                -ErrorAction Stop `
                -ResponseHeadersVariable responseHeader `
                -StatusCodeVariable statusCode

            # Step 3: Parse the response
            $jsonOperation = $response | ConvertTo-Json
            $operation = $jsonOperation | ConvertFrom-Json

            #$operation = $response | ConvertFrom-Json

            # Log status for debugging
            Write-Message -Message "Operation Status: $($operation.status)" -Level Debug

            # Step 4: Wait before the next request
            if ($operation.status -notin @("Succeeded", "Failed")) {
                Start-Sleep -Seconds $retryAfter
            }
        } while ($operation.status -notin @("Succeeded", "Failed"))

        # Step 5: Return the operation result
        return $operation
    }
    catch {
        # Step 6: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "An error occurred while checking the operation: $errorDetails" -Level Error
        throw
    }
}