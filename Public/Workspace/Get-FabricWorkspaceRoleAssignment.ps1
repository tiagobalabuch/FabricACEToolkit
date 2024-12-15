<#
.SYNOPSIS
Retrieves role assignments for a specified Fabric workspace.

.DESCRIPTION
The `Get-FabricWorkspaceRoleAssignments` function fetches the role assignments associated with a Fabric workspace by making a GET request to the API. If `WorkspaceRoleAssignmentId` is provided, it retrieves the specific role assignment.

.PARAMETER WorkspaceId
The unique identifier of the workspace to fetch role assignments for.

.PARAMETER WorkspaceRoleAssignmentId
(Optional) The unique identifier of a specific role assignment to retrieve.

.EXAMPLE
Get-FabricWorkspaceRoleAssignments -WorkspaceId "workspace123"

Fetches all role assignments for the workspace with the ID "workspace123".

.EXAMPLE
Get-FabricWorkspaceRoleAssignments -WorkspaceId "workspace123" -WorkspaceRoleAssignmentId "role123"

Fetches the role assignment with the ID "role123" for the workspace "workspace123".

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
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceRoleAssignmentId
    )

    try {
        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/roleAssignments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop

        # Validate and parse the response
        if (-not $response.Content) {
            Write-Message -Message "No content returned from the API for WorkspaceId '$WorkspaceId'." -Level Warning
            return @()
        }

        $responseCode = $response.StatusCode
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            # Parse the response JSON
            $data = $response.Content | ConvertFrom-Json
            #Write-Message -Message "Successfully retrieved role assignments for WorkspaceId '$WorkspaceId'." -Level Info

            if (-not $data.value) {
                Write-Message -Message "No role assignments found for WorkspaceId '$WorkspaceId'." -Level Warning
                return @()
            }

            # Filter results if WorkspaceRoleAssignmentId is provided
            $roleAssignments = if ($WorkspaceRoleAssignmentId) {
                $data.value | Where-Object { $_.Id -eq $WorkspaceRoleAssignmentId }
            } else {
                $data.value
            }
            
            if ($roleAssignments) {
                Write-Message -Message "Found $($roleAssignments.Count) role assignments for WorkspaceId '$WorkspaceId'." -Level Info
                # Transform data into custom objects
                $results = foreach ($obj in $roleAssignments) {
                    [PSCustomObject]@{
                        ID                 = $obj.id
                        PrincipalId        = $obj.principal.id
                        DisplayName        = $obj.principal.displayName
                        Type               = $obj.principal.type
                        UserPrincipalName  = $obj.principal.userDetails.userPrincipalName
                        aadAppId           = $obj.principal.servicePrincipalDetails.aadAppId
                        Role               = $obj.role
                    }
                }

                return $results
            } else {
                if($WorkspaceRoleAssignmentId) {
                    Write-Message -Message "No role assignment found with ID '$WorkspaceRoleAssignmentId' for WorkspaceId '$WorkspaceId'." -Level Warning
                }
                else {
                    Write-Message -Message "No role assignments found for WorkspaceId '$WorkspaceId'." -Level Warning
                }
                return @()
            }
            
        } else {
            Write-Message -Message "Unexpected response code: $responseCode from the API." -Level Error
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to retrieve role assignments for WorkspaceId '$WorkspaceId'. Error: $errorDetails" -Level Error
        #throw "Error retrieving role assignments: $errorDetails"
    }
}
