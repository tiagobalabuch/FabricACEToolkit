<#
.SYNOPSIS
Retrieves detailed error response from an exception, including response stream content if available.

.DESCRIPTION
The `Get-ErrorResponse` function attempts to extract detailed error information from an exception, including the content of the response stream when the exception has a `Response` property. If the response content is unavailable, it falls back to the exception's message or a generic error message.

.PARAMETER Exception
The exception object to extract error details from.

.EXAMPLE
try {
    Invoke-WebRequest -Uri "https://invalid-url.example"
} catch {
    $errorDetails = Get-ErrorResponse -Exception $_.Exception
    Write-Host "Error Details: $errorDetails"
}

Attempts to invoke a web request and retrieves detailed error information if the request fails.

.NOTES
Author: Tiago Balabuch
Date: 2024-12-12
#>

function Get-ErrorResponse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Exception]$Exception
    )

    try {
        # Check if the exception has a Response property
        if ($Exception -and $Exception.PSObject.Properties['Response']) {
            $responseStream = $Exception.Response.GetResponseStream()
            if ($responseStream) {
                try {
                    # Read the response stream
                    $reader = [System.IO.StreamReader]::new($responseStream)
                    $reader.BaseStream.Position = 0
                    $reader.DiscardBufferedData()
                    $errorResponse = $reader.ReadToEnd()

                    if (![string]::IsNullOrWhiteSpace($errorResponse)) {
                        return $errorResponse
                    }
                } catch {
                    # Log verbose information for debugging
                    Write-Verbose "Failed to read error response stream: $_"
                } finally {
                    # Dispose of the stream reader to free resources
                    if ($reader) {
                        $reader.Dispose()
                    }
                }
            }
        }

        # Fallback to the exception message
        if ($Exception.Message -and -not [string]::IsNullOrWhiteSpace($Exception.Message)) {
            return $Exception.Message
        }
    } catch {
        # Log verbose information if an unexpected error occurs
        Write-Verbose "An unexpected error occurred while processing the exception: $_"
    }

    # Generic fallback message
    return "No additional error information is available."
}


<#

function Get-ErrorResponse($exception) {
    # Check if the exception has a Response property
    if ($exception -and $exception.PSObject.Properties['Response']) {
        try {
            $result = $exception.Response.GetResponseStream()
            if ($result) {
                $reader = New-Object System.IO.StreamReader($result)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $errorResponse = $reader.ReadToEnd()

                if (![string]::IsNullOrWhiteSpace($errorResponse)) {
                    return $errorResponse
                }
            }
        } catch {
            # Log or handle errors while reading the response stream
            Write-Verbose "Failed to read error response stream."
        }
    }

    # Fallback to exception message if no response stream is available
    if ($exception.Message -and -not [string]::IsNullOrWhiteSpace($exception.Message)) {
        return $exception.Message
    }

    # Generic fallback message
    return "No additional error information is available."
}
try {
    1/0
}
catch {
    #$_.Exception
    $errorDetails = Get-ErrorResponse($_.Exception)# | Get-ErrorResponse
    Write-Message -Message  "Error Details: $errorDetails" -Level Error
    
}#>