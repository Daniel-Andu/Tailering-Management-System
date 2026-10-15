@echo off
title Setup Android Emulator for Tailoring System
setlocal EnableDelayedExpansion

set SDK=%LOCALAPPDATA%\Android\Sdk
set CMDLINE_TOOLS=%SDK%\cmdline-tools\latest\bin
set AVD_NAME=Tailoring_Pixel6

echo ================================================
echo  Android Emulator Setup
echo ================================================
echo.

:: Check if cmdline-tools exist
if not exist "%CMDLINE_TOOLS%\avdmanager.bat" (
    echo [ERROR] Android cmdline-tools not found.
    echo.
    echo Please open Android Studio and install:
    echo  1. SDK Manager ^> SDK Tools tab
    echo  2. Check "Android SDK Command-line Tools (latest)"
    echo  3. Click Apply
    echo.
    pause
    exit /b 1
)

echo [1/2] Creating Android Virtual Device...
echo Using already-downloaded system image: android-37.0

"%CMDLINE_TOOLS%\avdmanager.bat" create avd ^
    --name "%AVD_NAME%" ^
    --package "system-images;android-37.0;google_apis_playstore;x86_64" ^
    --device "pixel_6" ^
    --force

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to create AVD.
    echo Trying alternative image...
    "%CMDLINE_TOOLS%\avdmanager.bat" list target
    pause
    exit /b 1
)

echo.
echo [2/2] AVD Created Successfully!
echo.
echo ================================================
echo  DONE! To start the emulator, run:
echo.
echo  %SDK%\emulator\emulator.exe -avd %AVD_NAME%
echo.
echo  Then in your project terminal run:
echo  flutter run
echo ================================================
echo.

set /p START="Start emulator now? (y/n): "
if /i "%START%"=="y" (
    echo Starting emulator...
    start "" "%SDK%\emulator\emulator.exe" -avd %AVD_NAME%
    echo Emulator starting in background. Wait 1-2 minutes then run: flutter run
)

pause
