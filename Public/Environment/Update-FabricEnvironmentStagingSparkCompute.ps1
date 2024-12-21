function Update-FabricEnvironmentStagingSparkCompute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$InstancePoolName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Workspace', 'Capacity')]
        [string]$InstancePoolType,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DriverCores,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverMemory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$ExecutorCores,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ExecutorMemory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [bool]$DynamicExecutorAllocationEnabled,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DynamicExecutorAllocationMinExecutors,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DynamicExecutorAllocationMaxExecutors,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RuntimeVersion,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]$SparkProperties

    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/environments/{2}/staging/sparkcompute" -f $FabricConfig.BaseUrl, $WorkspaceId, $EnvironmentId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Construct the request body
        $body = @{
            instancePool              = @{
                name = $InstancePoolName
                type = $InstancePoolType
            }
            driverCores               = $DriverCores
            driverMemory              = $DriverMemory
            executorCores             = $ExecutorCores
            executorMemory            = $ExecutorMemory
            dynamicExecutorAllocation = @{
                enabled      = $DynamicExecutorAllocationEnabled
                minExecutors = $DynamicExecutorAllocationMinExecutors
                maxExecutors = $DynamicExecutorAllocationMaxExecutors
            }
            runtimeVersion            = $RuntimeVersion
            sparkProperties           = $SparkProperties
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Step 4: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Patch -Body $bodyJson -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 5: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }

        # Step 6: Handle results
        Write-Message -Message "Environment staging spark compute updated successfully!" -Level Info
        return $response
    }
    catch {
        # Step 7: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to update environment staging spark compute. Error: $errorDetails" -Level Error
    }
}
