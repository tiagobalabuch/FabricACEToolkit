<#
.SYNOPSIS
Creates a new Fabric workspace with the specified display name.

.DESCRIPTION
The `Add-FabricWorkspace` function creates a new workspace in the Fabric platform by sending a POST request to the API. It validates the display name and handles both success and error responses.

.PARAMETER WorkspaceName
The display name of the workspace to be created. Must only contain alphanumeric characters, spaces, and underscores.

.EXAMPLE
Add-FabricWorkspace -WorkspaceName "NewWorkspace"

Creates a workspace named "NewWorkspace".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch
Date: 2024-12-12
#>

function Add-FabricWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceDescription,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$CapacityId
    )

    try {
        # Step 1: Ensure token validity
        #Write-Message -Message "Validating token..." -Level Info
        Test-TokenExpired
        #Write-Message -Message "Token validation completed." -Level Info

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Message

        # Step 3: Construct the request body
        $body = @{
            displayName = $WorkspaceName
        }

        if ($WorkspaceDescription) {
            $body.description = $WorkspaceDescription
        }

        if ($CapacityId) {
            $body.capacityId = $CapacityId
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 2
        #Write-Message -Message "Request Body: $bodyJson" -Level Message

        # Step 4: Make the API request
        Write-Message -Message "Sending API request to create Workspace '$WorkspaceName'..." -Level Message
        $response = Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"

        # Step 5: Handle and log the response
        switch ($statusCode) {
            201 {
                Write-Message -Message "Workspace '$WorkspaceName' created successfully!" -Level Info
                return $response.value
            }
            202 {
                Write-Message -Message "Workspace '$WorkspaceName' creation accepted. Provisioning in progress!" -Level Info
                return $response.value
            }
            default {
                Write-Message -Message "Unexpected response code: $statusCode" -Level Error
                Write-Message -Message "Error details: $($response.message)" -Level Error
                throw "API request failed with status code $statusCode."
            }
        }
    }
    catch {
        # Step 6: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to create workspace. Error: $errorDetails" -Level Error
        
    }
}
