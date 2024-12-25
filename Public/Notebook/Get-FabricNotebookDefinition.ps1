<#
.SYNOPSIS
Retrieves an Notebook or a list of Notebooks from a specified workspace in Microsoft Fabric.

.DESCRIPTION
The `Get-FabricNotebook` function sends a GET request to the Fabric API to retrieve Notebook details for a given workspace. It can filter the results by `NotebookName`.

.PARAMETER WorkspaceId
(Mandatory) The ID of the workspace to query Notebooks.

.PARAMETER NotebookName
(Optional) The name of the specific Notebook to retrieve.

.EXAMPLE
Get-FabricNotebook -WorkspaceId "12345" -NotebookName "Development"

Retrieves the "Development" Notebook from workspace "12345".

.EXAMPLE
Get-FabricNotebook -WorkspaceId "12345"

Retrieves all Notebooks in workspace "12345".

.NOTES
- Requires `$FabricConfig` global configuration, including `BaseUrl` and `FabricHeaders`.
- Calls `Test-TokenExpired` to ensure token validity before making the API request.
- Returns the matching Notebook details or all Notebooks if no filter is provided.

Author: Tiago Balabuch  
Date: 2024-12-15
#>

function Get-FabricNotebookDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$NotebookId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ipynb')]
        [string]$NotebookFormat = 'ipynb'
    )

    try {
        # Step 2: Ensure token validity
        Write-Message -Message "Validating token..." -Level Debug
        Test-TokenExpired
        Write-Message -Message "Token validation completed." -Level Debug

        # Step 3: Construct the API URL
        $apiEndpointUrl = "{0}/workspaces/{1}/notebooks/{2}/getDefinition?format={3}" -f $FabricConfig.BaseUrl, $WorkspaceId, $NotebookId, $NotebookFormat
        Write-Message -Message "API Endpoint: $apiEndpointUrl" -Level Debug

        # Step 4: Make the API request
        $response = Invoke-RestMethod `
            -Headers $FabricConfig.FabricHeaders `
            -Uri $apiEndpointUrl `
            -Method Post `
            -ErrorAction Stop `
            -ResponseHeadersVariable "responseHeader" `
            -StatusCodeVariable "statusCode"

        # Step 5: Validate the response code and handle the response
        switch ($statusCode) {
            200 {
                Write-Message -Message "Notebook '$NotebookName' definition retrieved successfully!" -Level Debug
                return $response
            }
            202 {

                Write-Message -Message "Getting notebook '$NotebookName' definition request accepted. Retrieving in progress!" -Level Debug

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

                    <#
                    $operationResultUrl = "https://api.fabric.microsoft.com/v1/operations/{0}/result" -f $operationId

                    # Fetch the operation result
                    $resultResponse = Invoke-RestMethod `
                        -Headers $FabricConfig.FabricHeaders `
                        -Uri $operationResultUrl `
                        -Method Get `
                        -ErrorAction Stop
                    # Return the result
                    return $resultResponse.definition.parts#>

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
        # Step 9: Capture and log error details
        $errorDetails = $_.Exception.Message
        Write-Message -Message "Failed to retrieve Notebook. Error: $errorDetails" -Level Error
    } 
 
}
