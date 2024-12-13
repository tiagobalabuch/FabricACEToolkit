function Set-FabricHeaders {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId
    )

    try {
        Write-Host "Logging in to Azure tenant: $TenantId"
        Connect-AzAccount -Tenant $TenantId -ErrorAction Stop | Out-Null

        $fabricToken = Get-AzAccessToken -AsSecureString -ResourceUrl $FabricConfig.ResourceUrl -ErrorAction Stop
        $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($fabricToken.Token)
        )
    
        $FabricConfig.FabricHeaders = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer {0}" -f $plainToken
        }
        
        $FabricConfig.TokenExpiresOn = $fabricToken.ExpiresOn
        $FabricConfig.TenantIdGlobal = $TenantId

        Write-Host "Fabric headers successfully set version 2." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to set Fabric headers: $($_.Exception.Message)"
    }
}

