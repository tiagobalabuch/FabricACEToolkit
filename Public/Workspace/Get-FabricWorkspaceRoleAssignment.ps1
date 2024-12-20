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
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

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
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/roleAssignments" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 4: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }
        
        # Step 5: Handle empty response
        if (-not $response.value) {
            Write-Message -Message "No data returned from the API." -Level Warning
            return @()
        }

        # Step 7: Filter results based on provided parameters
        $roleAssignments = if ($WorkspaceRoleAssignmentId) {
            $response.value | Where-Object { $_.Id -eq $WorkspaceRoleAssignmentId }
        }
        else {
            $response.value
        }

        # Step 8: Handle results
        if ($roleAssignments) {
            Write-Message -Message "Found $($roleAssignments.Count) role assignments for WorkspaceId '$WorkspaceId'." -Level Message
            # Transform data into custom objects
            $results = foreach ($obj in $roleAssignments) {
                [PSCustomObject]@{
                    ID                = $obj.id
                    PrincipalId       = $obj.principal.id
                    DisplayName       = $obj.principal.displayName
                    Type              = $obj.principal.type
                    UserPrincipalName = $obj.principal.userDetails.userPrincipalName
                    aadAppId          = $obj.principal.servicePrincipalDetails.aadAppId
                    Role              = $obj.role
                }
            }
            return $results
        }
        else {
            if ($WorkspaceRoleAssignmentId) {
                Write-Message -Message "No role assignment found with ID '$WorkspaceRoleAssignmentId' for WorkspaceId '$WorkspaceId'." -Level Warning
            }
            else {
                Write-Message -Message "No role assignments found for WorkspaceId '$WorkspaceId'." -Level Warning
            }
            return @()
        }
            
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve role assignments for WorkspaceId '$WorkspaceId'. Error: $errorDetails" -Level Error
    }
}
