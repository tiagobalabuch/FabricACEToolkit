<#
.SYNOPSIS
Retrieves domain information from Microsoft Fabric, optionally filtering by domain ID, domain name, or only non-empty domains.

.DESCRIPTION
The `Get-FabricDomain` function allows retrieval of domains in Microsoft Fabric, with optional filtering by domain ID or name. Additionally, it can filter to return only non-empty domains.

.PARAMETER DomainId
(Optional) The ID of the domain to retrieve.

.PARAMETER DomainName
(Optional) The display name of the domain to retrieve.

.PARAMETER NonEmptyDomainsOnly
(Optional) If set to `$true`, only domains containing workspaces will be returned.

.EXAMPLE
Get-FabricDomain -DomainId "12345"

Fetches the domain with ID "12345".

.EXAMPLE
Get-FabricDomain -DomainName "Finance"

Fetches the domain with the display name "Finance".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- The function handles ambiguous input for both `DomainId` and `DomainName`.

Author: Tiago Balabuch  
Date: 2024-12-14
#>
function Get-FabricDomain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$NonEmptyDomainsOnly = $false
    )

    try {
        # Handle ambiguous input
        if ($DomainId -and $DomainName) {
            Write-Message -Message "Both 'DomainId' and 'DomainName' were provided. Please specify only one." -Level Error
            return @()
        }

        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL with filtering logic        
        $apiEndpointUrl = "{0}/admin/domains" -f $FabricConfig.BaseUrl
        if ($NonEmptyDomainsOnly) {
            $apiEndpointUrl = "{0}?nonEmptyOnly=true" -f $apiEndpointUrl
        }
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop

        # Validate the response
        if (-not $response.Content) {
            Write-Message -Message "Empty response from the API." -Level Warning
            return @()
        }

        $responseCode = $response.StatusCode
        #Debug
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            # Parse the response
            $data = $response.Content | ConvertFrom-Json

            # Filter results based on provided parameters
            $domains = if ($DomainId) {
                $data.domains | Where-Object { $_.Id -eq $DomainId }
            }
            elseif ($DomainName) {
                $data.domains | Where-Object { $_.DisplayName -eq $DomainName }
            }
            else {
                # Return all domains if no filter is provided
                Write-Message -Message "No filter provided. Returning all domains." -Level Info
                return $data.domains
            }

            if ($domains) {
                return $domains
            }
            else {
                Write-Message -Message "No domain found matching the provided criteria." -Level Warning
                return $null
            }
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode from the API." -Level Error
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = Get-ErrorResponse($_.Exception)
        #$errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve domain. Error: $errorDetails" -Level Error
        #throw "Error retrieving workspace details: $errorDetails"
    }
}
