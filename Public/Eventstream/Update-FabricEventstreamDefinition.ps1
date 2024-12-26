<#
.SYNOPSIS
Updates the definition of a Eventstream in a Microsoft Fabric workspace.

.DESCRIPTION
This function allows updating the content or metadata of a Eventstream in a Microsoft Fabric workspace. 
The Eventstream content can be provided as file paths, and metadata updates can optionally be enabled.

.PARAMETER WorkspaceId
(Mandatory) The unique identifier of the workspace where the Eventstream resides.

.PARAMETER EventstreamId
(Mandatory) The unique identifier of the Eventstream to be updated.

.PARAMETER EventstreamPathDefinition
(Mandatory) The file path to the Eventstream content definition file. The content will be encoded as Base64 and sent in the request.

.PARAMETER EventstreamPathPlatformDefinition
(Optional) The file path to the Eventstream's platform-specific definition file. The content will be encoded as Base64 and sent in the request.

.PARAMETER UpdateMetadata
(Optional)A boolean flag indicating whether to update the Eventstream's metadata. 
Default: `$false`.

.EXAMPLE
Update-FabricEventstreamDefinition -WorkspaceId "12345" -EventstreamId "67890" -EventstreamPathDefinition "C:\Eventstreams\Eventstream.ipynb"

Updates the content of the Eventstream with ID `67890` in the workspace `12345` using the specified Eventstream file.

.EXAMPLE
Update-FabricEventstreamDefinition -WorkspaceId "12345" -EventstreamId "67890" -EventstreamPathDefinition "C:\Eventstreams\Eventstream.ipynb" -UpdateMetadata $true

Updates both the content and metadata of the Eventstream with ID `67890` in the workspace `12345`.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- The Eventstream content is encoded as Base64 before being sent to the Fabric API.
- This function handles asynchronous operations and retrieves operation results if required.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Update-FabricEventstreamDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EventstreamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EventstreamPathDefinition,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$EventstreamPathPlatformDefinition
    )

    try {
        # Step 1: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/eventstreams/{2}/updateDefinition" -f $FabricConfig.BaseUrl, $WorkspaceId, $EventstreamId

        if($EventstreamPathPlatformDefinition){
            $apiEndpointUrl = "?updateMetadata=true" -f $apiEndpointUrl 
        }
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Construct the request body
        $body = @{
            definition = @{
                format = "eventstream"
                parts  = @()
            } 
        }
      
        if ($EventstreamPathDefinition) {
            $EventstreamEncodedContent = Encode-ToBase64 -filePath $EventstreamPathDefinition
            
            if (-not [string]::IsNullOrEmpty($EventstreamEncodedContent)) {
                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = "eventstream.json"
                    payload     = $EventstreamEncodedContent
                    payloadType = "InlineBase64"
                }
            }
            else {
                Write-Message -Message "Invalid or empty content in Eventstream definition." -Level Error
                return $null
            }
        }

        if ($EventstreamPathPlatformDefinition) {
            $EventstreamEncodedPlatformContent = Encode-ToBase64 -filePath $EventstreamPathPlatformDefinition
            if (-not [string]::IsNullOrEmpty($EventstreamEncodedPlatformContent)) {
                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = ".platform"
                    payload     = $EventstreamEncodedPlatformContent
                    payloadType = "InlineBase64"
                }
            }
            else {
                Write-Message -Message "Invalid or empty content in platform definition." -Level Error
                return $null
            }
        }

        $bodyJson = $body | ConvertTo-Json -Depth 10
        Write-Message -Message "Request Body: $bodyJson" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Post `
            -Body $bodyJson `
            -ContentType "application/json" `
            -ErrorAction Stop `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"
       
        # Step 5: Handle and log the response
        switch ($statusCode) {
            200 {
                Write-Message -Message "Update definition for Eventstream '$EventstreamId' created successfully!" -Level Info
                return $response
            }
            202 {
                Write-Message -Message "Update definition for Eventstream '$EventstreamId' accepted. Operation in progress!" -Level Info
                [string]$operationId = $responseHeader["x-ms-operation-id"]
                $operationResult = Get-FabricLongRunningOperation -operationId $operationId

                # Handle operation result
                if ($operationResult.status -eq "Succeeded") {
                    Write-Message -Message "Operation Succeeded" -Level Debug
                    
                    $result = Get-FabricLongRunningOperationResult -operationId $operationId
                    return $result.definition.parts
                }
                else {
                    Write-Message -Message "Operation Failed" -Level Debug
                    return $operationResult.definition.parts
                }   
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
        Write-Message -Message "Failed to update Eventstream. Error: $errorDetails" -Level Error
    }
}
