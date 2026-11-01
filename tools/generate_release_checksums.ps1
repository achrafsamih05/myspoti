[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$IpaPath = "ios/build/Myspoti.ipa",

    [Parameter(Position = 1)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Myspoti iOS - Release Checksum Generator (SHA-256)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Validate IPA file existence
if (-not (Test-Path -Path $IpaPath -PathType Leaf)) {
    Write-Error ("ERROR: Target IPA file not found at path: '{0}'. Please verify that the IPA has been built before generating checksums." -f $IpaPath)
    exit 1
}

$ipaItem = Get-Item -Path $IpaPath
$ipaFullName = $ipaItem.FullName
$ipaFileName = $ipaItem.Name
$ipaSize = $ipaItem.Length
$ipaSizeMB = [math]::Round($ipaSize / 1048576, 2)

Write-Host ("Target File: {0}" -f $ipaFileName) -ForegroundColor White
Write-Host ("Full Path:   {0}" -f $ipaFullName) -ForegroundColor Gray
Write-Host ("File Size:   {0} bytes ({1} MB)" -f $ipaSize, $ipaSizeMB) -ForegroundColor Gray

# 2. Compute SHA-256 Hash
Write-Host ""
Write-Host "Computing SHA-256 cryptographic hash..." -ForegroundColor Yellow
$hashResult = Get-FileHash -Path $ipaFullName -Algorithm SHA256
$sha256Hex = $hashResult.Hash.ToLowerInvariant()

Write-Host ("SHA-256:     {0}" -f $sha256Hex) -ForegroundColor Green

# 3. Determine Output Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $targetDir = $ipaItem.DirectoryName
    $targetOutputFile = Join-Path -Path $targetDir -ChildPath "SHA256SUMS.txt"
} else {
    $targetOutputFile = $OutputPath
}

# Standard GNU sha256sum format: "<hash>  <filename>"
$checksumLine = "{0}  {1}" -f $sha256Hex, $ipaFileName

Set-Content -Path $targetOutputFile -Value $checksumLine -Encoding ascii -Force
$outputItem = Get-Item -Path $targetOutputFile

Write-Host ""
Write-Host "Checksum file written successfully:" -ForegroundColor Green
Write-Host ("Destination: {0}" -f $outputItem.FullName) -ForegroundColor White
Write-Host ("Content:     {0}" -f $checksumLine) -ForegroundColor Gray

# 4. Display Verification Commands
Write-Host ""
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Verification Commands for End Users:" -ForegroundColor Cyan
Write-Host "  Windows PowerShell:" -ForegroundColor White
Write-Host ("    (Get-FileHash -Algorithm SHA256 .\{0}).Hash.ToLower() -eq '{1}'" -f $ipaFileName, $sha256Hex) -ForegroundColor Gray
Write-Host "  macOS / Linux:" -ForegroundColor White
Write-Host "    shasum -a 256 -c SHA256SUMS.txt" -ForegroundColor Gray
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

exit 0
