# Download required offline assets: CanvasKit and Roboto fonts
# Run this script from the repo root with PowerShell (requires internet to download once).
# Adjust $canvasKitHash if your Flutter build expects a different version.

param(
    [string]$canvasKitHash = 'c29809135135e262a912cf583b2c90deb9ded610',
    [string]$outDir = "$PSScriptRoot/.."
)

$canvasBase = "https://www.gstatic.com/flutter-canvaskit/$canvasKitHash/chromium"
$localCanvasDir = Join-Path -Path $outDir -ChildPath "web/flutter-canvaskit/$canvasKitHash/chromium"

# Fonts to download
$fonts = @(
    @{ name = 'Roboto-Regular.woff2'; url = 'https://fonts.gstatic.com/s/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2' },
    @{ name = 'Roboto-Medium.woff2'; url = 'https://fonts.gstatic.com/s/roboto/v32/KFOlCnqEu92Fr1MmEU9fABc4.woff2' }
)

New-Item -ItemType Directory -Force -Path $localCanvasDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outDir 'assets/fonts') | Out-Null

Write-Host "Downloading CanvasKit files to $localCanvasDir"
$canvasFiles = @('canvaskit.js','canvaskit.wasm')
foreach ($f in $canvasFiles) {
    $url = "$canvasBase/$f"
    $dest = Join-Path $localCanvasDir $f
    Write-Host "- $url -> $dest"
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

Write-Host "Downloading fonts to assets/fonts"
foreach ($font in $fonts) {
    $dest = Join-Path (Join-Path $outDir 'assets/fonts') $font.name
    Write-Host "- $($font.url) -> $dest"
    Invoke-WebRequest -Uri $font.url -OutFile $dest -UseBasicParsing
}

Write-Host "Done. You can now build your app and the service worker will cache the local assets for offline use."
