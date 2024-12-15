function Add-FabricDomainWorkspaceByCapacity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]$CapacitiesIds
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}/assignWorkspacesByCapacities" -f $FabricConfig.BaseUrl, $DomainId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info
        
        # Construct the request body
        $body = @{
            capacitiesIds = $CapacitiesIds
        }

      
        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 2
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Handle response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        #$data = $response.Content | ConvertFrom-Json

        if ($responseCode -eq 202) {
            Write-Message -Message "Assigning domain workspaces by capacity is in progress!" -Level Info
            return $null
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while creating domain." -Level Error
            return $null
        }
    }
    catch {
        # Log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign domain workspaces by capacity. Error: $errorDetails" -Level Error
        #throw "Error creating domain: $errorDetails"
    }
}
