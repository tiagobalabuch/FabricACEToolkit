<#
.SYNOPSIS
Updates the definition of a Eventhouse in a Microsoft Fabric workspace.

.DESCRIPTION
This function allows updating the content or metadata of a Eventhouse in a Microsoft Fabric workspace. 
The Eventhouse content can be provided as file paths, and metadata updates can optionally be enabled.

.PARAMETER WorkspaceId
(Mandatory) The unique identifier of the workspace where the Eventhouse resides.

.PARAMETER EventhouseId
(Mandatory) The unique identifier of the Eventhouse to be updated.

.PARAMETER EventhousePathDefinition
(Mandatory) The file path to the Eventhouse content definition file. The content will be encoded as Base64 and sent in the request.

.PARAMETER EventhousePathPlatformDefinition
(Optional) The file path to the Eventhouse's platform-specific definition file. The content will be encoded as Base64 and sent in the request.

.PARAMETER UpdateMetadata
(Optional)A boolean flag indicating whether to update the Eventhouse's metadata. 
Default: `$false`.

.EXAMPLE
Update-FabricEventhouseDefinition -WorkspaceId "12345" -EventhouseId "67890" -EventhousePathDefinition "C:\Eventhouses\Eventhouse.json"

Updates the content of the Eventhouse with ID `67890` in the workspace `12345` using the specified Eventhouse file.

.EXAMPLE
Update-FabricEventhouseDefinition -WorkspaceId "12345" -EventhouseId "67890" -EventhousePathDefinition "C:\Eventhouses\Eventhouse.json" -UpdateMetadata $true

Updates both the content and metadata of the Eventhouse with ID `67890` in the workspace `12345`.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- The Eventhouse content is encoded as Base64 before being sent to the Fabric API.
- This function handles asynchronous operations and retrieves operation results if required.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Update-FabricEventhouseDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EventhouseId,

        [Parameter(Mandatory = $true)]
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
        $apiEndpointUrl = "{0}/workspaces/{1}/eventhouses/{2}/updateDefinition" -f $FabricConfig.BaseUrl, $WorkspaceId, $EventhouseId

        #if ($UpdateMetadata -eq $true) {
        if($EventhousePathPlatformDefinition){
            $apiEndpointUrl = "?updateMetadata=true" -f $apiEndpointUrl 
        }
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Construct the request body
        $body = @{
            definition = @{
                parts  = @()
            } 
        }
      
        if ($EventhousePathDefinition) {
            $EventhouseEncodedContent = Encode-ToBase64 -filePath $EventhousePathDefinition
            
            if (-not [string]::IsNullOrEmpty($EventhouseEncodedContent)) {
                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = "EventhouseProperties.json"
                    payload     = $EventhouseEncodedContent
                    payloadType = "InlineBase64"
                }
            }
            else {
                Write-Message -Message "Invalid or empty content in Eventhouse definition." -Level Error
                return $null
            }
        }

        if ($EventhousePathPlatformDefinition) {
            $EventhouseEncodedPlatformContent = Encode-ToBase64 -filePath $EventhousePathPlatformDefinition
            if (-not [string]::IsNullOrEmpty($EventhouseEncodedPlatformContent)) {
                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = ".platform"
                    payload     = $EventhouseEncodedPlatformContent
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
                Write-Message -Message "Update definition for Eventhouse '$EventhouseId' created successfully!" -Level Info
                return $response
            }
            202 {
                Write-Message -Message "Update definition for Eventhouse '$EventhouseId' accepted. Operation in progress!" -Level Info
                [string]$operationId = $responseHeader["x-ms-operation-id"]
                $operationResult = Get-FabricLongRunningOperation -operationId $operationId

                # Handle operation result
                if ($operationResult.status -eq "Succeeded") {
                    Write-Message -Message "Operation Succeeded" -Level Debug
                    
                    $result = Get-FabricLongRunningOperationResult -operationId $operationId
                    return $result
                }
                else {
                    Write-Message -Message "Operation Failed" -Level Debug
                    return $operationResult
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
        Write-Message -Message "Failed to update Eventhouse. Error: $errorDetails" -Level Error
    }
}
