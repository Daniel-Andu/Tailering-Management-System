@echo off
title Create Debug Keystore (if missing)

set KEYSTORE_PATH=C:\Users\Daniel\.android\debug.keystore

if exist "%KEYSTORE_PATH%" (
    echo [OK] Debug keystore already exists at: %KEYSTORE_PATH%
    goto :done
)

echo [INFO] Debug keystore not found. Creating it now...

:: Create the .android folder if it doesn't exist
if not exist "C:\Users\Daniel\.android" mkdir "C:\Users\Daniel\.android"

:: Find keytool (comes with Java/JDK)
set KEYTOOL=
for %%P in (
    "C:\Program Files\Java\jdk-17\bin\keytool.exe"
    "C:\Program Files\Java\jdk-11\bin\keytool.exe"
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.0.35-hotspot\bin\keytool.exe"
    "C:\Flutter\src\flutter\bin\cache\artifacts\engine\windows-x64\keytool.exe"
) do (
    if exist %%P set KEYTOOL=%%P
)

:: Try to find keytool in PATH
if "%KEYTOOL%"=="" (
    where keytool >nul 2>&1
    if %errorlevel% equ 0 set KEYTOOL=keytool
)

if "%KEYTOOL%"=="" (
    echo [ERROR] keytool not found. Please install JDK.
    echo  Download from: https://adoptium.net/
    pause
    exit /b 1
)

echo Using keytool: %KEYTOOL%
echo.
echo Generating debug keystore (this is a standard Android debug key)...
%KEYTOOL% -genkeypair -v ^
    -keystore "%KEYSTORE_PATH%" ^
    -alias androiddebugkey ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity 10000 ^
    -storepass android ^
    -keypass android ^
    -dname "CN=Android Debug,O=Android,C=US"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to create keystore.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Debug keystore created at: %KEYSTORE_PATH%

:done
echo.
echo Now run build_release_apk.bat to build your APK.
pause
