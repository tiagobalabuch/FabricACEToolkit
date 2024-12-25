function Get-FabricLongRunningOperationResult {
    param (
        [Parameter(Mandatory = $true)]
        [string]$operationId
    )

    # Step 1: Construct the API URL
    $apiEndpointUrl = "https://api.fabric.microsoft.com/v1/operations/{0}/result" -f $operationId
    Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug
    
    try {
        # Step 2: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Get `
            -ErrorAction Stop `
            -ResponseHeadersVariable responseHeader `
            -StatusCodeVariable statusCode
        # Return the result
        #return $resultResponse.definition.parts
        Write-Message -Message "Result return: $response" -Level Debug

        # Return the operation result
        return $response
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "An error occurred while returning the operation result: $errorDetails" -Level Error
        throw
    }
}