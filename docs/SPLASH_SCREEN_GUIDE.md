# Splash Screen & App Icon Guide

## Overview

The Tailoring Management System uses a unified splash screen design that creates a seamless user experience with no visible transition between native Android splash and Flutter initialization.

## Design Specifications

### Colors
- **Primary Background**: `#6366F1` (Indigo)
- **Status Bar**: `#6366F1` (Matches background)
- **Navigation Bar**: `#6366F1` (Matches background)

### Icon Design
- **Style**: Circular adaptive icon
- **Background**: Purple/Indigo gradient
- **Foreground**: White tailoring icon (hanger symbol)
- **Size**: Responsive across all densities (mdpi to xxxhdpi)

## Architecture

### 1. Native Android Splash (First Screen)
**Location**: `android/app/src/main/res/drawable/launch_background.xml`

**Purpose**: Shows immediately when app launches (native Android)

**Features**:
- Purple background matching app theme
- Centered app launcher icon
- Displayed before Flutter engine starts

### 2. Flutter Splash (Seamless Transition)
**Location**: `lib/screens/splash_screen.dart`

**Purpose**: Minimal placeholder during Flutter initialization

**Features**:
- Identical purple background to native splash
- No visible content (native splash handles UI)
- Instant transition to license/home screen

## File Structure

```
project/
├── android/app/src/main/res/
│   ├── drawable/
│   │   └── launch_background.xml          # Native splash (API <21)
│   ├── drawable-v21/
│   │   └── launch_background.xml          # Native splash (API 21+)
│   ├── values/
│   │   ├── colors.xml                     # Splash colors definition
│   │   └── styles.xml                     # Light mode splash theme
│   ├── values-night/
│   │   └── styles.xml                     # Dark mode splash theme
│   └── mipmap-*/
│       └── ic_launcher.png                # App icons (all densities)
├── lib/screens/
│   └── splash_screen.dart                 # Flutter splash (minimal)
├── assets/images/
│   └── app_icon.png                       # Source icon for generation
└── tools/
    └── flutter_launcher_icons.yaml        # Icon generation config
```

## Customization

### Change Splash Background Color

1. **Update Android native colors**:
   ```xml
   <!-- android/app/src/main/res/values/colors.xml -->
   <color name="splash_background">#YourColor</color>
   ```

2. **Update Flutter splash**:
   ```dart
   // lib/screens/splash_screen.dart
   backgroundColor: Color(0xFFYourColor)
   ```

### Change App Icon

1. **Replace source image**:
   - Place new icon: `assets/images/app_icon.png`
   - Recommended size: 1024x1024px
   - Format: PNG with transparency

2. **Regenerate icons**:
   ```bash
   scripts\regenerate_splash_and_icons.bat
   ```

### Modify Icon Background (Adaptive Icon)

```yaml
# tools/flutter_launcher_icons.yaml
adaptive_icon_background: "#NewColor"
```

## Regenerating Assets

### Automated (Recommended)
```bash
cd "C:\Projects\Tailer System\Tailering-Management-System"
scripts\regenerate_splash_and_icons.bat
```

### Manual Steps
```bash
# 1. Clean build
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Generate icons
flutter pub run flutter_launcher_icons -f tools/flutter_launcher_icons.yaml

# 4. Rebuild app
flutter run
```

## Testing Checklist

After making changes, test:

- [ ] **Native splash appears immediately** on app launch
- [ ] **No flash/transition** between native and Flutter splash
- [ ] **Status bar color** matches splash background
- [ ] **Navigation bar color** matches splash background
- [ ] **App icon** displays correctly in launcher
- [ ] **Circular icon** on Android 8.0+ (Adaptive Icons)
- [ ] **Dark mode** splash uses same colors
- [ ] **Fast transition** to license/home screen

## Troubleshooting

### Issue: Two different splash screens visible
**Cause**: Native and Flutter splash colors don't match

**Fix**: Ensure both use `#6366F1`:
- `android/app/src/main/res/values/colors.xml`
- `lib/screens/splash_screen.dart`

### Issue: Icon not circular
**Cause**: Adaptive icons not generated

**Fix**: 
1. Check `tools/flutter_launcher_icons.yaml` has `adaptive_icon_background`
2. Run: `scripts\regenerate_splash_and_icons.bat`

### Issue: White flash between splashes
**Cause**: Status bar or window background mismatch

**Fix**: Check `android/app/src/main/res/values/styles.xml`:
```xml
<item name="android:statusBarColor">@color/splash_background</item>
<item name="android:navigationBarColor">@color/splash_background</item>
```

## Best Practices

1. **Keep It Simple**: Splash should be minimal and load fast
2. **Match Colors**: Native and Flutter splash must use identical colors
3. **Test on Device**: Emulators may not show true transition speed
4. **Optimize Icon**: Use high-quality 1024x1024px source image
5. **Version Control**: Keep `app_icon.png` in repository for regeneration

## Platform-Specific Notes

### Android 12+ (API 31+)
- Uses splash screen API automatically
- Icon animates with system transition
- Background color from `adaptive_icon_background`

### Android 8-11 (API 26-30)
- Adaptive icons with circular mask
- Background color shows through

### Android 5-7 (API 21-25)
- Standard icons (not adaptive)
- Circular appearance through icon design

## References

- [Flutter Splash Screen Documentation](https://docs.flutter.dev/development/ui/splash-screen)
- [Android Splash Screens](https://developer.android.com/develop/ui/views/launch/splash-screen)
- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
