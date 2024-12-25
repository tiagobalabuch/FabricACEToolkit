<#
.SYNOPSIS
    Encodes the content of a file into a Base64-encoded string.

.DESCRIPTION
    The Encode-ToBase64 function takes a file path as input, reads the file's content as a byte array, 
    and converts it into a Base64-encoded string. This is useful for embedding binary data (e.g., images, 
    documents) in text-based formats such as JSON or XML.

.PARAMETER filePath
    The full path to the file whose contents you want to encode into Base64.

.EXAMPLE
    PS C:\> Encode-ToBase64 -filePath "C:\Path\To\File.txt"

    Output:
    VGhpcyBpcyBhbiBlbmNvZGVkIGZpbGUu

.EXAMPLE
    PS C:\> $encodedContent = Encode-ToBase64 -filePath "C:\Path\To\Image.jpg"
    PS C:\> $encodedContent | Set-Content -Path "C:\Path\To\EncodedImage.txt"

    This saves the Base64-encoded content of the image to a text file.

.NOTES
    - Ensure the file exists at the specified path before running this function.
    - Large files may cause memory constraints due to full loading into memory.

.AUTHOR
Tiago Balabuch
#>
function Encode-ToBase64 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$filePath
    )
    try {
        # Step 1: Read the file's contents into a byte array
        if (-Not (Test-Path $filePath)) {
            Write-Message -Message "The specified file does not exist: $filePath" -Level Error 
            throw
        }
        
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