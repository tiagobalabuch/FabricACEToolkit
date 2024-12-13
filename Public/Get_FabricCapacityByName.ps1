function Get-FabricCapacityByName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$capacityName    
    ) 

    try {

        # Check if the token is expired
        Is-TokenExpired 

        # Construct the API URL
        $getCapacityUrl = "{0}/capacities" -f $global:baseUrl
        Write-Host "API Endpoint: $getCapacityUrl"

        # Make the API request
        $response = Invoke-WebRequest -Headers $global:fabricHeaders -Uri $getCapacityUrl -Method Get

        # Check the response code and parse the content
        $responseCode = $response.StatusCode
        Write-Host "Response Code: $responseCode"

        if ($responseCode -eq 200) {
            $data = $response.Content | ConvertFrom-Json
            if ($data.value) {
                # Try to find the capacity by display name
                $capacity = $data.value | Where-Object { $_.DisplayName -eq $capacityName }

                if ($capacity) {
                    Write-Host "Capacity '$capacityName' found." -ForegroundColor Green
                    return $capacity
                }
                else {
                    Write-Host "No capacity found with the name '$capacityName'." -ForegroundColor Yellow
                    return $null
                }
            }
            else {
                Write-Host "No capacities found in the response." -ForegroundColor Yellow
                return @()
            }
        }
        else {
            Write-Host "Unexpected response code: $responseCode" -ForegroundColor Red
            return $null
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = $_.Exception | Get-ErrorResponse
        Write-Host "Failed to retrieve capacity by name. Error: $errorDetails" -ForegroundColor Red
    }
}