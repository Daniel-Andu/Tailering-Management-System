@echo off
setlocal

rem Connect your Android phone with USB debugging enabled, then run this file.
rem This skips Flutter's online version/package checks.
flutter --no-version-check build apk --release --no-pub --split-per-abi --no-tree-shake-icons
if errorlevel 1 exit /b %errorlevel%

flutter --no-version-check install --release --no-pub
