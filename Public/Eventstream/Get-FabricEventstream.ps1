<#
.SYNOPSIS
Retrieves an Eventstream or a list of Eventstreams from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Get-FabricEventstream` function sends a GET request to the Fabric API to retrieve Eventstream details for a given workspace. It can filter the results by `EventstreamName`.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace to query Eventstreams.

.PARAMETER EventstreamName
(Optional) The name of the specific Eventstream to retrieve.

.EXAMPLE
Get-FabricEventstream -WorkspaceId "12345" -EventstreamName "Development"

Retrieves the "Development" Eventstream from workspace "12345".

.EXAMPLE
Get-FabricEventstream -WorkspaceId "12345"

Retrieves all Eventstreams in workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricEventstream {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EventstreamId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$EventstreamName
    )

    try {
        # Step 1: Handle ambiguous input
        if ($EventstreamId -and $EventstreamName) {
            Write-Message -Message "Both 'EventstreamId' and 'EventstreamName' were provided. Please specify only one." -Level Error
            return $null
        }

        # Step 2: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/eventstreams" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Get `
            -ErrorAction Stop `
            -SkipHttpErrorCheck `
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
        $Eventstream = if ($EventstreamId) {
            $response.value | Where-Object { $_.Id -eq $EventstreamId }
        }
        elseif ($EventstreamName) {
            $response.value | Where-Object { $_.DisplayName -eq $EventstreamName }
        }
        else {
            # Return all workspaces if no filter is provided
            Write-Message -Message "No filter provided. Returning all Eventstreams." -Level Debug
            $response.value
        }

        # Step 8: Handle results
        if ($Eventstream) {
            return $Eventstream
        }
        else {
            Write-Message -Message "No Eventstream found matching the provided criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve Eventstream. Error: $errorDetails" -Level Error
    } 
 
}
