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