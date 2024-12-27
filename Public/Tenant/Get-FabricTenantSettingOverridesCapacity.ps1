<#
.SYNOPSIS
Retrieves capacities tenant settings overrides from the Fabric tenant.

.DESCRIPTION
The `Get-FabricTenantSetting` function retrieves capacities tenant settings overrides for a Fabric tenant by making a GET request to the appropriate API endpoint. 

.EXAMPLE
Get-FabricTenantSettingOverridesCapacity

Returns all capacities tenant settings overrides.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricTenantSettingOverridesCapacity {
    [CmdletBinding()]
    param ()
    try {
        # Step 1: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug


        $continuationToken = $null
        $capacitiesOverrides = @()

        $apiEndpointUrl = "{0}/admin/capacities/delegatedTenantSettingOverrides" -f $FabricConfig.BaseUrl
        # Step 2:  Loop to retrieve data with continuation token
        do {
            # Step 3: Construct the API URL
            $apiEndpointUrl = if ($null -ne $continuationToken) {
                "{0}?continuationToken={1}" -f $apiEndpointUrl, $continuationToken
            }
            else {
                $apiEndpointUrl
            }
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

            # Step 6: Add data to the list
            if ($null -ne $response) {
                Write-Message -Message "Adding data to the list" -Level Debug
                $capacitiesOverrides += $response.value
        
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

        # Step 7: Handle results
        if ($capacitiesOverrides) {
            return $capacitiesOverrides
        }
        else {
            Write-Message -Message "No capacity capacities tenant settings overrides overrides found matching the provided criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 8: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve capacities tenant settings overrides. Error: $errorDetails" -Level Error
    }
}
