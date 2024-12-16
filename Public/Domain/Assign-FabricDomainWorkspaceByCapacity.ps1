<#
.SYNOPSIS
Assigns workspaces to a Fabric domain based on specified capacities.

.DESCRIPTION
The `Assign-FabricDomainWorkspaceByCapacity` function assigns workspaces to a Fabric domain using a list of capacity IDs by making a POST request to the relevant API endpoint.

.PARAMETER DomainId
The unique identifier of the Fabric domain to which the workspaces will be assigned.

.PARAMETER CapacitiesIds
An array of capacity IDs used to assign workspaces to the domain.

.EXAMPLE
Assign-FabricDomainWorkspaceByCapacity -DomainId "12345" -CapacitiesIds @("capacity1", "capacity2")

Assigns workspaces to the domain with ID "12345" based on the specified capacities.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure token validity before making the API request.
- Includes detailed logging and error handling.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Assign-FabricDomainWorkspaceByCapacity {
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

        if ($responseCode -eq 202) {
            Write-Message -Message "Assigning domain workspaces by capacity is in progress for domain '$DomainId'." -Level Info
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while processing domain '$DomainId'." -Level Error
        }
    }
    catch {
        # Log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Error occurred while assigning workspaces by capacity for domain '$DomainId'. Details: $errorDetails" -Level Error
    }
}
