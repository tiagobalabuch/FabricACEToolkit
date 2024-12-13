<#
.SYNOPSIS
Sets the Fabric API headers with a valid token for the specified Azure tenant.

.DESCRIPTION
The `Set-FabricHeaders` function logs into the specified Azure tenant, retrieves an access token for the Fabric API, and sets the necessary headers for subsequent API requests. 
It also updates the token expiration time and global tenant ID.

.PARAMETER TenantId
The Azure tenant ID for which the access token is requested.

.EXAMPLE
Set-FabricHeaders -TenantId "your-tenant-id"

Logs in to Azure with the specified tenant ID, retrieves an access token, and configures the Fabric headers.

.NOTES
- Ensure the `Connect-AzAccount` and `Get-AzAccessToken` commands are available (Azure PowerShell module required).
- Relies on a global `$FabricConfig` object for storing headers and token metadata.
- Use the function `Is-TokenExpired` to check the token validity later.

.AUTHOR
Your Name
#>

function Set-FabricHeaders {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId
    )

    try {
        # Log the tenant being accessed
        Write-Message -Message "Logging in to Azure tenant: $TenantId" -Level Info

        # Connect to the Azure account
        Connect-AzAccount -Tenant $TenantId -ErrorAction Stop | Out-Null

        # Retrieve the access token for the Fabric API
        $fabricToken = Get-AzAccessToken -AsSecureString -ResourceUrl $FabricConfig.ResourceUrl -ErrorAction Stop

        # Extract the plain token from the secure string
        $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($fabricToken.Token)
        )

        # Set the headers in the global configuration
        $FabricConfig.FabricHeaders = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer $plainToken"
        }

        # Update token metadata in the global configuration
        $FabricConfig.TokenExpiresOn = $fabricToken.ExpiresOn
        $FabricConfig.TenantIdGlobal = $TenantId

        # Log success message
        Write-Message -Message "Fabric token successfully configured." -Level Info
    }
    catch {
        # Log detailed error messages
        # $errorDetails = $_.Exception.Message

        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to set Fabric token: $errorDetails" -Level Error
        throw "Unable to configure Fabric token. Ensure tenant and API configurations are correct."
    }
}
