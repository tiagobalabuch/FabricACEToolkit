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
        [Parameter(Mandatory = $false)]
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
        [Parameter(Mandatory = $false)]
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
