<#
.SYNOPSIS
Assigns workspaces to a specified domain in Microsoft Fabric by their IDs.

.DESCRIPTION
The `Assign-FabricDomainWorkspaceById` function sends a request to assign multiple workspaces to a specified domain using the provided domain ID and an array of workspace IDs.

.PARAMETER DomainId
The ID of the domain to which workspaces will be assigned. This parameter is mandatory.

.PARAMETER WorkspaceIds
An array of workspace IDs to be assigned to the domain. This parameter is mandatory.

.EXAMPLE
Assign-FabricDomainWorkspaceById -DomainId "12345" -WorkspaceIds @("ws1", "ws2", "ws3")

Assigns the workspaces with IDs "ws1", "ws2", and "ws3" to the domain with ID "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- The function ensures token validity before making API requests.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Assign-FabricDomainWorkspaceById {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]$WorkspaceIds
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}/assignWorkspaces" -f $FabricConfig.BaseUrl, $DomainId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info
        
        # Construct the request body
        $body = @{
            workspacesIds = $WorkspaceIds
        }
      
        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 2
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Handle response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            Write-Message -Message "Successfully assigned workspaces to the domain with ID '$DomainId'." -Level Info
        } else {
            Write-Message -Message "Unexpected response code: $responseCode while assigning workspaces to the domain." -Level Error
        }
    }
    catch {
        # Log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to assign workspaces to the domain with ID '$DomainId'. Error: $errorDetails" -Level Error
    }
}
