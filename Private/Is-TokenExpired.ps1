<#
.SYNOPSIS
Checks if the Fabric token is expired and logs appropriate messages.

.DESCRIPTION
The `Is-TokenExpired` function checks the expiration status of the Fabric token stored in the `$FabricConfig.TokenExpiresOn` variable. 
If the token is expired, it logs an error message and provides guidance for refreshing the token. 
Otherwise, it logs that the token is still valid.

.PARAMETER FabricConfig
The configuration object containing the token expiration details.

.EXAMPLE
Is-TokenExpired -FabricConfig $config

Checks the token expiration status using the provided `$config` object.

.NOTES
- Ensure the `FabricConfig` object includes a valid `TokenExpiresOn` property of type `DateTimeOffset`.
- Requires the `Write-Log` function for logging.

.AUTHOR
Tiago Balabuch
#>

function Is-TokenExpired {
    [CmdletBinding()]
    param (
 #       [Parameter(Mandatory)]
 #       [PSCustomObject]$FabricConfig
    )

    try {
        # Ensure required properties have valid values
        if ([string]::IsNullOrWhiteSpace($FabricConfig.TenantIdGlobal) -or 
            [string]::IsNullOrWhiteSpace($FabricConfig.TokenExpiresOn)) {
            Write-Log -Message "Token expiration details are missing. Please run 'Set-FabricHeaders' to configure them." -Level Error
            throw "ConfigurationException: Missing token details in the FabricConfig object."
        }

        # Convert the TokenExpiresOn value to a DateTime object
        $tokenExpiryDate = [datetimeoffset]::Parse($FabricConfig.TokenExpiresOn)

        # Check if the token is expired
        if ($tokenExpiryDate -le [datetimeoffset]::Now) {
            Write-Log -Message "Your authentication token has expired. Please sign in again to refresh your session." -Level Warning
            #throw "TokenExpiredException: Token has expired."
            Set-FabricHeaders -tenantId $FabricConfig.TenantIdGlobal
        }

        # Log valid token status
        Write-Log -Message "Token is still valid. Expiry time: $($tokenExpiryDate.ToString("u"))" -Level Info
    } catch [System.FormatException] {
        Write-Log -Message "Invalid 'TokenExpiresOn' format in the FabricConfig object. Ensure it is a valid datetime string." -Level Error
        throw "FormatException: Invalid TokenExpiresOn value."
    } catch {
        # Log unexpected errors with details
        Write-Log -Message "An unexpected error occurred: $_" -Level Error
        throw $_
    }
}
