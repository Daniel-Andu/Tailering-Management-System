# Scripts

This folder contains build and development automation scripts for the Tailoring Management System.

## Build Scripts

- `build_release_apk.bat` - Build production APK for distribution
- `build_release_fast.bat` - Fast debug build for testing
- `install_release_to_mobile.bat` - Install APK to connected Android device

## Setup Scripts

- `setup_emulator.bat` - Setup Android emulator for development
- `create_keystore_if_missing.bat` - Generate signing keystore for releases

## Asset Generation Scripts

- `generate_icons.ps1` - Generate app icons from source
- `create_icon_png.ps1` - Create PNG icons from SVG
- `download_fonts.ps1` - Download required fonts

## Diagnostic Scripts

- `diagnose_gradle_release.bat` - Troubleshoot Gradle build issues
- `diagnose_release_build.bat` - Debug release build problems
- `run_chrome_offline.bat` - Run web version for testing

## Usage

Run scripts from the project root directory:

```bash
cd "C:\Projects\Tailer System\Tailering-Management-System"
scripts\build_release_apk.bat
```


## Asset Generation Scripts (Added)

- `regenerate_splash_and_icons.bat` - Regenerate app icons and splash screen resources

### Splash Screen & Icon Management

To update app branding:
```bash
scripts\regenerate_splash_and_icons.bat
```

This regenerates:
- Circular app launcher icons (all densities)
- Adaptive icons for Android 8.0+
- Unified splash screen (native + Flutter)
- Web and Windows icons
