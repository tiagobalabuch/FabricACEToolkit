<#
.SYNOPSIS
Creates a new Eventhouse in a specified workspace.

.DESCRIPTION
The `Add-FabricEventhouse` function sends a POST request to the Fabric API to create a new Eventhouse in the specified workspace. The function allows specifying an optional description for the Eventhouse.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace where the Eventhouse will be created.

.PARAMETER EventhouseName
(Mandatory) The name of the Eventhouse to be created. Only alphanumeric characters, spaces, and underscores are allowed.

.PARAMETER EventhouseDescription
(Optional) A description of the Eventhouse.

.EXAMPLE
Add-FabricEventhouse -WorkspaceId "12345" -EventhouseName "MainEvents" -EventhouseDescription "Handles core event streaming."

Creates an Eventhouse named "MainEvents" in workspace "12345" with the provided description.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Ensures token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function New-FabricEventhouse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$EventhouseName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EventhouseDescription,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EventhousePathDefinition,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EventhousePathPlatformDefinition
    )

    try {
        # Step 1: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/eventhouses" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Construct the request body
        $body = @{
            displayName = $EventhouseName
        }

        if ($EventhouseDescription) {
            $body.description = $EventhouseDescription
        }
        if ($EventhousePathDefinition) {
            $eventhouseEncodedContent = Encode-ToBase64 -filePath $EventhousePathDefinition

            if (-not [string]::IsNullOrEmpty($eventhouseEncodedContent)) {
                # Initialize definition if it doesn't exist
                if (-not $body.definition) {
                    $body.definition = @{
                        parts  = @()
                    }
                }

                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = "EventhouseProperties.json"
                    payload     = $eventhouseEncodedContent
                    payloadType = "InlineBase64"
                }
            }
            else {
                Write-Message -Message "Invalid or empty content in Eventhouse definition." -Level Error
                return $null
            }
        }

        if ($EventhousePathPlatformDefinition) {
            $eventhouseEncodedPlatformContent = Encode-ToBase64 -filePath $EventhousePathPlatformDefinition

            if (-not [string]::IsNullOrEmpty($eventhouseEncodedPlatformContent)) {
                # Initialize definition if it doesn't exist
                if (-not $body.definition) {
                    $body.definition = @{
                        parts  = @()
                    }
                }

                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = ".platform"
                    payload     = $eventhouseEncodedPlatformContent
                    payloadType = "InlineBase64"
                }
            }
            else {
                Write-Message -Message "Invalid or empty content in platform definition." -Level Error
                return $null
            }
        }

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 2
        Write-Message -Message "Request Body: $bodyJson" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Post `
            -Body $bodyJson `
            -ContentType "application/json" `
            -ErrorAction Stop `
            -SkipHttpErrorCheck `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"
        
        Write-Message -Message "Response Code: $statusCode" -Level Debug
  
        # Step 5: Handle and log the response
        switch ($statusCode) {
            201 {
                Write-Message -Message "Eventhouse '$EventhouseName' created successfully!" -Level Info
                return $response
            }
            202 {
                Write-Message -Message "Eventhouse '$EventhouseName' creation accepted. Provisioning in progress!" -Level Info
                [string]$operationId = $responseHeader["x-ms-operation-id"]
                Write-Message -Message "Operation ID: '$operationId'" -Level Debug
                Write-Message -Message "Getting Long Running Operation status" -Level Debug
               
                $operationStatus = Get-FabricLongRunningOperation -operationId $operationId
                Write-Message -Message "Long Running Operation status: $operationStatus" -Level Debug
                # Handle operation result
                if ($operationStatus.status -eq "Succeeded") {
                    Write-Message -Message "Operation Succeeded" -Level Debug
                    Write-Message -Message "Getting Long Running Operation result" -Level Debug
                
                    $operationResult = Get-FabricLongRunningOperationResult -operationId $operationId
                    Write-Message -Message "Long Running Operation status: $operationResult" -Level Debug
                
                    return $operationResult
                } 
                #return $response.value
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
        Write-Message -Message "Failed to create Eventhouse. Error: $errorDetails" -Level Error
    }
}
