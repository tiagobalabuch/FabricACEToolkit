<#
.SYNOPSIS
Retrieves an environment or a list of environments from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Get-FabricEnvironment` function sends a GET request to the Fabric API to retrieve environment details for a given workspace. It can filter the results by `EnvironmentName`.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace to query environments.

.PARAMETER EnvironmentName
(Optional) The name of the specific environment to retrieve.

.EXAMPLE
Get-FabricEnvironment -WorkspaceId "12345" -EnvironmentName "Development"

Retrieves the "Development" environment from workspace "12345".

.EXAMPLE
Get-FabricEnvironment -WorkspaceId "12345"

Retrieves all environments in workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- Returns the matching environment details or all environments if no filter is provided.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$EnvironmentName
    )

    try {
        # Step 1: Handle ambiguous input
        if ($EnvironmentId -and $EnvironmentName) {
            Write-Message -Message "Both 'EnvironmentId' and 'EnvironmentName' were provided. Please specify only one." -Level Error
            return $null
        }

        # Step 2: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/environments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Get `
            -ErrorAction Stop `
            -SkipHttpErrorCheck `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"

        # Step 5: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }
                    
        # Step 6: Handle empty response
        if (-not $response) {
            Write-Message -Message "No data returned from the API." -Level Warning
            return $null
        }
       
        # Step 7: Filter results based on provided parameters
        $environment = if ($EnvironmentId) {
            $response.value | Where-Object { $_.Id -eq $EnvironmentId }
        }
        elseif ($EnvironmentName) {
            $response.value | Where-Object { $_.DisplayName -eq $EnvironmentName }
        }
        else {
            # Return all workspaces if no filter is provided
            Write-Message -Message "No filter provided. Returning all environments." -Level Debug
            $response.value
        }

        # Step 8: Handle results
        if ($environment) {
            return $environment
        }
        else {
            Write-Message -Message "No environment found matching the provided criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve environment. Error: $errorDetails" -Level Error
    } 
 
}
