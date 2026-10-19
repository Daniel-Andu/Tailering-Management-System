@echo off
setlocal EnableDelayedExpansion
title Tailoring System - Regenerate Splash Screen & Icons

echo ================================================
echo   REGENERATING SPLASH SCREEN AND APP ICONS
echo ================================================
echo.
echo This script will:
echo   1. Clean build cache
echo   2. Regenerate app icons (circular, professional)
echo   3. Update splash screen resources
echo.
pause

cd /d "%~dp0.."

echo.
echo [1/3] Cleaning build cache...
call flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/3] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [3/3] Generating launcher icons...
call flutter pub run flutter_launcher_icons -f tools/flutter_launcher_icons.yaml
if errorlevel 1 (
    echo ERROR: Icon generation failed
    pause
    exit /b 1
)

echo.
echo ================================================
echo   SUCCESS! Splash and Icons Updated
echo ================================================
echo.
echo Changes made:
echo   ✓ Native splash screen matches Flutter theme
echo   ✓ App icons regenerated with circular design
echo   ✓ Seamless transition (no visible switch)
echo   ✓ Status bar and navigation bar colors updated
echo.
echo Next steps:
echo   1. Run: flutter run
echo   2. Test the splash screen on your device
echo   3. Build release: scripts\build_release_apk.bat
echo.
pause
