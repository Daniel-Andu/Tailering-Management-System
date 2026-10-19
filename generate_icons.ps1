# Generate App Icons for Android from SVG
# Requires: Inkscape or uses flutter_launcher_icons package

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Tailoring System - App Icon Generator" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$PROJECT = "c:\Users\Daniel\OneDrive\Desktop\Projects\Mobile app\TailoringManagementSystem"
$ANDROID_RES = "$PROJECT\android\app\src\main\res"
$FLUTTER = "C:\src\flutter\bin\flutter.bat"

Set-Location $PROJECT

# Method 1: Use flutter_launcher_icons package (easiest)
Write-Host "[METHOD] Using flutter_launcher_icons package..." -ForegroundColor Green
Write-Host ""

# Check if pubspec already has flutter_launcher_icons
$pubspec = Get-Content "$PROJECT\pubspec.yaml" -Raw
if ($pubspec -notmatch "flutter_launcher_icons") {
    Write-Host "Adding flutter_launcher_icons to pubspec.yaml..." -ForegroundColor Yellow
    
    # Add to dev_dependencies
    $pubspec = $pubspec -replace "(dev_dependencies:[\r\n]+)", "`$1  flutter_launcher_icons: ^0.14.1`n"
    Set-Content "$PROJECT\pubspec.yaml" $pubspec
    Write-Host "Added flutter_launcher_icons dependency" -ForegroundColor Green
} else {
    Write-Host "flutter_launcher_icons already in pubspec.yaml" -ForegroundColor Green
}

# Create/update flutter_launcher_icons config
$iconsConfig = @"
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/images/app_icon.png"
  min_sdk_android: 23
  web:
    generate: true
    image_path: "assets/images/app_icon.png"
    background_color: "#8B5CF6"
    theme_color: "#8B5CF6"
  windows:
    generate: true
    image_path: "assets/images/app_icon.png"
    icon_size: 48
"@

Set-Content "$PROJECT\flutter_launcher_icons.yaml" $iconsConfig
Write-Host "Created flutter_launcher_icons.yaml config" -ForegroundColor Green

# Run flutter pub get
Write-Host ""
Write-Host "Running flutter pub get..." -ForegroundColor Yellow
& $FLUTTER pub get

# Run the icon generator
Write-Host ""
Write-Host "Generating icons..." -ForegroundColor Yellow
& $FLUTTER pub run flutter_launcher_icons

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS! App icons generated." -ForegroundColor Green
    Write-Host ""
    Write-Host "Icons placed in:" -ForegroundColor Cyan
    Write-Host "  - android/app/src/main/res/mipmap-*/ic_launcher.png" -ForegroundColor White
    Write-Host "  - web/favicon.png" -ForegroundColor White
    Write-Host ""
    Write-Host "Now rebuild your APK:" -ForegroundColor Yellow
    Write-Host "  flutter build apk --release --no-tree-shake-icons" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: Icon generation failed." -ForegroundColor Red
    Write-Host "Check that assets/images/app_icon.png exists." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
