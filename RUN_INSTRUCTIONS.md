# Run Instructions for Flutter Tailoring System

## Step 1: Open Command Prompt

1. Press `Win + R`
2. Type `cmd` and press Enter

## Step 2: Navigate to Project

```cmd
cd C:\Users\dniel\TailoringSystem\flutter_project
```

## Step 3: Get Dependencies

```cmd
C:\Flutter\src\flutter\bin\flutter.bat pub get
```

If this fails, try:
```cmd
flutter pub get
```

## Step 4: Run the App

### Option A: Run on Windows Desktop
```cmd
flutter run -d windows
```

### Option B: Run on Android Emulator
```cmd
flutter run
```

### Option C: Run on Android Device (USB connected)
```cmd
flutter run
```

## Step 5: Build for Distribution

### Android APK
```cmd
flutter build apk --release
```
Output: `build\app\outputs\flutter-apk\app-release.apk`

### Windows EXE
```cmd
flutter build windows --release
```
Output: `build\windows\runner\Release\`

## Troubleshooting

### If flutter command not found:
Add Flutter to PATH:
1. Search "Environment Variables" in Windows
2. Click "Environment Variables"
3. Under "System variables", find "Path" and click "Edit"
4. Click "New" and add: `C:\Flutter\src\flutter\bin`
5. Click OK on all dialogs
6. Restart Command Prompt

### If dependencies fail:
```cmd
flutter clean
flutter pub get
```

### If Android build fails:
```cmd
flutter doctor --android-licenses
flutter clean
flutter pub get
flutter build apk
```

## What's Included

✅ All screens implemented
✅ Customer management
✅ Order management
✅ Dashboard with statistics
✅ License system (30-day trial)
✅ Amharic and English support
✅ Beautiful UI with Material Design
✅ Logo included
✅ Offline functionality

## Testing the App

1. **License Screen**: Click "Continue Trial" for 30-day trial
2. **Home Screen**: Navigate to different sections
3. **Customers**: Add, edit, delete customers
4. **Orders**: Add, edit, delete orders
5. **Dashboard**: View statistics
6. **Language**: Toggle between English and Amharic

## Generate License Key

Use the existing Java license generator:
```cmd
cd C:\Users\dniel\TailoringSystem
javac LicenseKeyGenerator.java
java LicenseKeyGenerator
```

Then use the generated key in the app's license screen.

## Support

If you encounter issues:
- Run `flutter doctor` to check setup
- Check Flutter documentation: https://flutter.dev/docs
