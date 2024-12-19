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

function Get-FabricWorkspace2 {
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
        #$response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders 
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Get -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        #$responseCode = $response.StatusCode
        #Debug
        #Write-Message -Message "Response Code: $responseCode" -Level Info

        if ($statusCode -eq 200) {
            # Parse the response
            $data = $response.value #| ConvertFrom-Json

            # Filter results based on provided parameters
            $workspace = if ($WorkspaceId) {
                $data | Where-Object { $_.Id -eq $WorkspaceId }
            }
            elseif ($WorkspaceName) {
                $data | Where-Object { $_.DisplayName -eq $WorkspaceName }
            }
            else {
                # Return all workspaces if no filter is provided
                Write-Message -Message "No filter provided. Returning all workspaces." -Level Info
                return $data
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
            Write-Message -Message "Unexpected response code: $statusCode from the API." -Level Error
            Write-Host "HTTP Error: $($response.message)"
            Write-Host "Error Code: $($response.errorCode)"
            throw
        }
    }
    catch {
        # Handle and log errors
        #$errorDetails = Get-ErrorResponse($_.Exception)
        #Write-Message -Message "Failed to retrieve workspace. Error: errorDetails" -Level Error
        write-host $_.Exception.Message
    }
}


get-fabricworkspace2