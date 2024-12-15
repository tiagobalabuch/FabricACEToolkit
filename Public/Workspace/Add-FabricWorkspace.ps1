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
- Requires the `$FabricConfig` global object, including `BaseUrl` and `FabricHeaders`.
- Calls `Is-TokenExpired` to ensure the token is valid before making the API request.
- Logs each step of the operation for debugging and monitoring purposes.

Author: Tiago Balabuch
Date: 2024-12-12
#>

function Add-FabricWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$WorkspaceName
    )

    try {
        # Check if the token is expired
        Is-TokenExpired
        
        # Construct the API URL
        $apiEndpointUrl = "{0}/workspaces" -f $FabricConfig.BaseUrl
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Info

        # Define the workspace body
        $body = @{
            displayName = $WorkspaceName
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json
        
        #Write-Message -Message "Request Body: $bodyJson" -Level Info

        # Make the API request
        $response = Invoke-WebRequest -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop

        # Parse and log the response
        $responseCode = $response.StatusCode

        #Write-Message -Message "Response Code: $responseCode" -Level Info
        
        $data = $response.Content | ConvertFrom-Json

        if ($responseCode -eq 201) {
            # Handle successful creation of workspace
            if ($data) {
                Write-Message -Message "Workspace '$WorkspaceName' created successfully!" -Level Info
                return $data
            }
            else {
                Write-Message -Message "No workspace data returned in the response." -Level Warning
                return @()
            }
        }
        else {
            Write-Message -Message "Unexpected response code: $responseCode" -Level Error
            return $null
        }
    }
    catch {
        # Handle and log errors
        #$errorDetails = Get-ErrorResponse($_.Exception)
        Write-Message -Message "Failed to create workspace. Error: $_.Exception" -Level Error
        
    }
}
