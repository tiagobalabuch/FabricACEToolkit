<#
.SYNOPSIS
Retrieves role assignments for a specified Fabric workspace.

.DESCRIPTION
The `Get-FabricWorkspaceRoleAssignment` function fetches the role assignments associated with a Fabric workspace by making a GET request to the API.

.PARAMETER WorkspaceId
The unique identifier of the workspace to fetch role assignments for.

.EXAMPLE
Get-FabricWorkspaceRoleAssignment -WorkspaceId "workspace123"

Fetches the role assignments for the workspace with the ID "workspace123".

.NOTES
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.
- Returns the role assignments as a parsed JSON object.

Author: Tiago Balabuch  
Date: 2024-12-13
#>

function Get-FabricWorkspaceRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId
    )

    try {
        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $roleAssignmentsUrl = "{0}/workspaces/{1}/roleAssignments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $roleAssignmentsUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $roleAssignmentsUrl -Method Get -ErrorAction Stop

        # Validate and parse the response
        if (-not $response.Content) {
            Write-Message -Message "No content returned from the API for WorkspaceId '$WorkspaceId'." -Level Warning
            return @()
        }

        $responseCode = $response.StatusCode
        Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            # Parse the response JSON
            $data = $response.Content | ConvertFrom-Json
            Write-Message -Message "Successfully retrieved role assignments for WorkspaceId '$WorkspaceId'." -Level Info
            return $data
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode while fetching role assignments." -Level Error
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to retrieve role assignments for WorkspaceId '$WorkspaceId'. Error: $errorDetails" -Level Error
        throw "Error retrieving role assignments: $errorDetails"
    }
}
