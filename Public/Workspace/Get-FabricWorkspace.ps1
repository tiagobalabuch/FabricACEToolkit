<#
.SYNOPSIS
Retrieves details of a Microsoft Fabric workspace by its ID or name.

.DESCRIPTION
The `Get-FabricWorkspace` function fetches workspace details from the Fabric API. It supports filtering by WorkspaceId or WorkspaceName.

.PARAMETER WorkspaceId
The unique identifier of the workspace to retrieve.

.PARAMETER WorkspaceName
The display name of the workspace to retrieve.

.EXAMPLE
Get-FabricWorkspace -WorkspaceId "workspace123"

Fetches details of the workspace with ID "workspace123".

.EXAMPLE
Get-FabricWorkspace -WorkspaceName "MyWorkspace"

Fetches details of the workspace with the name "MyWorkspace".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- Returns the matching workspace details or all workspaces if no filter is provided.

Author: Tiago Balabuch  
Date: 2024-12-13
#>

function Get-FabricWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName
    )

    try {
        # Step 1: Handle ambiguous input
        if ($WorkspaceId -and $WorkspaceName) {
            Write-Message -Message "Both 'WorkspaceId' and 'WorkspaceName' were provided. Please specify only one." -Level Error
            return $null
        }

        # Step 2: Ensure token validity
        Test-TokenExpired

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 4: Make the API request
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
        
        # Step 5: Validate the response code
        if ($statusCode -ne 200) {
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Message -Message "Error: $($response.message)" -Level Error
            Write-Message "Error Code: $($response.errorCode)" -Level Error
            return $null
        }
            
        # Step 6: Handle empty response
        if (-not $response.value) {
            Write-Message -Message "No capacities returned from the API." -Level Warning
            return $null
        }

        # Step 7: Filter results based on provided parameters
        $workspace = if ($WorkspaceId) {
            $response.value | Where-Object { $_.Id -eq $WorkspaceId }
        }
        elseif ($WorkspaceName) {
            $response.value | Where-Object { $_.DisplayName -eq $WorkspaceName }
        }
        else {
            # Return all workspaces if no filter is provided
            Write-Message -Message "No filter provided. Returning all workspaces." -Level Info
            return $response.value
        }
            
        # Step 8: Handle results
        if ($workspace) {
            return $workspace
        }
        else {
            Write-Message -Message "No workspace found matching the provided criteria." -Level Warning
            return $null
        }
    }
    catch {
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve workspace. Error: $errorDetails" -Level Error
    }
}