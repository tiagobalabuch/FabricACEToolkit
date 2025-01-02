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
        # Step 1: Connect to the Azure account
        Write-Message -Message "Logging in to Azure tenant: $TenantId" -Level Info
        Connect-AzAccount -Tenant $TenantId -ErrorAction Stop | Out-Null

        # Step 2: Retrieve the access token for the Fabric API
        Write-Message -Message "Retrieve the access token for the Fabric API: $TenantId" -Level Debug
        $fabricToken = Get-AzAccessToken -AsSecureString -ResourceUrl $FabricConfig.ResourceUrl -ErrorAction Stop -WarningAction SilentlyContinue

        ## Step 2: Extract the plain token from the secure string
        Write-Message -Message "Extract the plain token from the secure string" -Level Debug
        $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($fabricToken.Token)
        )

        ## Step 3: Set the headers in the global configuration
        Write-Message -Message "Set the headers in the global configuration" -Level Debug
        $FabricConfig.FabricHeaders = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer $plainToken"
        }

        ## Step 4: Update token metadata in the global configuration
        Write-Message -Message "Update token metadata in the global configuration" -Level Debug
        $FabricConfig.TokenExpiresOn = $fabricToken.ExpiresOn
        $FabricConfig.TenantIdGlobal = $TenantId

        Write-Message -Message "Fabric token successfully configured." -Level Info
    }
    catch {
        # Step 5: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to set Fabric token: $errorDetails" -Level Error
        throw "Unable to configure Fabric token. Ensure tenant and API configurations are correct."
    }
}
