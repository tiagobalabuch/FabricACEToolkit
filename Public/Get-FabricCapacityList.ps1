function Get-FabricCapacityList {
    [CmdletBinding()]
    param ()

    try {

        # Check if the token is expired
        Is-TokenExpired 

        #Write-Host "Checking if token is expired: $TokenExpired" -ForegroundColor White

        # Construct the API URL
        $getCapacityUrl = "{0}/capacities" -f $FabricConfig.BaseUrl
        Write-Host "API Endpoint: $getCapacityUrl"

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $getCapacityUrl -Method Get

        # Check the response code and parse the content
        $responseCode = $response.StatusCode
        Write-Host "Response Code: $responseCode"

        if ($responseCode -eq 200) {
            $data = $response.Content | ConvertFrom-Json
            if ($data.value) {
                Write-Host "Capacities retrieved successfully." -ForegroundColor Green
                return $data.value
            }
            else {
                Write-Host "No capacities found." -ForegroundColor Yellow
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
        Write-Host "Failed to retrieve capacity list. Error: $errorDetails" -ForegroundColor Red
    }
}