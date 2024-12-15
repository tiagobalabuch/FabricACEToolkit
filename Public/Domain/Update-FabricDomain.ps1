<#
.SYNOPSIS
Updates a Fabric domain by its ID.

.DESCRIPTION
The `Update-FabricDomain` function modifies a specified domain in Microsoft Fabric using the provided parameters. 

.PARAMETER DomainId
The unique identifier of the domain to be updated.

.PARAMETER DomainName
The new name for the domain. Must be alphanumeric.

.PARAMETER DomainDescription
(Optional) A new description for the domain.

.PARAMETER DomainContributorsScope
(Optional) The contributors' scope for the domain. Accepted values: 'AdminsOnly', 'AllTenant', 'SpecificUsersAndGroups'.

.EXAMPLE
Update-FabricDomain -DomainId "12345" -DomainName "NewDomain" -DomainDescription "Updated description" -DomainContributorsScope "AdminsOnly"

Updates the domain with ID "12345" with a new name, description, and contributors' scope.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Update-FabricDomain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$DomainName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainDescription,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('AdminsOnly', 'AllTenant', 'SpecificUsersAndGroups')]
        [string]$DomainContributorsScope
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}" -f $FabricConfig.BaseUrl, $DomainId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Define the request body
        $body = @{
            displayName = $DomainName
        }

        if ($DomainDescription) {
            $body.description = $DomainDescription
        }

        if ($DomainContributorsScope) {
            $body.contributorsScope = $DomainContributorsScope
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 10
        Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Patch -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            Write-Message -Message "Domain '$DomainName' updated successfully!" -Level Info

            if ($response.Content) {
                $data = $response.Content | ConvertFrom-Json
                Write-Message -Message "Response Content: $($data | ConvertTo-Json -Depth 10)" -Level Debug
                return $data
            } else {
                Write-Message -Message "No content returned in the response. Update assumed successful." -Level Info
                return $null
            }
        } else {
            Write-Message -Message "Unexpected response code: $responseCode during update." -Level Error
            return $null
        }
    }
    catch {
        # Log and handle errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to update domain '$DomainId'. Error: $errorDetails" -Level Error
        throw "Error updating domain: $errorDetails"
    }
}
