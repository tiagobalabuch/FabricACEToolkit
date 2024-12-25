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

            # Log status for debugging
            Write-Message -Message "Operation Status: $($operation.status)" -Level Debug

            #Step 4: Wait before the next request
            Start-Sleep -Seconds $retryAfter
        } while ($operation.status -notin @("Succeeded", "Failed"))

        # Return the operation result
        return $operation
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "An error occurred while checking the operation: $errorDetails" -Level Error
        throw
    }
}