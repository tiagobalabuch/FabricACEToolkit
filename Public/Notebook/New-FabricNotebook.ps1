<#
.SYNOPSIS
Creates a new notebook in a specified Microsoft Fabric workspace.

.DESCRIPTION
This function sends a POST request to the Microsoft Fabric API to create a new notebook 
in the specified workspace. It supports optional parameters for notebook description 
and path definitions for the notebook content.

.PARAMETER WorkspaceId
The unique identifier of the workspace where the notebook will be created.

.PARAMETER NotebookName
The name of the notebook to be created.

.PARAMETER NotebookDescription
An optional description for the notebook.

.PARAMETER NotebookPathDefinition
An optional path to the notebook definition file (e.g., .ipynb file) to upload.

.PARAMETER NotebookPathPlatformDefinition
An optional path to the platform-specific definition (e.g., .platform file) to upload.

.EXAMPLE
 Add-FabricNotebook -WorkspaceId "workspace-12345" -NotebookName "New Notebook" -NotebookPathDefinition "C:\notebooks\example.ipynb"

 .NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.

Author: Tiago Balabuch  
Date: 2024-12-14
#>

function New-FabricNotebook {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$NotebookName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookDescription,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookPathDefinition,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookPathPlatformDefinition
    )

    try {
        # Step 1: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 2: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/notebooks" -f $FabricConfig.BaseUrl, $WorkspaceId
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 3: Construct the request body
        $body = @{
            displayName = $NotebookName
        }

        if ($NotebookDescription) {
            $body.description = $NotebookDescription
        }

        if ($NotebookPathDefinition) {
            $notebookEncodedContent = Encode-ToBase64 -filePath $NotebookPathDefinition

            if (-not [string]::IsNullOrEmpty($notebookEncodedContent)) {
                # Initialize definition if it doesn't exist
                if (-not $body.definition) {
                    $body.definition = @{
                        format = "ipynb"
                        parts  = @()
                    }
                }

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
                # Initialize definition if it doesn't exist
                if (-not $body.definition) {
                    $body.definition = @{
                        format = "ipynb"
                        parts  = @()
                    }
                }

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
            -SkipHttpErrorCheck `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"

        # Step 5: Handle and log the response
        switch ($statusCode) {
            201 {
                Write-Message -Message "Notebook '$NotebookName' created successfully!" -Level Info
                return $response
            }
            202 {
                Write-Message -Message "Notebook '$NotebookName' creation accepted. Provisioning in progress!" -Level Info
               
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
                 
                    <#   $operationResultUrl = "https://api.fabric.microsoft.com/v1/operations/{0}/result" -f $operationId

                    # Fetch the operation result
                    $resultResponse = Invoke-RestMethod `
                        -Headers $FabricConfig.FabricHeaders `
                        -Uri $operationResultUrl `
                        -Method Get `
                        -ErrorAction Stop
                    # Return the result
                    #return $resultResponse.definition.parts
                    Write-Message -Message "Result return: $resultResponse" -Level Debug
                    
                    #$customObject = Get-FabricNotebook -WorkspaceId $WorkspaceId -NotebookName $NotebookName

                    #$customObject | Add-Member -NotePropertyName definition -NotePropertyValue $resultResponse.definition

                    return $resultResponse
#>
                }
                else {
                    Write-Message -Message "Operation Failed" -Level Debug
                    return $operationStatus
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
        Write-Message -Message "Failed to create notebook. Error: $errorDetails" -Level Error
    }
}
