
<#
.SYNOPSIS
Unassign workspaces from a specified Fabric domain.

.DESCRIPTION
The `Unassign -FabricDomainWorkspace` function allows you to Unassign  specific workspaces from a given Fabric domain or unassign all workspaces if no workspace IDs are specified. 
It makes a POST request to the relevant API endpoint for this operation.

.PARAMETER DomainId
The unique identifier of the Fabric domain.

.PARAMETER WorkspaceIds
(Optional) An array of workspace IDs to unassign. If not provided, all workspaces will be unassigned.

.EXAMPLE
Unassign -FabricDomainWorkspace -DomainId "12345"

Unassigns all workspaces from the domain with ID "12345".

.EXAMPLE
Unassign -FabricDomainWorkspace -DomainId "12345" -WorkspaceIds @("workspace1", "workspace2")

Unassigns the specified workspaces from the domain with ID "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure token validity before making the API request.

.MODIFICATIONS
- Added enhanced logging and error handling.
- Made the function modular for better reusability.
- Improved parameter validation.
- Detailed comment-based help.

Author: Tiago Balabuch  
Date: 2024-12-15
#>
function Unassign -FabricDomainWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainId,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [array]$WorkspaceIds
    )

    try {
        # Ensure token validity
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/admin/domains/{1}/unassignAllWorkspaces" -f $FabricConfig.BaseUrl, $DomainId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        $bodyJson = $null
        if(($WorkspaceIds -and $WorkspaceIds.Count -gt 0)) {
            # Construct the request body
            $body = @{
                workspacesIds = $WorkspaceIds
            }

            # Convert the body to JSON
            $bodyJson = $body | ConvertTo-Json -Depth 2
            #Write-Message -Message "Request Body: $bodyJson" -Level Info

            # Make the API request
            $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop
        }
        else {
        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post
        }

        # Handle response
        #$responseCode = $response.StatusCode
        #SWrite-Message -Message "Response Code: $responseCode" -Level Info

        # Handle the response
        if ($response.StatusCode -eq 200) {
            if ($WorkspaceIds) {
             Write-Message -Message "Successfully unassigned specified workspaces from domain '$DomainId'." -Level Info
            } else {
                Write-Message -Message "Successfully unassigned all workspaces from domain '$DomainId'." -Level Info
            }
        } else {
            Write-Message -Message "Unexpected response code: $($response.StatusCode) while processing domain '$DomainId'." -Level Error
        }
    }
    catch {
        # Capture detailed error information
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to unassign workspaces from domain '$DomainId'. Error: $errorDetails" -Level Error
        #throw "Error deleting domain: $errorDetails"
    }
}
