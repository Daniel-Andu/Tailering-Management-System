@echo off
setlocal EnableDelayedExpansion
title Tailoring System - Release APK Builder

echo ================================================
echo   TAILORING SYSTEM - Release APK Builder
echo ================================================
echo.

set FLUTTER=C:\src\flutter\bin\flutter.bat
set PROJECT_DIR=%~dp0

:: Check Flutter exists
if not exist "%FLUTTER%" (
    echo [ERROR] Flutter not found at: %FLUTTER%
    echo Please check your Flutter installation.
    pause
    exit /b 1
)

echo [1/4] Cleaning previous build...
cd /d "%PROJECT_DIR%"
"%FLUTTER%" clean
if %errorlevel% neq 0 (
    echo [WARNING] Clean had issues, continuing anyway...
)

echo.
echo [2/4] Getting dependencies...
"%FLUTTER%" pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies.
    pause
    exit /b 1
)

echo.
echo [3/4] Building Release APK (single universal APK)...
"%FLUTTER%" build apk --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] APK build failed! Trying with verbose output...
    "%FLUTTER%" build apk --release --no-tree-shake-icons --verbose 2>&1 | findstr /i "error\|FAILED\|exception"
    pause
    exit /b 1
)

echo.
echo [4/4] Build SUCCESS!
echo.
echo ================================================
echo   APK LOCATION:
echo   build\app\outputs\flutter-apk\app-release.apk
echo ================================================
echo.

:: Show file size
for %%F in ("%PROJECT_DIR%build\app\outputs\flutter-apk\app-release.apk") do (
    set /a SIZE_MB=%%~zF / 1048576
    echo   File size: !SIZE_MB! MB
)
echo.
echo HOW TO INSTALL ON YOUR PHONE:
echo   1. Copy app-release.apk to your phone
echo   2. On your phone: Settings -> Security -> Unknown Sources (ENABLE)
echo   3. Or: Settings -> Apps -> Special Access -> Install Unknown Apps
echo   4. Find the APK in your file manager and tap to install
echo   5. If "App Not Installed" error: UNINSTALL the old version first!
echo.
echo Opening APK folder...
explorer "%PROJECT_DIR%build\app\outputs\flutter-apk\"

pause
