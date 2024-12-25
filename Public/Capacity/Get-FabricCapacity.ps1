<#
.SYNOPSIS
Retrieves a Fabric capacity by its ID, Display Name, or returns all capacities if no filter is provided.

.DESCRIPTION
The `Get-FabricCapacity` function interacts with the Fabric API to retrieve capacity details. It can filter by `capacityId` or `capacityName`, or return all available capacities if no filter is specified.

.PARAMETER capacityId
(Optional) The unique identifier of the Fabric capacity to retrieve.

.PARAMETER capacityName
(Optional) The display name of the Fabric capacity to retrieve.

.EXAMPLE
Get-FabricCapacity -capacityId "12345"

Retrieve a Fabric capacity by its unique ID.

.EXAMPLE
Get-FabricCapacity -capacityName "MyCapacity"

Retrieve a Fabric capacity by its display name.

.EXAMPLE
Get-FabricCapacity

Retrieve all available capacities.

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Uses `Test-TokenExpired` to validate the token before making API calls.

Author: Tiago Balabuch  
Date: 2024-12-12
#>

function Get-FabricCapacity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$capacityId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$capacityName
    )

    try {
        # Step 1: Handle ambiguous input
        if ($capacityId -and $capacityName) {
            Write-Message -Message "Both 'capacityId' and 'capacityName' were provided. Please specify only one." -Level Error
            return $null
        }

        # Step 2: Ensure token validity
        Test-TokenExpired

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/capacities" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 5: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }

        # Step 6: Handle empty response
        if (-not $response.value) {
            Write-Message -Message "No capacities returned from the API." -Level Warning
            return $null
        }

        # Step 7: Filter results based on provided parameters
        $capacity = if ($capacityId) {
            $response.value | Where-Object { $_.Id -eq $capacityId }
        }
        elseif ($capacityName) {
            $response.value | Where-Object { $_.DisplayName -eq $capacityName }
        }
        else {
            # No filter, return all capacities
            Write-Message -Message "No filter specified. Returning all capacities." -Level Debug
            return $response.value
        }

        # Step 8: Handle results
        if ($capacity) {
            Write-Message -Message "Capacity found matching the specified criteria." -Level Debug
            return $capacity
        }
        else {
            Write-Message -Message "No capacity found matching the specified criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve capacity. Error: $errorDetails" -Level Error
        return $null
    }
}
