<#
.SYNOPSIS
Deletes a Fabric domain by its ID.

.DESCRIPTION
The `Remove-FabricDomain` function removes a specified domain from Microsoft Fabric by making a DELETE request to the relevant API endpoint.

.PARAMETER DomainId
The unique identifier of the domain to be deleted.

.EXAMPLE
Remove-FabricDomain -DomainId "12345"

Deletes the domain with ID "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Remove-FabricDomain {
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

        if($WorkspaceIds -ne $null) {
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
        $responseCode = $response.StatusCode
        #SWrite-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            Write-Message -Message "Unassign workspaces from the specified domain by workspace ID completed successfully!" -Level Info
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode while attempting to delete domain '$DomainId'." -Level Error
        }
    }
    catch {
        # Capture detailed error information
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to delete domain '$DomainId'. Error: $errorDetails" -Level Error
        #throw "Error deleting domain: $errorDetails"
    }
}
