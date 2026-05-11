# Generates a password with:
# 3 dictionary words, spaces between words
# 1 uppercase letter at the beginning of one word
# 1 lowercase letter
# 1 digit not at the end of the password
# 1 special character not at the end of the password
# words are 5-8 letters long

$DictionaryPath = "wordlist.txt"

if (-not (Test-Path $DictionaryPath)) {
    Write-Error "Dictionary file not found. Set `$DictionaryPath to a valid word list file."
    exit
}

$SpecialChars = "!@#$%^&*".ToCharArray()

$Words = Get-Content $DictionaryPath |
    Where-Object {
        $_ -match '^[a-zA-Z]{5,8}$'
    } |
    ForEach-Object {
        $_.ToLower()
    } |
    Sort-Object -Unique

if ($Words.Count -lt 3) {
    Write-Error "Not enough valid dictionary words found."
    exit
}

function New-DictionaryPassword {
    $SelectedWords = $Words | Get-Random -Count 3

    # Capitalize the first letter of one random word
    $CapitalWordIndex = Get-Random -Minimum 0 -Maximum 3
    $SelectedWords[$CapitalWordIndex] =
        $SelectedWords[$CapitalWordIndex].Substring(0,1).ToUpper() +
        $SelectedWords[$CapitalWordIndex].Substring(1)

    # Join words with spaces
    $Password = ($SelectedWords -join " ")

    # Pick insert positions that are NOT the end of the password
    $MaxInsertPosition = $Password.Length - 1

    $Digit = Get-Random -Minimum 0 -Maximum 10
    $Special = $SpecialChars | Get-Random

    $DigitPosition = Get-Random -Minimum 0 -Maximum $MaxInsertPosition
    $Password = $Password.Insert($DigitPosition, [string]$Digit)

    $SpecialPosition = Get-Random -Minimum 0 -Maximum ($Password.Length - 1)
    $Password = $Password.Insert($SpecialPosition, [string]$Special)

    return $Password
}

New-DictionaryPassword