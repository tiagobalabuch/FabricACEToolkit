<#
.SYNOPSIS
Bulk unUnassign roles to principals for workspaces in a Fabric domain.

.DESCRIPTION
The `AssignFabricDomainWorkspaceRoleAssignment` function performs bulk role assignments for principals in a specific Fabric domain. It sends a POST request to the relevant API endpoint.

.PARAMETER DomainId
The unique identifier of the Fabric domain where roles will be assigned.

.PARAMETER DomainRole
The role to assign to the principals. Must be one of the following:
- `Admins`
- `Contributors`

.PARAMETER PrincipalIds
An array of principals to assign roles to. Each principal must include:
- `id`: The identifier of the principal.
- `type`: The type of the principal (e.g., `User`, `Group`).

.EXAMPLE
AssignFabricDomainWorkspaceRoleAssignment -DomainId "12345" -DomainRole "Admins" -PrincipalIds @(@{id="user1"; type="User"}, @{id="group1"; type="Group"})

Unassign the `Admins` role to the specified principals in the domain with ID "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure token validity before making the API request.
- Validates that each principal contains both `id` and `type` properties.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Unassign-FabricDomainWorkspaceRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Admins', 'Contributors')]
        [string]$DomainRole,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]$PrincipalIds # Array of hashtables with 'id' and 'type'
    )

    try {
        # Validate PrincipalIds structure
        foreach ($principal in $PrincipalIds) {
            if (-not ($principal.id -and $principal.type)) {
                throw "Invalid principal detected: Each principal must include 'id' and 'type' properties. Found: $principal"
            }
        }

        #Ensure the API token is valid
        Is-TokenExpired

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}/roleAssignments/bulkUnassign" -f $FabricConfig.BaseUrl, $DomainId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Construct the JSON body
        $body = @{
            type = $DomainRole
            principals = $PrincipalIds
        }
        $bodyJson = $body | ConvertTo-Json -Depth 2
        Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        #Write-Message -Message "Sending API request for bulk role unassignment..." -Level Info
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Handle the API response
        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            Write-Message -Message "Bulk role unassignment for domain '$DomainId' completed successfully!" -Level Info
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while performing bulk role unassignment." -Level Error
        }
    }
    catch {
        # Log detailed error information
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to bulk assign roles in domain '$DomainId'. Error: $errorDetails" -Level Error
    }
}