<#
.SYNOPSIS
Retrieves a Fabric capacity by either its ID, Display Name, or all capacities if no filter is provided.

.DESCRIPTION
The `Get-FabricCapacity` function retrieves specific Fabric capacities based on the provided ID or Display Name. 
If no ID or Display Name is specified, it returns all capacities.

.PARAMETER capacityId
The unique identifier of the Fabric capacity to retrieve.

.PARAMETER capacityName
The display name of the Fabric capacity to retrieve.

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
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

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
        # Handle ambiguous input
        if ($capacityId -and $capacityName) {
            Write-Message -Message "Both 'capacityId' and 'capacityName' were provided. Please specify only one." -Level Error
            return @()
        }

        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/capacities" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop

        # Validate and parse the response
        if (-not $response.Content) {
            Write-Message -Message "Empty response from the API." -Level 
            return @()
        }
        
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info
        
        $data = $response.Content | ConvertFrom-Json

        if ($responseCode -eq 200) {
            $data = $response.Content | ConvertFrom-Json

            # Filter results based on provided parameter
            $capacity = if ($capacityId) {
                $data.value | Where-Object { $_.Id -eq $capacityId }
            }
            elseif ($capacityName) {
                $data.value | Where-Object { $_.DisplayName -eq $capacityName }
            }
            else {
                # Return all capacities if no filter is provided
                Write-Message -Message "No filter provided. Returning all capacities." -Level Info
                return $data.value
            }

            if ($capacity) {
                Write-Message -Message "Capacity found" -Level Info
                return $capacity
            }
            else {
                Write-Message -Message "No capacity found matching the provided criteria." -Level Warning
                return $null
            }
        }
        else {
            Write-Message -Message "No capacities returned from the API." -Level Warning
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to retrieve capacity. Error: $errorDetails" -Level Error
       # Write-Message -Message "Failed to retrieve capacity. Error: $_.Exception" -Level Error
    }
}
