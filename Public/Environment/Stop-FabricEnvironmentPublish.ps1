function Stop-FabricEnvironmentPublish{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/environments/{2}/staging/cancelPublish" -f $FabricConfig.BaseUrl, $WorkspaceId, $EnvironmentId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Step 3: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 4: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }
        Write-Message -Message "Publication for environment '$EnvironmentId' has been successfully canceled." -Level Info
        
    }
    catch {
        # Step 5: Log and handle errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to cancel publication for environment '$EnvironmentId' from workspace '$WorkspaceId'. Error: $errorDetails" -Level Error
    }
}
