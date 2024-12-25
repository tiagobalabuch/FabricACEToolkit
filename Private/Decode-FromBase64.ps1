function Decode-FromBase64 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Base64String
    )

    try {
        # Step 1: Convert the Base64 string to a byte array
        $bytes = [Convert]::FromBase64String($Base64String)

        # Step 2: Convert the byte array back to a UTF-8 string
        $decodedString = [System.Text.Encoding]::UTF8.GetString($bytes)

        # Step 3: Return the decoded string
        return $decodedString
    }
    catch {
        # Step 4: Handle and log errors
        $errorDetails = $_.Exception.Message
        Write-Message -Message "An error occurred while decoding from Base64: $errorDetails" -Level Error
        throw "An error occurred while decoding from Base64: $_"
    }
}