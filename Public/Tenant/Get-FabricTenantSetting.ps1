<#
.SYNOPSIS
Retrieves tenant settings from the Fabric environment.

.DESCRIPTION
The `Get-FabricTenantSetting` function retrieves tenant settings for a Fabric environment by making a GET request to the appropriate API endpoint. Optionally, it filters the results by the `SettingTitle` parameter.

.PARAMETER SettingTitle
(Optional) The title of a specific tenant setting to filter the results.

.EXAMPLE
Get-FabricTenantSetting

Returns all tenant settings.

.EXAMPLE
Get-FabricTenantSetting -SettingTitle "SomeSetting"

Returns the tenant setting with the title "SomeSetting".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricTenantSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SettingTitle
    )

    try {
        # Ensure the token is valid
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/tenantsettings" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        Write-Message -Message "Sending API request to retrieve tenant settings..." -Level Info
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop

        # Validate and parse the response
        if (-not $response.Content) {
            Write-Message -Message "Empty response from the API." -Level Warning
            return @()
        }

        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            $data = $response.Content | ConvertFrom-Json

            # Filter results if SettingTitle is provided
            if ($SettingTitle) {
                Write-Message -Message "Filtering tenant settings for title: $SettingTitle" -Level Info
                $filteredSettings = $data.tenantSettings | Where-Object { $_.title -eq $SettingTitle }

                if ($filteredSettings) {
                    Write-Message -Message "Tenant setting found for title: $SettingTitle" -Level Info
                    return $filteredSettings
                }
                else {
                    Write-Message -Message "No tenant setting found with title: $SettingTitle" -Level Warning
                    return $null
                }
            }
            else {
                Write-Message -Message "No filter applied. Returning all tenant settings." -Level Info
                return $data.tenantSettings
            }
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode received from API." -Level Error
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve tenant settings. Error: $errorDetails" -Level Error
    }
}
