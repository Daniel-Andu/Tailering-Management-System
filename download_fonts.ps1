# Downloads Roboto fonts locally so the app works offline
$fontsDir = "c:\Users\Daniel\OneDrive\Desktop\Projects\Mobile app\TailoringManagementSystem\assets\fonts"

Write-Host "Downloading Roboto fonts for offline use..." -ForegroundColor Cyan

$fonts = @{
    "Roboto-Regular.ttf" = "https://fonts.gstatic.com/s/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2"
    "Roboto-Medium.ttf"  = "https://fonts.gstatic.com/s/roboto/v32/KFOlCnqEu92Fr1MmEU9fBBc4AMP6lQ.woff2"
    "Roboto-Bold.ttf"    = "https://fonts.gstatic.com/s/roboto/v32/KFOlCnqEu92Fr1MmWUlfBBc4AMP6lQ.woff2"
}

foreach ($name in $fonts.Keys) {
    $url = $fonts[$name]
    $out = Join-Path $fontsDir $name
    Write-Host "Downloading $name..." -NoNewline
    try {
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " FAILED - $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Run: flutter pub get && flutter run -d chrome --web-renderer html" -ForegroundColor Green
