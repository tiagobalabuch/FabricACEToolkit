<#
.SYNOPSIS
Updates the definition of a notebook in a Microsoft Fabric workspace.

.DESCRIPTION
This function allows updating the content or metadata of a notebook in a Microsoft Fabric workspace. 
The notebook content can be provided as file paths, and metadata updates can optionally be enabled.

.PARAMETER WorkspaceId
(Mandatory) The unique identifier of the workspace where the notebook resides.

.PARAMETER NotebookId
(Mandatory) The unique identifier of the notebook to be updated.

.PARAMETER NotebookPathDefinition
(Mandatory) The file path to the notebook content definition file. The content will be encoded as Base64 and sent in the request.

.PARAMETER NotebookPathPlatformDefinition
(Optional) The file path to the notebook's platform-specific definition file. The content will be encoded as Base64 and sent in the request.

.PARAMETER UpdateMetadata
(Optional)A boolean flag indicating whether to update the notebook's metadata. 
Default: `$false`.

.EXAMPLE
Update-FabricNotebookDefinition -WorkspaceId "12345" -NotebookId "67890" -NotebookPathDefinition "C:\Notebooks\Notebook.ipynb"

Updates the content of the notebook with ID `67890` in the workspace `12345` using the specified notebook file.

.EXAMPLE
Update-FabricNotebookDefinition -WorkspaceId "12345" -NotebookId "67890" -NotebookPathDefinition "C:\Notebooks\Notebook.ipynb" -UpdateMetadata $true

Updates both the content and metadata of the notebook with ID `67890` in the workspace `12345`.

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- The notebook content is encoded as Base64 before being sent to the Fabric API.
- This function handles asynchronous operations and retrieves operation results if required.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Update-FabricNotebookDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookPathDefinition,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookPathPlatformDefinition,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$UpdateMetadata = $false
    )

    try {
        # Step 1: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL

        Write-Host 'Variable' $UpdateMetadata

        $apiEndpointUrl = "{0}/workspaces/{1}/notebooks/{2}/updateDefinition" -f $FabricConfig.BaseUrl, $WorkspaceId, $NotebookId
        if ($UpdateMetadata -eq $true) {
            $apiEndpointUrl += "?updateMetadata=true" -f $FabricConfig.BaseUrl, $WorkspaceId, $NotebookId
        }
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Construct the request body
        $body = @{
            definition = @{
                format = "ipynb"
                parts  = @()
            } 
        }
      
        if ($NotebookPathDefinition) {
            $notebookEncodedContent = Encode-ToBase64 -filePath $NotebookPathDefinition
            
            if (-not [string]::IsNullOrEmpty($notebookEncodedContent)) {
                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = "notebook-content.py"
                    payload     = $notebookEncodedContent
                    payloadType = "InlineBase64"
                }
            }
            else {
                Write-Message -Message "Invalid or empty content in notebook definition." -Level Error
                return $null
            }
        }

        if ($NotebookPathPlatformDefinition) {
            $notebookEncodedPlatformContent = Encode-ToBase64 -filePath $NotebookPathPlatformDefinition
            if (-not [string]::IsNullOrEmpty($notebookEncodedPlatformContent)) {
                # Add new part to the parts array
                $body.definition.parts += @{
                    path        = ".platform"
                    payload     = $notebookEncodedPlatformContent
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
            201 {
                Write-Message -Message "Update definition for notebook '$NotebookId' created successfully!" -Level Info
                return $response
            }
            202 {
                Write-Message -Message "Update definition for notebook '$NotebookId' accepted. Operation in progress!" -Level Info
                [string]$operationId = $responseHeader["x-ms-operation-id"]
                $operationResult = Get-FabricLongRunningOperation -operationId $operationId

                # Handle operation result
                if ($operationResult.status -eq "Succeeded") {
                    Write-Message -Message "Operation Succeeded" -Level Debug
                    
                    $result = Get-FabricLongRunningOperationResult -operationId $operationId
                    return $result
                   
                    <#$operationResultUrl = "https://api.fabric.microsoft.com/v1/operations/{0}/result" -f $operationId

                    # Fetch the operation result
                    $resultResponse = Invoke-RestMethod `
                        -Headers $FabricConfig.FabricHeaders `
                        -Uri $operationResultUrl `
                        -Method Get `
                        -ErrorAction Stop
                    # Return the result
                    return $resultResponse.definition.parts
                }#>
                    else {
                        Write-Message -Message "Operation Failed" -Level Debug
                        return $operationResult
                    }   
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
        Write-Message -Message "Failed to update notebook. Error: $errorDetails" -Level Error
    }
}
