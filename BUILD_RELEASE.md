# How to Build the Release APK

## Quick Build (for installation on phones)

Run this command in the project directory:

```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Without release-signing credentials, this APK is signed with the Android debug
key for local testing. Do not distribute that APK as a production release.

For production signing, provide these environment variables before building:

- `ANDROID_RELEASE_STORE_FILE`: path to your private `.jks` or `.keystore` file
- `ANDROID_RELEASE_STORE_PASSWORD`
- `ANDROID_RELEASE_KEY_ALIAS`
- `ANDROID_RELEASE_KEY_PASSWORD`

Keep the keystore and passwords out of source control. Back up the keystore:
future updates must use the same signing key.

## Install on a phone via USB

```bash
flutter install --release
```

## If you get "App Not Installed" error on the phone

This happens when:
1. The phone already has an older version signed with a different key
2. The device's Android version is lower than the APK's minimum supported version

For case 1, uninstall the old app first, then install the new APK. Uninstalling
also removes that app's local data. For case 2, install on a supported device or
emulator. The Chrome console's `sqflite_sw.js` error is web-only and does not
diagnose Android APK installation or startup failures.

## Enable installation from Unknown Sources on Android

1. Go to Settings → Security (or Privacy)
2. Enable "Install from Unknown Sources" or "Install Unknown Apps"
3. Then install the APK

## For Play Store distribution

Create a proper keystore:
```bash
keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

Then update `android/app/build.gradle.kts` with:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file("/path/to/my-release-key.jks")
        storePassword = "your_store_password"
        keyAlias = "my-key-alias"
        keyPassword = "your_key_password"
    }
}
```
