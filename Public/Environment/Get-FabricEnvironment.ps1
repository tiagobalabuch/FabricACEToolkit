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
- Validates token expiration before making the API request.

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
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$EnvironmentName
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Is-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/environments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Step 3: Make the API request
        #Write-Message -Message "Sending API request to retrieve environments..." -Level Info
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get #-ErrorAction Stop

        # Step 4: Handle response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info
        if ($responseCode -eq 200) {
            # Parse the response
            $data = $response.Content | ConvertFrom-Json

            # Filter results based on provided EnvironmentName
            if ($EnvironmentName) {
                $environment = $data.value | Where-Object { $_.displayName -eq $EnvironmentName }
                if ($environment) {
                    Write-Message -Message "Environment '$EnvironmentName' found." -Level Info
                    return $environment
                }
                else {
                    Write-Message -Message "No environment found with name '$EnvironmentName'." -Level Warning
                    return $null
                }
            }
            else {
                # Return all environments if no filter is provided
                Write-Message -Message "Returning all environments in the workspace." -Level Info
                return $data.value
            }
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode from the API." -Level Error
            return @()
        }
    }
    catch [System.Net.WebException] {
        # This is the missing statement block, indented for clarity
        Write-Warning "Web request failed: $($_.Exception.Message)"
        # Extract more specific error details, if needed:
        #Write-Warning "Status Code: $($ex.Status)"
        #Write-Warning "Response: $($ex.Response)"
    } 
    catch {
        Write-Warning "An unexpected error occurred: $($error.Message)"
    }
  <#  catch {
        # Step 5: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Error $_.Exception
        Write-Message -Message "Failed to retrieve environments. Error: $errorDetails" -Level Error
    }#>
}
