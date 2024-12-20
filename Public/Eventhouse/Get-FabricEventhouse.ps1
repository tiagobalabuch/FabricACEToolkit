<#
.SYNOPSIS
Retrieves an Eventhouse or a list of Eventhouses from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Get-FabricEventhouse` function sends a GET request to the Fabric API to retrieve Eventhouse details for a given workspace. It can filter the results by `EventhouseName`.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace to query Eventhouses.

.PARAMETER EventhouseName
(Optional) The name of the specific Eventhouse to retrieve.

.EXAMPLE
Get-FabricEventhouse -WorkspaceId "12345" -EventhouseName "Development"

Retrieves the "Development" Eventhouse from workspace "12345".

.EXAMPLE
Get-FabricEventhouse -WorkspaceId "12345"

Retrieves all Eventhouses in workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- Returns the matching Eventhouse details or all Eventhouses if no filter is provided.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricEventhouse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EventhouseId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$EventhouseName
    )

    try {

        # Step 1: Handle ambiguous input
        if ($EventhouseId -and $EventhouseName) {
            Write-Message -Message "Both 'EventhouseId' and 'EventhouseName' were provided. Please specify only one." -Level Error
            return $null
        }

        # Step 2: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/eventhouses" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Step 4: Make the API request
        #Write-Message -Message "Sending API request to retrieve Eventhouses..." -Level Info
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

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
        $Eventhouse = if ($EventhouseId) {
            $response | Where-Object { $_.Id -eq $EventhouseId }
        }
        elseif ($EventhouseName) {
            $response | Where-Object { $_.DisplayName -eq $EventhouseName }
        }
        else {
            # Return all workspaces if no filter is provided
            Write-Message -Message "No filter provided. Returning all Eventhouses." -Level Info
            $response
        }

        # Step 8: Handle results
        if ($Eventhouse) {
            return $Eventhouse
        }
        else {
            Write-Message -Message "No Eventhouse found matching the provided criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve Eventhouse. Error: $errorDetails" -Level Error
    } 
 
}
