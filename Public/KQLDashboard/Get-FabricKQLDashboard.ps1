<#
.SYNOPSIS
Retrieves an KQLDashboard or a list of KQLDashboards from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Get-FabricKQLDashboard` function sends a GET request to the Fabric API to retrieve KQLDashboard details for a given workspace. It can filter the results by `KQLDashboardName`.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace to query KQLDashboards.

.PARAMETER KQLDashboardName
(Optional) The name of the specific KQLDashboard to retrieve.

.EXAMPLE
Get-FabricKQLDashboard -WorkspaceId "12345" -KQLDashboardName "Development"

Retrieves the "Development" KQLDashboard from workspace "12345".

.EXAMPLE
Get-FabricKQLDashboard -WorkspaceId "12345"

Retrieves all KQLDashboards in workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricKQLDashboard {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$KQLDashboardId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$KQLDashboardName
    )

    try {
        # Step 1: Handle ambiguous input
        if ($KQLDashboardId -and $KQLDashboardName) {
            Write-Message -Message "Both 'KQLDashboardId' and 'KQLDashboardName' were provided. Please specify only one." -Level Error
            return $null
        }

        # Step 2: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        $continuationToken = $null
        $KQLDashboards = @()

        $apiEndpointUrl = "{0}/workspaces/{1}/kqlDashboards" -f $FabricConfig.BaseUrl, $WorkspaceId
        # Step 3:  Loop to retrieve data with continuation token
        do {
            # Step 4: Construct the API URL
            $apiEndpointUrl = if ($null -ne $continuationToken) {
                "{0}?continuationToken={1}" -f $apiEndpointUrl, $continuationToken
            }
            else {
                $apiEndpointUrl
            }
            Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

            # Step 5: Make the API request
            $response = Invoke-RestMethod `
                -Headers $FabricConfig.FabricHeaders `
                -Uri $apiEndpointUrl `
                -Method Get `
                -ErrorAction Stop `
                -SkipHttpErrorCheck `
                -StatusCodeVariable "statusCode"

            # Step 6: Validate the response code
            if ($statusCode -ne 200) {
                Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
                Write-Message -Message "Error: $($response.message)" -Level Error
                Write-Message "Error Code: $($response.errorCode)" -Level Error
                return $null
            }
                    
            # Step 7: Add data to the list
            if ($null -ne $response) {
                Write-Message -Message "Adding data to the list" -Level Debug
                $KQLDashboards += $response.value
        
                # Update the continuation token
                Write-Message -Message "Updating the continuation token" -Level Debug
                $continuationToken = $response.continuationToken
                Write-Message -Message "Continuation token: $continuationToken" -Level Debug
            }
            else {
                Write-Message -Message "No data received from the API." -Level Warning
                break
            }
        } while ($null -ne $continuationToken)
       
        # Step 8: Filter results based on provided parameters
        $KQLDashboard = if ($KQLDashboardId) {
            $KQLDashboards | Where-Object { $_.Id -eq $KQLDashboardId }
        }
        elseif ($KQLDashboardName) {
            $KQLDashboards | Where-Object { $_.DisplayName -eq $KQLDashboardName }
        }
        else {
            # Return all workspaces if no filter is provided
            Write-Message -Message "No filter provided. Returning all KQLDashboards." -Level Debug
            $response.value
        }

        # Step 9: Handle results
        if ($KQLDashboard) {
            return $KQLDashboard
        }
        else {
            Write-Message -Message "No KQLDashboard found matching the provided criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 10: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve KQLDashboard. Error: $errorDetails" -Level Error
    } 
 
}