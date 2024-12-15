<#
.SYNOPSIS
Retrieves the workspaces associated with a specific domain in Microsoft Fabric.

.DESCRIPTION
The `Get-FabricDomainWorkspace` function fetches the workspaces for the given domain ID.

.PARAMETER DomainId
The ID of the domain for which to retrieve workspaces.

.EXAMPLE
Get-FabricDomainWorkspace -DomainId "12345"

Fetches workspaces for the domain with ID "12345".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Get-FabricDomainWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId
    )

    try {
        # Handle ambiguous input
        if ($DomainId -and $DomainName) {
            Write-Message -Message "Both 'DomainId' and 'DomainName' were provided. Please specify only one." -Level Error
            return @()
        }

        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}/workspaces" -f $FabricConfig.BaseUrl, $DomainId
        
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
            # Parse and return the response data
            $data = $response.Content | ConvertFrom-Json
            return $data.value
        } else {
            Write-Message -Message "Unexpected response code: $responseCode from the API." -Level Error
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to retrieve domain workspaces. Error: $errorDetails" -Level Error
        #throw "Error retrieving workspace details: $errorDetails"
    }
}
