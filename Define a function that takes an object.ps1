# Define a function that takes an object as input
function Add-SparkPropertiesToJson {
    param(
      [Parameter(Mandatory)]
      [object]$Object
    )
  
    # Create an empty hashtable to represent the JSON object
    $JsonObject = @{}
  
    # Add the input object to the 'sparkProperties' property
    $JsonObject["sparkProperties"] = $Object
  
    # Convert the hashtable to JSON
    $JsonString = ConvertTo-Json -InputObject $JsonObject
  
    # Return the JSON string
    return $JsonString
  }
  
  # Example usage:
  # Create a sample object
  $MyObject = @{
    "key1" = "value1"
    "key2" = "value2"
  }
  
  # Call the function and store the result
  $JsonResult = Add-SparkPropertiesToJson -Object $MyObject
  
  # Output the resulting JSON string
  Write-Host $JsonResult


  function test-EnvSpark {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,   
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$InstancePoolName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Workspace', 'Capacity')]
        [string]$InstancePoolType,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DriverCores,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverMemory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$ExecutorCores,


        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ExecutorMemory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [bool]$DynamicExecutorAllocationEnabled,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DynamicExecutorAllocationMinExecutors,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DynamicExecutorAllocationMaxExecutors,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RuntimeVersion,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]$SparkProperties

    )

# Step 3: Construct the request body
$body = @{
    instancePool = @{
        name = $InstancePoolName
        type = $InstancePoolType
    }
    driverCores = $DriverCores
    driverMemory = $DriverMemory
    executorCores = $ExecutorCores
    executorMemory = $ExecutorMemory
dynamicExecutorAllocation = @{
    enabled = $DynamicExecutorAllocationEnabled
    minExecutors = $DynamicExecutorAllocationMinExecutors
    maxExecutors = $DynamicExecutorAllocationMaxExecutors
}

    runtimeVersion = $RuntimeVersion
    }

    $body["sparkProperties"] = $SparkProperties

        # Convert the body to JSON
        $bodyJson = $body | ConvertTo-Json -Depth 4

        return $bodyJson

}



$MyObject = @{
    "key1" = "value1"
    "key2" = "value2"
  }

test-EnvSpark2 -WorkspaceId "xxxxxxxxx" -EnvironmentId "xxxxxxxx" -DriverCores 4 -DriverMemory "65g" -InstancePoolName "PoolName" -InstancePoolType Workspace -ExecutorCores 8 -ExecutorMemory "32g" -DynamicExecutorAllocationEnabled $true -DynamicExecutorAllocationMinExecutors 1 -DynamicExecutorAllocationMaxExecutors 8 -RuntimeVersion "1.2" -SparkProperties $MyObject



function Test-EnvSpark2 {
    [CmdletBinding()]
    param (
        # Optional: Workspace ID
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceId,
        
        # Mandatory: Environment ID
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$EnvironmentId,

        # Mandatory: Instance Pool Name (Alphanumeric and spaces allowed)
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z0-9_ ]*$')]
        [string]$InstancePoolName,

        # Optional: Instance Pool Type with default values
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Workspace', 'Capacity')]
        [string]$InstancePoolType = 'Workspace',

        # Mandatory: Driver Configuration
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DriverCores,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverMemory,

        # Mandatory: Executor Configuration
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$ExecutorCores,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ExecutorMemory,

        # Mandatory: Dynamic Executor Allocation Settings
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [bool]$DynamicExecutorAllocationEnabled,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DynamicExecutorAllocationMinExecutors,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$DynamicExecutorAllocationMaxExecutors,

        # Mandatory: Runtime Version
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RuntimeVersion,

        # Mandatory: Spark Properties
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]$SparkProperties
    )

    # Construct the request body
    $body = @{
        instancePool = @{
            name = $InstancePoolName
            type = $InstancePoolType
        }
        driverCores                      = $DriverCores
        driverMemory                     = $DriverMemory
        executorCores                    = $ExecutorCores
        executorMemory                   = $ExecutorMemory
        dynamicExecutorAllocation        = @{
            enabled        = $DynamicExecutorAllocationEnabled
            minExecutors   = $DynamicExecutorAllocationMinExecutors
            maxExecutors   = $DynamicExecutorAllocationMaxExecutors
        }
        runtimeVersion                   = $RuntimeVersion
        sparkProperties                  = $SparkProperties
    }

    # Convert the body to JSON with proper depth
    $bodyJson = $body | ConvertTo-Json -Depth 4

    # Return the JSON body
    return $bodyJson
}

### Encode a string to Base64 in PowerShell

function Encode-ToBase64 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$filePath
    )

    try {
        # Step 1: Convert the input string to a byte array
        #$bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)

        # Step 2: Convert the byte array to Base64 string
        $base64String = [Convert]::ToBase64String($fileBytes)

        # Step 3: Return the encoded string
        return $base64String
    }
    catch {
        # Step 4: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "An error occurred while encoding to Base64: $errorDetails" -Level Error
        throw "An error occurred while encoding to Base64: $_"
    }
}

# Example usage with JSON
$jsonObject = @{
    Name  = "John Doe"
    Age   = 30
    Email = "john.doe@example.com"
} | ConvertTo-Json -Depth 10

$jsonObject

$encodedString = Encode-ToBase64 -InputString $jsonObject
Write-Output "Original JSON: $jsonObject"
Write-Output "Base64 Encoded JSON: $encodedString"

ewogICJFbWFpbCI6ICJqb2huLmRvZUBleGFtcGxlLmNvbSIsCiAgIk5hbWUiOiAiSm9obiBEb2UiLAogICJBZ2UiOiAzMAp9 #web
ew0KICAiRW1haWwiOiAiam9obi5kb2VAZXhhbXBsZS5jb20iLA0KICAiTmFtZSI6ICJKb2huIERvZSIsDQogICJBZ2UiOiAzMA0KfQ== #ps


function Decode-FromBase64 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Base64String
    )

    try {
        # Convert the Base64 string to a byte array
        $bytes = [Convert]::FromBase64String($Base64String)

        # Convert the byte array back to a UTF-8 string
        $decodedString = [System.Text.Encoding]::UTF8.GetString($bytes)

        # Return the decoded string
        return $decodedString
    } catch {
        Write-Error "An error occurred while decoding from Base64: $_"
    }
}

# Example usage
$encodedString = "ewogICJFbWFpbCI6ICJqb2huLmRvZUBleGFtcGxlLmNvbSIsCiAgIk5hbWUiOiAiSm9obiBEb2UiLAogICJBZ2UiOiAzMAp9"
$decodedString = Decode-FromBase64 -Base64String $encodedString
Write-Output "Base64 Encoded String: $encodedString"
Write-Output "Decoded String: $decodedString"


# Specify the path to your Python file
$filePath = "C:\temp\API\notebook-content.py"
#$filePath = "C:\temp\API\.platform"
# Read the content of the file as bytes
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)

Encode-ToBase64 -filePath $filePath
$decodeString = Encode-ToBase64 -filePath $filePath
Decode-FromBase64 -Base64String $decodeString
    # Convert the input string to a byte array
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($filePath)
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)

    # Convert the byte array to Base64 string
    $base64String = [Convert]::ToBase64String($fileBytes)

    # Return the encoded string
     $base64String


 $bytes = [Convert]::FromBase64String($Base64String)

 # Convert the byte array back to a UTF-8 string
 $decodedString = [System.Text.Encoding]::UTF8.GetString($bytes)

 # Return the decoded string
$decodedString



# Encode the bytes to Base64
$base64String = [Convert]::ToBase64String($fileBytes)

# Output the Base64 string (or save it to a file)
Write-Output $base64String

# Optionally save the Base64 string to a file
$base64FilePath = "C:\Path\To\Your\Base64Output.txt"
$base64String | Set-Content -Path $base64FilePath






$NotebookName = "NotebookName"

$NotebookDescription = "NotebookDescription"

$NotebookPathDefinition = "C:\temp\API\notebook-content.py"
$NotebookPathPlatformDefinition = "C:\temp\API\.platform"


$body = @{
    displayName = $NotebookName
}

if ($NotebookDescription) {
    $body.description = $NotebookDescription
}


if ($NotebookPathDefinition) {
    $notebookEncodedContent = Encode-ToBase64 -filePath $NotebookPathDefinition

    # Initialize definition if it doesn't exist
    if (-not $body.definition) {
        $body.definition = @{
            format = "py"
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


if ($NotebookPathPlatformDefinition) {
    $notebookEncodedPlatformContent = Encode-ToBase64 -filePath $NotebookPathPlatformDefinition

    # Initialize definition if it doesn't exist
    if (-not $body.definition) {
        $body.definition = @{
            format = "py"
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


$bodyJson = $body | ConvertTo-Json -Depth 10

$bodyJson


### UTF-8 Encoding in PowerShell
# Specify the path to your Python file
$filePath = "C:\temp\API\notebook-content.py"

# Read the content of the file as text with UTF-8 encoding
$fileContent = Get-Content -Path $filePath -Raw -Encoding UTF8

# Convert the UTF-8 string to bytes
$fileBytes = [System.Text.Encoding]::UTF8.GetBytes($fileContent)

# Encode the bytes to Base64
$base64String = [Convert]::ToBase64String($fileBytes)

# Output the Base64 string (or save it to a file)
Write-Output $base64String

$a = "IyBGYWJyaWMgbm90ZWJvb2sgc291cmNlDQoNCiMgTUVUQURBVEEgKioqKioqKioqKioqKioqKioqKioNCg0KIyBNRVRBIHsNCiMgTUVUQSAgICJrZXJuZWxfaW5mbyI6IHsNCiMgTUVUQSAgICAgIm5hbWUiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBICAgfSwNCiMgTUVUQSAgICJkZXBlbmRlbmNpZXMiOiB7DQojIE1FVEEgICAgICJsYWtlaG91c2UiOiB7DQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlIjogImY4NTQwZmVhLTNhMWEtNDdiOS04OWI0LWJlZDMxMTM2MWE0YyIsDQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlX25hbWUiOiAiRGVtb19MSCIsDQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlX3dvcmtzcGFjZV9pZCI6ICIzZTlkMzg1Zi0yNTU1LTRhNmQtYjM4Mi1kZmJmOThmMjZjYjQiLA0KIyBNRVRBICAgICAgICJrbm93bl9sYWtlaG91c2VzIjogWw0KIyBNRVRBICAgICAgICAgew0KIyBNRVRBICAgICAgICAgICAiaWQiOiAiODBiM2NmODEtOGY2Zi00NTE3LTk1YjUtNWYyNGY1OGQ1YWE1Ig0KIyBNRVRBICAgICAgICAgfSwNCiMgTUVUQSAgICAgICAgIHsNCiMgTUVUQSAgICAgICAgICAgImlkIjogImY4NTQwZmVhLTNhMWEtNDdiOS04OWI0LWJlZDMxMTM2MWE0YyINCiMgTUVUQSAgICAgICAgIH0NCiMgTUVUQSAgICAgICBdDQojIE1FVEEgICAgIH0NCiMgTUVUQSAgIH0NCiMgTUVUQSB9DQoNCiMgQ0VMTCAqKioqKioqKioqKioqKioqKioqKg0KDQpmcm9tICBweXNwYXJrLnNxbC50eXBlcyBpbXBvcnQgKg0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KY3JpbWVzX3NjaGVtYSA9IFN0cnVjdFR5cGUoWw0KICAgIFN0cnVjdEZpZWxkKCdJRCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ2FzZU51bWJlcicsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdEYXRlJywgVGltZXN0YW1wVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0Jsb2NrJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0lVQ1InLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnUHJpbWFyeVR5cGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnRGVzY3JpcHRpb24nLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQXJyZXN0JywgQm9vbGVhblR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdEb21lc3RpYycsIEJvb2xlYW5UeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQmVhdCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnRGlzdHJpY3QnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1dhcmQnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0NvbW11bml0eUFyZWEnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0ZCSUNvZGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWENvb3JkaW5hdGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWUNvb3JkaW5hdGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWWVhcicsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVXBkYXRlZE9uJywgVGltZXN0YW1wVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xhdGl0dWRlJywgRmxvYXRUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTG9uZ2l0dWRlJywgRmxvYXRUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTG9jYXRpb24nLCBTdHJpbmdUeXBlKCksIEZhbHNlKQ0KXSkNCg0KIyBNRVRBREFUQSAqKioqKioqKioqKioqKioqKioqKg0KDQojIE1FVEEgew0KIyBNRVRBICAgImxhbmd1YWdlIjogInB5dGhvbiIsDQojIE1FVEEgICAibGFuZ3VhZ2VfZ3JvdXAiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBIH0NCg0KIyBDRUxMICoqKioqKioqKioqKioqKioqKioqDQoNCiMgZGYgbm93IGlzIGEgU3BhcmsgRGF0YUZyYW1lIGNvbnRhaW5pbmcgQ1NWIGRhdGEgZnJvbSAiRmlsZXMvRGF0YS9DcmltZXNfLV8yMDAxX3RvX1ByZXNlbnQuY3N2Ii4NCmRmID0gc3BhcmsucmVhZC5mb3JtYXQoImNzdiIpLnNjaGVtYShjcmltZXNfc2NoZW1hKS5vcHRpb24oImhlYWRlciIsInRydWUiKS5sb2FkKCJGaWxlcy9EYXRhL0NyaW1lc18tXzIwMDFfdG9fUHJlc2VudC5jc3YiKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KZGlzcGxheShkZikNCg0KIyBNRVRBREFUQSAqKioqKioqKioqKioqKioqKioqKg0KDQojIE1FVEEgew0KIyBNRVRBICAgImxhbmd1YWdlIjogInB5dGhvbiIsDQojIE1FVEEgICAibGFuZ3VhZ2VfZ3JvdXAiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBIH0NCg0KIyBDRUxMICoqKioqKioqKioqKioqKioqKioqDQoNCmRlbHRhX3RhYmxlX25hbWUgPSAnY3JpbWVzJw0Kc3Bhcmsuc3FsKGYiRFJPUCBUQUJMRSBJRiBFWElTVFMge2RlbHRhX3RhYmxlX25hbWV9IikNCmRmLndyaXRlLmZvcm1hdCgiZGVsdGEiKS5tb2RlKCJvdmVyd3JpdGUiKS5zYXZlQXNUYWJsZShkZWx0YV90YWJsZV9uYW1lKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KY3Jhc2hlc19zY2hlbWEgPSBTdHJ1Y3RUeXBlKFsNCiAgICBTdHJ1Y3RGaWVsZCgnQ3Jhc2hEYXRlJywgRGF0ZVR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdDcmFzaFRpbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQm9yb3VnaCcsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdaaXBDb2RlJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xhdGl0dWRlJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xvbmdpdHVkZScsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdPblN0cmVldE5hbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ3Jvc3NTdHJlZXROYW1lJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ09mZlN0cmVldE5hbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZXJzb25zSW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZXJzb25zS2lsbGVkJywgSW50ZWdlclR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdOdW1PZlBlZGVzdHJpYW5zSW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZWRlc3RyaWFuc0tpbGxlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZDeWNsaXN0SW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZDeWNsaXN0S2lsbGVkJywgSW50ZWdlclR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdOdW1PZk1vdG9yaXN0SW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZNb3RvcmlzdEtpbGxlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTEnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTInLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTMnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTQnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29sbGlzaW9uSUQnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1ZlaGljbGVUeXBlQ29kZTEnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVmVoaWNsZVR5cGVDb2RlMicsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdWZWhpY2xlVHlwZUNvZGUzJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1ZlaGljbGVUeXBlQ29kZTQnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVmVoaWNsZVR5cGVDb2RlNScsIFN0cmluZ1R5cGUoKSwgRmFsc2UpDQpdKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KZGYgPSBzcGFyay5yZWFkLmZvcm1hdCgiY3N2Iikub3B0aW9uKCJoZWFkZXIiLCJ0cnVlIikubG9hZCgiRmlsZXMvbW90b3ItdmVoaWNsZS1jb2xsaXNpb25zL2Nzdi9jcmFzaGVzL2NyYXNoZXMuY3N2IikNCiMgZGYgbm93IGlzIGEgU3BhcmsgRGF0YUZyYW1lIGNvbnRhaW5pbmcgQ1NWIGRhdGEgZnJvbSAiRmlsZXMvbW90b3ItdmVoaWNsZS1jb2xsaXNpb25zL2Nzdi9jcmFzaGVzL2NyYXNoZXMuY3N2Ii4NCmRpc3BsYXkoZGYpDQoNCiMgTUVUQURBVEEgKioqKioqKioqKioqKioqKioqKioNCg0KIyBNRVRBIHsNCiMgTUVUQSAgICJsYW5ndWFnZSI6ICJweXRob24iLA0KIyBNRVRBICAgImxhbmd1YWdlX2dyb3VwIjogInN5bmFwc2VfcHlzcGFyayINCiMgTUVUQSB9DQoNCiMgQ0VMTCAqKioqKioqKioqKioqKioqKioqKg0KDQpkZiA9IHNwYXJrLnJlYWQuZm9ybWF0KCJjc3YiKS5vcHRpb24oImhlYWRlciIsInRydWUiKS5zY2hlbWEoY3Jhc2hlc19zY2hlbWEpLmxvYWQoIkZpbGVzL21vdG9yLXZlaGljbGUtY29sbGlzaW9ucy9jc3YvY3Jhc2hlcy9jcmFzaGVzLmNzdiIpDQojIGRmIG5vdyBpcyBhIFNwYXJrIERhdGFGcmFtZSBjb250YWluaW5nIENTViBkYXRhIGZyb20gIkZpbGVzL21vdG9yLXZlaGljbGUtY29sbGlzaW9ucy9jc3YvY3Jhc2hlcy9jcmFzaGVzLmNzdiIuDQpkaXNwbGF5KGRmKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0K"
$b = "IyBGYWJyaWMgbm90ZWJvb2sgc291cmNlDQoNCiMgTUVUQURBVEEgKioqKioqKioqKioqKioqKioqKioNCg0KIyBNRVRBIHsNCiMgTUVUQSAgICJrZXJuZWxfaW5mbyI6IHsNCiMgTUVUQSAgICAgIm5hbWUiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBICAgfSwNCiMgTUVUQSAgICJkZXBlbmRlbmNpZXMiOiB7DQojIE1FVEEgICAgICJsYWtlaG91c2UiOiB7DQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlIjogImY4NTQwZmVhLTNhMWEtNDdiOS04OWI0LWJlZDMxMTM2MWE0YyIsDQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlX25hbWUiOiAiRGVtb19MSCIsDQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlX3dvcmtzcGFjZV9pZCI6ICIzZTlkMzg1Zi0yNTU1LTRhNmQtYjM4Mi1kZmJmOThmMjZjYjQiLA0KIyBNRVRBICAgICAgICJrbm93bl9sYWtlaG91c2VzIjogWw0KIyBNRVRBICAgICAgICAgew0KIyBNRVRBICAgICAgICAgICAiaWQiOiAiODBiM2NmODEtOGY2Zi00NTE3LTk1YjUtNWYyNGY1OGQ1YWE1Ig0KIyBNRVRBICAgICAgICAgfSwNCiMgTUVUQSAgICAgICAgIHsNCiMgTUVUQSAgICAgICAgICAgImlkIjogImY4NTQwZmVhLTNhMWEtNDdiOS04OWI0LWJlZDMxMTM2MWE0YyINCiMgTUVUQSAgICAgICAgIH0NCiMgTUVUQSAgICAgICBdDQojIE1FVEEgICAgIH0NCiMgTUVUQSAgIH0NCiMgTUVUQSB9DQoNCiMgQ0VMTCAqKioqKioqKioqKioqKioqKioqKg0KDQpmcm9tICBweXNwYXJrLnNxbC50eXBlcyBpbXBvcnQgKg0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KY3JpbWVzX3NjaGVtYSA9IFN0cnVjdFR5cGUoWw0KICAgIFN0cnVjdEZpZWxkKCdJRCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ2FzZU51bWJlcicsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdEYXRlJywgVGltZXN0YW1wVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0Jsb2NrJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0lVQ1InLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnUHJpbWFyeVR5cGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnRGVzY3JpcHRpb24nLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQXJyZXN0JywgQm9vbGVhblR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdEb21lc3RpYycsIEJvb2xlYW5UeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQmVhdCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnRGlzdHJpY3QnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1dhcmQnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0NvbW11bml0eUFyZWEnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0ZCSUNvZGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWENvb3JkaW5hdGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWUNvb3JkaW5hdGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWWVhcicsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVXBkYXRlZE9uJywgVGltZXN0YW1wVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xhdGl0dWRlJywgRmxvYXRUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTG9uZ2l0dWRlJywgRmxvYXRUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTG9jYXRpb24nLCBTdHJpbmdUeXBlKCksIEZhbHNlKQ0KXSkNCg0KIyBNRVRBREFUQSAqKioqKioqKioqKioqKioqKioqKg0KDQojIE1FVEEgew0KIyBNRVRBICAgImxhbmd1YWdlIjogInB5dGhvbiIsDQojIE1FVEEgICAibGFuZ3VhZ2VfZ3JvdXAiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBIH0NCg0KIyBDRUxMICoqKioqKioqKioqKioqKioqKioqDQoNCiMgZGYgbm93IGlzIGEgU3BhcmsgRGF0YUZyYW1lIGNvbnRhaW5pbmcgQ1NWIGRhdGEgZnJvbSAiRmlsZXMvRGF0YS9DcmltZXNfLV8yMDAxX3RvX1ByZXNlbnQuY3N2Ii4NCmRmID0gc3BhcmsucmVhZC5mb3JtYXQoImNzdiIpLnNjaGVtYShjcmltZXNfc2NoZW1hKS5vcHRpb24oImhlYWRlciIsInRydWUiKS5sb2FkKCJGaWxlcy9EYXRhL0NyaW1lc18tXzIwMDFfdG9fUHJlc2VudC5jc3YiKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KZGlzcGxheShkZikNCg0KIyBNRVRBREFUQSAqKioqKioqKioqKioqKioqKioqKg0KDQojIE1FVEEgew0KIyBNRVRBICAgImxhbmd1YWdlIjogInB5dGhvbiIsDQojIE1FVEEgICAibGFuZ3VhZ2VfZ3JvdXAiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBIH0NCg0KIyBDRUxMICoqKioqKioqKioqKioqKioqKioqDQoNCmRlbHRhX3RhYmxlX25hbWUgPSAnY3JpbWVzJw0Kc3Bhcmsuc3FsKGYiRFJPUCBUQUJMRSBJRiBFWElTVFMge2RlbHRhX3RhYmxlX25hbWV9IikNCmRmLndyaXRlLmZvcm1hdCgiZGVsdGEiKS5tb2RlKCJvdmVyd3JpdGUiKS5zYXZlQXNUYWJsZShkZWx0YV90YWJsZV9uYW1lKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KY3Jhc2hlc19zY2hlbWEgPSBTdHJ1Y3RUeXBlKFsNCiAgICBTdHJ1Y3RGaWVsZCgnQ3Jhc2hEYXRlJywgRGF0ZVR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdDcmFzaFRpbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQm9yb3VnaCcsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdaaXBDb2RlJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xhdGl0dWRlJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xvbmdpdHVkZScsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdPblN0cmVldE5hbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ3Jvc3NTdHJlZXROYW1lJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ09mZlN0cmVldE5hbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZXJzb25zSW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZXJzb25zS2lsbGVkJywgSW50ZWdlclR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdOdW1PZlBlZGVzdHJpYW5zSW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZWRlc3RyaWFuc0tpbGxlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZDeWNsaXN0SW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZDeWNsaXN0S2lsbGVkJywgSW50ZWdlclR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdOdW1PZk1vdG9yaXN0SW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZNb3RvcmlzdEtpbGxlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTEnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTInLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTMnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTQnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29sbGlzaW9uSUQnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1ZlaGljbGVUeXBlQ29kZTEnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVmVoaWNsZVR5cGVDb2RlMicsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdWZWhpY2xlVHlwZUNvZGUzJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1ZlaGljbGVUeXBlQ29kZTQnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVmVoaWNsZVR5cGVDb2RlNScsIFN0cmluZ1R5cGUoKSwgRmFsc2UpDQpdKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KZGYgPSBzcGFyay5yZWFkLmZvcm1hdCgiY3N2Iikub3B0aW9uKCJoZWFkZXIiLCJ0cnVlIikubG9hZCgiRmlsZXMvbW90b3ItdmVoaWNsZS1jb2xsaXNpb25zL2Nzdi9jcmFzaGVzL2NyYXNoZXMuY3N2IikNCiMgZGYgbm93IGlzIGEgU3BhcmsgRGF0YUZyYW1lIGNvbnRhaW5pbmcgQ1NWIGRhdGEgZnJvbSAiRmlsZXMvbW90b3ItdmVoaWNsZS1jb2xsaXNpb25zL2Nzdi9jcmFzaGVzL2NyYXNoZXMuY3N2Ii4NCmRpc3BsYXkoZGYpDQoNCiMgTUVUQURBVEEgKioqKioqKioqKioqKioqKioqKioNCg0KIyBNRVRBIHsNCiMgTUVUQSAgICJsYW5ndWFnZSI6ICJweXRob24iLA0KIyBNRVRBICAgImxhbmd1YWdlX2dyb3VwIjogInN5bmFwc2VfcHlzcGFyayINCiMgTUVUQSB9DQoNCiMgQ0VMTCAqKioqKioqKioqKioqKioqKioqKg0KDQpkZiA9IHNwYXJrLnJlYWQuZm9ybWF0KCJjc3YiKS5vcHRpb24oImhlYWRlciIsInRydWUiKS5zY2hlbWEoY3Jhc2hlc19zY2hlbWEpLmxvYWQoIkZpbGVzL21vdG9yLXZlaGljbGUtY29sbGlzaW9ucy9jc3YvY3Jhc2hlcy9jcmFzaGVzLmNzdiIpDQojIGRmIG5vdyBpcyBhIFNwYXJrIERhdGFGcmFtZSBjb250YWluaW5nIENTViBkYXRhIGZyb20gIkZpbGVzL21vdG9yLXZlaGljbGUtY29sbGlzaW9ucy9jc3YvY3Jhc2hlcy9jcmFzaGVzLmNzdiIuDQpkaXNwbGF5KGRmKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0K"

if( $a -eq $b) {
    Write-Host "Strings are equal"
} else {
    Write-Host "Strings are not equal"
}


$body = '{
  "description": "NotebookDescription",
  "definition": {
    "format": "py",
    "parts": [
      {
        "payloadType": "InlineBase64",
        "payload": "IyBGYWJyaWMgbm90ZWJvb2sgc291cmNlDQoNCiMgTUVUQURBVEEgKioqKioqKioqKioqKioqKioqKioNCg0KIyBNRVRBIHsNCiMgTUVUQSAgICJrZXJuZWxfaW5mbyI6IHsNCiMgTUVUQSAgICAgIm5hbWUiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBICAgfSwNCiMgTUVUQSAgICJkZXBlbmRlbmNpZXMiOiB7DQojIE1FVEEgICAgICJsYWtlaG91c2UiOiB7DQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlIjogImY4NTQwZmVhLTNhMWEtNDdiOS04OWI0LWJlZDMxMTM2MWE0YyIsDQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlX25hbWUiOiAiRGVtb19MSCIsDQojIE1FVEEgICAgICAgImRlZmF1bHRfbGFrZWhvdXNlX3dvcmtzcGFjZV9pZCI6ICIzZTlkMzg1Zi0yNTU1LTRhNmQtYjM4Mi1kZmJmOThmMjZjYjQiLA0KIyBNRVRBICAgICAgICJrbm93bl9sYWtlaG91c2VzIjogWw0KIyBNRVRBICAgICAgICAgew0KIyBNRVRBICAgICAgICAgICAiaWQiOiAiODBiM2NmODEtOGY2Zi00NTE3LTk1YjUtNWYyNGY1OGQ1YWE1Ig0KIyBNRVRBICAgICAgICAgfSwNCiMgTUVUQSAgICAgICAgIHsNCiMgTUVUQSAgICAgICAgICAgImlkIjogImY4NTQwZmVhLTNhMWEtNDdiOS04OWI0LWJlZDMxMTM2MWE0YyINCiMgTUVUQSAgICAgICAgIH0NCiMgTUVUQSAgICAgICBdDQojIE1FVEEgICAgIH0NCiMgTUVUQSAgIH0NCiMgTUVUQSB9DQoNCiMgQ0VMTCAqKioqKioqKioqKioqKioqKioqKg0KDQpmcm9tICBweXNwYXJrLnNxbC50eXBlcyBpbXBvcnQgKg0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KY3JpbWVzX3NjaGVtYSA9IFN0cnVjdFR5cGUoWw0KICAgIFN0cnVjdEZpZWxkKCdJRCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ2FzZU51bWJlcicsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdEYXRlJywgVGltZXN0YW1wVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0Jsb2NrJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0lVQ1InLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnUHJpbWFyeVR5cGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnRGVzY3JpcHRpb24nLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQXJyZXN0JywgQm9vbGVhblR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdEb21lc3RpYycsIEJvb2xlYW5UeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQmVhdCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnRGlzdHJpY3QnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1dhcmQnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0NvbW11bml0eUFyZWEnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0ZCSUNvZGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWENvb3JkaW5hdGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWUNvb3JkaW5hdGUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnWWVhcicsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVXBkYXRlZE9uJywgVGltZXN0YW1wVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xhdGl0dWRlJywgRmxvYXRUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTG9uZ2l0dWRlJywgRmxvYXRUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTG9jYXRpb24nLCBTdHJpbmdUeXBlKCksIEZhbHNlKQ0KXSkNCg0KIyBNRVRBREFUQSAqKioqKioqKioqKioqKioqKioqKg0KDQojIE1FVEEgew0KIyBNRVRBICAgImxhbmd1YWdlIjogInB5dGhvbiIsDQojIE1FVEEgICAibGFuZ3VhZ2VfZ3JvdXAiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBIH0NCg0KIyBDRUxMICoqKioqKioqKioqKioqKioqKioqDQoNCiMgZGYgbm93IGlzIGEgU3BhcmsgRGF0YUZyYW1lIGNvbnRhaW5pbmcgQ1NWIGRhdGEgZnJvbSAiRmlsZXMvRGF0YS9DcmltZXNfLV8yMDAxX3RvX1ByZXNlbnQuY3N2Ii4NCmRmID0gc3BhcmsucmVhZC5mb3JtYXQoImNzdiIpLnNjaGVtYShjcmltZXNfc2NoZW1hKS5vcHRpb24oImhlYWRlciIsInRydWUiKS5sb2FkKCJGaWxlcy9EYXRhL0NyaW1lc18tXzIwMDFfdG9fUHJlc2VudC5jc3YiKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KZGlzcGxheShkZikNCg0KIyBNRVRBREFUQSAqKioqKioqKioqKioqKioqKioqKg0KDQojIE1FVEEgew0KIyBNRVRBICAgImxhbmd1YWdlIjogInB5dGhvbiIsDQojIE1FVEEgICAibGFuZ3VhZ2VfZ3JvdXAiOiAic3luYXBzZV9weXNwYXJrIg0KIyBNRVRBIH0NCg0KIyBDRUxMICoqKioqKioqKioqKioqKioqKioqDQoNCmRlbHRhX3RhYmxlX25hbWUgPSAnY3JpbWVzJw0Kc3Bhcmsuc3FsKGYiRFJPUCBUQUJMRSBJRiBFWElTVFMge2RlbHRhX3RhYmxlX25hbWV9IikNCmRmLndyaXRlLmZvcm1hdCgiZGVsdGEiKS5tb2RlKCJvdmVyd3JpdGUiKS5zYXZlQXNUYWJsZShkZWx0YV90YWJsZV9uYW1lKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KY3Jhc2hlc19zY2hlbWEgPSBTdHJ1Y3RUeXBlKFsNCiAgICBTdHJ1Y3RGaWVsZCgnQ3Jhc2hEYXRlJywgRGF0ZVR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdDcmFzaFRpbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQm9yb3VnaCcsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdaaXBDb2RlJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xhdGl0dWRlJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ0xvbmdpdHVkZScsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdPblN0cmVldE5hbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ3Jvc3NTdHJlZXROYW1lJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ09mZlN0cmVldE5hbWUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZXJzb25zSW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZXJzb25zS2lsbGVkJywgSW50ZWdlclR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdOdW1PZlBlZGVzdHJpYW5zSW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZQZWRlc3RyaWFuc0tpbGxlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZDeWNsaXN0SW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZDeWNsaXN0S2lsbGVkJywgSW50ZWdlclR5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdOdW1PZk1vdG9yaXN0SW5qdXJlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnTnVtT2ZNb3RvcmlzdEtpbGxlZCcsIEludGVnZXJUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTEnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTInLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTMnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTQnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29udHJpYnV0aW5nRmFjdG9yVmVoaWNsZTUnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnQ29sbGlzaW9uSUQnLCBJbnRlZ2VyVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1ZlaGljbGVUeXBlQ29kZTEnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVmVoaWNsZVR5cGVDb2RlMicsIFN0cmluZ1R5cGUoKSwgRmFsc2UpLA0KICAgIFN0cnVjdEZpZWxkKCdWZWhpY2xlVHlwZUNvZGUzJywgU3RyaW5nVHlwZSgpLCBGYWxzZSksDQogICAgU3RydWN0RmllbGQoJ1ZlaGljbGVUeXBlQ29kZTQnLCBTdHJpbmdUeXBlKCksIEZhbHNlKSwNCiAgICBTdHJ1Y3RGaWVsZCgnVmVoaWNsZVR5cGVDb2RlNScsIFN0cmluZ1R5cGUoKSwgRmFsc2UpDQpdKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0KDQojIENFTEwgKioqKioqKioqKioqKioqKioqKioNCg0KZGYgPSBzcGFyay5yZWFkLmZvcm1hdCgiY3N2Iikub3B0aW9uKCJoZWFkZXIiLCJ0cnVlIikubG9hZCgiRmlsZXMvbW90b3ItdmVoaWNsZS1jb2xsaXNpb25zL2Nzdi9jcmFzaGVzL2NyYXNoZXMuY3N2IikNCiMgZGYgbm93IGlzIGEgU3BhcmsgRGF0YUZyYW1lIGNvbnRhaW5pbmcgQ1NWIGRhdGEgZnJvbSAiRmlsZXMvbW90b3ItdmVoaWNsZS1jb2xsaXNpb25zL2Nzdi9jcmFzaGVzL2NyYXNoZXMuY3N2Ii4NCmRpc3BsYXkoZGYpDQoNCiMgTUVUQURBVEEgKioqKioqKioqKioqKioqKioqKioNCg0KIyBNRVRBIHsNCiMgTUVUQSAgICJsYW5ndWFnZSI6ICJweXRob24iLA0KIyBNRVRBICAgImxhbmd1YWdlX2dyb3VwIjogInN5bmFwc2VfcHlzcGFyayINCiMgTUVUQSB9DQoNCiMgQ0VMTCAqKioqKioqKioqKioqKioqKioqKg0KDQpkZiA9IHNwYXJrLnJlYWQuZm9ybWF0KCJjc3YiKS5vcHRpb24oImhlYWRlciIsInRydWUiKS5zY2hlbWEoY3Jhc2hlc19zY2hlbWEpLmxvYWQoIkZpbGVzL21vdG9yLXZlaGljbGUtY29sbGlzaW9ucy9jc3YvY3Jhc2hlcy9jcmFzaGVzLmNzdiIpDQojIGRmIG5vdyBpcyBhIFNwYXJrIERhdGFGcmFtZSBjb250YWluaW5nIENTViBkYXRhIGZyb20gIkZpbGVzL21vdG9yLXZlaGljbGUtY29sbGlzaW9ucy9jc3YvY3Jhc2hlcy9jcmFzaGVzLmNzdiIuDQpkaXNwbGF5KGRmKQ0KDQojIE1FVEFEQVRBICoqKioqKioqKioqKioqKioqKioqDQoNCiMgTUVUQSB7DQojIE1FVEEgICAibGFuZ3VhZ2UiOiAicHl0aG9uIiwNCiMgTUVUQSAgICJsYW5ndWFnZV9ncm91cCI6ICJzeW5hcHNlX3B5c3BhcmsiDQojIE1FVEEgfQ0K",
        "path": "notebook-content.py"
      },
      {
        "payloadType": "InlineBase64",
        "payload": "ew0KICAiJHNjaGVtYSI6ICJodHRwczovL2RldmVsb3Blci5taWNyb3NvZnQuY29tL2pzb24tc2NoZW1hcy9mYWJyaWMvZ2l0SW50ZWdyYXRpb24vcGxhdGZvcm1Qcm9wZXJ0aWVzLzIuMC4wL3NjaGVtYS5qc29uIiwNCiAgIm1ldGFkYXRhIjogew0KICAgICJ0eXBlIjogIk5vdGVib29rIiwNCiAgICAiZGlzcGxheU5hbWUiOiAiSW5jcmVtZW50YWwgTG9hZCIsDQogICAgImRlc2NyaXB0aW9uIjogIk5ldyBub3RlYm9vayINCiAgfSwNCiAgImNvbmZpZyI6IHsNCiAgICAidmVyc2lvbiI6ICIyLjAiLA0KICAgICJsb2dpY2FsSWQiOiAiYTgxYmNlZWMtNTJhZi00OGJmLWJmM2YtN2RlZDI3YmQ3YjQyIg0KICB9DQp9",
        "path": ".platform"
      }
    ]
  },
  "displayName": "NotebookName123"
}'
$apiEndpointUrl = "https://api.fabric.microsoft.com/v1/workspaces/26cbd4ed-5920-4f2b-94ab-8e6ffbbdc48d/notebooks"
Invoke-RestMethod -Headers $FabricConfig.FabricHeaders -Uri $apiEndpointUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
$statusCode