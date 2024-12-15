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
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.
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
        # Handle ambiguous input
        if ($WorkspaceId -and $WorkspaceName) {
            Write-Message -Message "Both 'WorkspaceId' and 'WorkspaceName' were provided. Please specify only one." -Level Error
            return @()
        }

        # Check if the token is expired
        Is-TokenExpired

        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop

        # Validate the response
        if (-not $response.Content) {
            Write-Message -Message "Empty response from the API." -Level Warning
            return @()
        }

        $responseCode = $response.StatusCode
        #Debug
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($responseCode -eq 200) {
            # Parse the response
            $data = $response.Content | ConvertFrom-Json

            # Filter results based on provided parameters
            $workspace = if ($WorkspaceId) {
                $data.value | Where-Object { $_.Id -eq $WorkspaceId }
            }
            elseif ($WorkspaceName) {
                $data.value | Where-Object { $_.DisplayName -eq $WorkspaceName }
            }
            else {
                # Return all workspaces if no filter is provided
                Write-Message -Message "No filter provided. Returning all workspaces." -Level Info
                return $data.value
            }

            if ($workspace) {
                return $workspace
            }
            else {
                Write-Message -Message "No workspace found matching the provided criteria." -Level Warning
                return $null
            }
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode from the API." -Level Error
            return @()
        }
    }
    catch {
        # Handle and log errors
        $errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to retrieve workspace. Error: $errorDetails" -Level Error
        #throw "Error retrieving workspace details: $errorDetails"
    }
}
