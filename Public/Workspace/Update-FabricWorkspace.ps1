<#
.SYNOPSIS
Updates the properties of a Fabric workspace.

.DESCRIPTION
The `Update-FabricWorkspace` function updates the name and/or description of a specified Fabric workspace by making a PATCH request to the API.

.PARAMETER WorkspaceId
The unique identifier of the workspace to be updated.

.PARAMETER WorkspaceName
The new name for the workspace.

.PARAMETER WorkspaceDescription
(Optional) The new description for the workspace.

.EXAMPLE
Update-FabricWorkspace -WorkspaceId "workspace123" -WorkspaceName "NewWorkspaceName"

Updates the name of the workspace with the ID "workspace123" to "NewWorkspaceName".

.EXAMPLE
Update-FabricWorkspace -WorkspaceId "workspace123" -WorkspaceName "NewName" -WorkspaceDescription "Updated description"

Updates both the name and description of the workspace "workspace123".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function Update-FabricWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceDescription
    )

    try {
        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Define the request body
        $body = @{
            displayName = $WorkspaceName
        }

        if ($WorkspaceDescription) {
            $body.description = $WorkspaceDescription
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json
        
        #Write-Message -Message "Request Body: $bodyJson" -Level Info
        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Patch -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200 -or $responseCode -eq 204) {
            Write-Message -Message "Workspace '$WorkspaceName' updated successfully!" -Level Info

            if ($response.Content) {
                $data = $response.Content | ConvertFrom-Json
                return $data
            } else {
                Write-Message -Message "No content returned in the response. Update assumed successful." -Level Info
                return $null
            }
        } else {
            Write-Message -Message "Unexpected response code: $responseCode during update." -Level Error
            return $null
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to update workspace. Error: $errorDetails" -Level Error
        #throw "Error updating workspace: $errorDetails"
    }
}
