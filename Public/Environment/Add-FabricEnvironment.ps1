<#
.SYNOPSIS
Creates a new environment in a specified workspace.

.DESCRIPTION
The `Add-FabricEnvironment` function creates a new environment within a given workspace by making a POST request to the Fabric API. The environment can optionally include a description.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace where the environment will be created.

.PARAMETER EnvironmentName
(Mandatory) The name of the environment to be created. Only alphanumeric characters, spaces, and underscores are allowed.

.PARAMETER EnvironmentDescription
(Optional) A description of the environment.

.EXAMPLE
Add-FabricEnvironment -WorkspaceId "12345" -EnvironmentName "DevEnv" -EnvironmentDescription "Development Environment"

Creates an environment named "DevEnv" in workspace "12345" with the specified description.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Add-FabricEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentDescription
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/environments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Construct the request body
        $body = @{
            displayName = $EnvironmentName
            description = $EnvironmentDescription
        }

        if ($EnvironmentDescription) {
            $body.description = $EnvironmentDescription
        }

        $bodyJson = $body | ConvertTo-Json -Depth 2
        #Write-Message -Message "Request Body: $bodyJson" -Level Message

        # Step 4: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 5: Handle and log the response
        switch ($statusCode) {
            201 {
                Write-Message -Message "Environment '$EnvironmentName' created successfully!" -Level Info
                return $response
            }
            202 {
                Write-Message -Message "Environment '$EnvironmentName' creation accepted. Provisioning in progress!" -Level Info
                return $response
            }
            default {
                Write-Message -Message "Unexpected response code: $statusCode" -Level Error
                Write-Message -Message "Error details: $($response.message)" -Level Error
                throw "API request failed with status code $statusCode."
            }
        }
    }
    catch {
        # Step 6: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to create environment. Error: $errorDetails" -Level Error
    }
}