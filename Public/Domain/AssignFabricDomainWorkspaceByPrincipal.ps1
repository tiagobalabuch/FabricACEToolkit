<#
.SYNOPSIS
Assigns workspaces to a domain based on principal IDs in Microsoft Fabric.

.DESCRIPTION
The `Assign-FabricDomainWorkspaceByPrincipal` function sends a request to assign workspaces to a specified domain using a JSON object of principal IDs and types.

.PARAMETER DomainId
The ID of the domain to which workspaces will be assigned. This parameter is mandatory.

.PARAMETER PrincipalIds
An array representing the principals with their `id` and `type` properties. Must contain a `principals` key with an array of objects.

.EXAMPLE
$principals = @{
    principals = @(
        @{ id = "user1"; type = "User" },
        @{ id = "group1"; type = "Group" }
    )
}
Assign-FabricDomainWorkspaceByPrincipal -DomainId "12345" -PrincipalIds $principals

Assigns the workspaces based on the provided principal IDs and types.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Ensures token validity before making API requests.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Assign-FabricDomainWorkspaceByPrincipal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$PrincipalIds # Must contain a JSON array of principals with 'id' and 'type' properties
    )

    try {
        # Validate PrincipalIds structure
        if (-not $PrincipalIds.ContainsKey('principals')) {
            throw "The PrincipalIds parameter must contain a 'principals' key."
        }

        # Ensure each principal contains 'id' and 'type'
        foreach ($principal in $PrincipalIds['principals']) {
            if (-not ($principal.ContainsKey('id') -and $principal.ContainsKey('type'))) {
                throw "Each principal object must contain 'id' and 'type' properties."
            }
        }

        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}/assignWorkspacesByPrincipals" -f $FabricConfig.BaseUrl, $DomainId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Convert the PrincipalIds to JSON
        $bodyJson = $PrincipalIds | ConvertTo-Json -Depth 2
        Write-Message -Message "Request Body: $bodyJson" -Level Debug

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Handle response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 202) {
            Write-Message -Message "Assigning domain workspaces by principal is in progress!" -Level Info
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while assigning workspaces." -Level Error
        }
    }
    catch {
        # Log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign domain workspaces by principals. Error: $errorDetails" -Level Error
    }
}
