# Secure Lock App

A comprehensive Android app locker application built with Flutter that provides multi-method authentication (PIN, password, fingerprint, pattern) with advanced security features including intruder detection, automation rules, and privacy vault.

## Quick Start - Test the App Now!

The app is **already running**! Open your browser and visit:

**http://localhost:8080**

Follow the on-screen wizard to set up the app and explore its features.

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Testing Guide](#testing-guide-end-to-end)
- [Project Structure](#project-structure)
- [Development](#development)
- [Troubleshooting](#troubleshooting)

---

## Features

### Core Features (MVP - Currently Implemented)
- ✅ **Multi-Method Authentication**
  - PIN (4-6 digits)
  - Password with strength validation
  - Biometric (fingerprint/face) - Android only

- ✅ **App Locking System**
  - Lock/unlock individual apps
  - Visual app selection interface
  - Search and filter apps
  - Persistent lock settings

- ✅ **Security Features**
  - AES-256-GCM encryption
  - Secure storage for sensitive data
  - Password hashing with salt
  - Failed attempt tracking
  - Auto-lockout after 5 failed attempts

- ✅ **User Experience**
  - Beautiful Material 3 design
  - Light/Dark/System themes
  - Smooth onboarding flow
  - Intuitive dashboard
  - Real-time statistics

### Planned Features (See Complete Prompt.md)
- Intruder detection with photo capture
- Smart automation (location/time/WiFi-based)
- Privacy vault for photos/videos
- Usage analytics and monitoring
- Break-in alerts
- Anti-tampering measures

---

## Requirements

### System Requirements
- **Flutter SDK:** 3.0.0 or higher (Currently using 3.35.7)
- **Dart SDK:** 3.0.0 or higher (Currently using 3.9.2)
- **Android Studio:** Arctic Fox or higher (for Android deployment)
- **Java:** JDK 11 or higher
- **Gradle:** 7.0 or higher

### Target Android Versions
- **Minimum SDK:** Android 8.0 (API Level 26)
- **Target SDK:** Android 14+ (API Level 34)
- **Compile SDK:** 34

### Development Environment
```bash
# Verify installations
flutter --version
dart --version
java -version
```

---

## Installation

### 1. Navigate to Project Directory
```bash
cd "/home/tempadmin/Documents/Workspace/Lock App/secure_lock_app"
```

### 2. Install Dependencies
```bash
# Add Flutter to PATH
export PATH="$PATH:/home/tempadmin/flutter/bin"

# Install packages
flutter pub get
```

### 3. Verify Setup
```bash
flutter doctor
```

---

## Running the App

### Method 1: Web (Chrome) - For Testing
```bash
# Add Flutter to PATH
export PATH="$PATH:/home/tempadmin/flutter/bin"

# Navigate to project
cd "/home/tempadmin/Documents/Workspace/Lock App/secure_lock_app"

# Run on Chrome
flutter run -d chrome
```

**Access at:** http://localhost:8080

### Method 2: Android Device (Production)

#### a. Connect Android Device
1. Enable **Developer Options** on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go to Settings > Developer Options
   - Enable "USB Debugging"

2. Connect device via USB

3. Verify connection:
```bash
flutter devices
```

#### b. Run on Android
```bash
flutter run
```

Or build APK:
```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Testing Guide (End-to-End)

### Step 1: Launch the App
Open http://localhost:8080 in your browser (if running on web)

### Step 2: Complete Onboarding
1. **Splash Screen** - You'll see the app logo with a loading animation
2. **Welcome Screen** - Read about the features
3. **Swipe through 3 onboarding pages**:
   - Page 1: Multi-Method Authentication
   - Page 2: Smart App Locking
   - Page 3: Advanced Security
4. Click **"Get Started"**

### Step 3: Set Up Authentication

#### PIN Setup
1. You'll be prompted to **"Create a PIN"**
2. Enter a 4-6 digit PIN (e.g., `123456`)
3. Click **"Continue"**
4. **Confirm your PIN** by entering it again
5. Click **"Confirm"**
6. You'll see a success message

#### Skip Biometric (Web Only)
- If on web, you'll see a warning that biometric is not available
- Click **"Skip for now"** to continue

### Step 4: Explore the Home Screen

You'll see the **Dashboard** with:

**Statistics**
- Number of locked apps
- Total unlock attempts
- Apps installed count

**Locked Apps List**
- Initially empty (no apps locked yet)
- Shows a message: "No locked apps yet"

**Floating Action Button (+)**
- Click to add apps to lock

### Step 5: Lock Apps

1. Click the **floating "+" button** on the home screen
2. You'll see the **App Selection Screen** with 15 sample apps:
   - WhatsApp
   - Facebook
   - Instagram
   - Gmail
   - Twitter/X
   - Snapchat
   - TikTok
   - Telegram
   - Messages
   - Gallery
   - Phone
   - Chrome
   - YouTube
   - Banking App
   - Dating App

3. **Search functionality**: Type in the search box to filter apps
4. **Lock apps**: Tap the toggle switch next to any app to lock it
5. **Visual feedback**: Locked apps show a checkmark and "Locked" badge
6. Try locking **WhatsApp**, **Instagram**, and **Gmail**
7. Click **"Back"** to return to home

### Step 6: Verify Locked Apps

Back on the home screen:
- Statistics update to show **3 locked apps**
- Locked apps appear in the list with:
  - App icon
  - App name
  - Package name
  - "Locked" status badge
  - Quick unlock button

### Step 7: Test Quick Unlock

1. Find **WhatsApp** in the locked apps list
2. Click the **unlock icon** (🔓) on the right
3. You'll be redirected to the **Lock Screen**
4. Enter your PIN (e.g., `123456`)
5. Click **"Unlock"**
6. **WhatsApp will be unlocked** and removed from the list
7. Statistics update to show **2 locked apps**

### Step 8: Test Failed Attempts

1. Lock WhatsApp again
2. Click unlock on WhatsApp
3. **Enter wrong PIN** (e.g., `000000`)
4. You'll see an error: **"Invalid PIN"**
5. Attempt counter increases
6. Try 5 wrong attempts in a row
7. After 5 failed attempts:
   - You'll see: **"Too many failed attempts. Try again in 5 minutes"**
   - Lock screen is disabled for 5 minutes
   - This demonstrates the security lockout feature

### Step 9: Explore Settings

1. From home screen, click the **settings icon** (⚙️) in the top-right
2. You'll see **Settings Screen** with options:

**Security Section**
- **Biometric Authentication** toggle
  - On web: Shows warning when trying to enable
  - On Android: Enables fingerprint/face unlock

**Appearance Section**
- **Theme** dropdown with 3 options:
  - Light Mode
  - Dark Mode
  - System Default
- Change theme and see the app update in real-time!

**About Section**
- App version
- Package name

3. Click **"Back"** to return home

### Step 10: Test Theme Switching

1. Go to Settings
2. Change theme to **"Dark Mode"**
3. Notice the entire app switches to dark theme instantly
4. Try **"Light Mode"** to switch back
5. Select **"System Default"** to follow your system preference

### Step 11: Test App Search

1. Go to **App Selection** screen (click + button)
2. Type **"what"** in the search box
3. Only **WhatsApp** appears (filtered)
4. Type **"face"**
5. Only **Facebook** appears
6. Clear the search to see all apps again

### Step 12: Test Bulk Locking

1. From App Selection screen
2. Quickly lock multiple apps:
   - Lock **Facebook**
   - Lock **Twitter/X**
   - Lock **Snapchat**
   - Lock **TikTok**
   - Lock **Telegram**
3. Go back to home
4. See all 5 apps in the locked list
5. Statistics show **5+ locked apps**

### Step 13: Data Persistence Test

1. **Close the browser tab** completely
2. **Reopen** http://localhost:8080
3. **Verify**:
   - You go straight to home screen (setup already complete)
   - All locked apps are still there
   - Your PIN is still configured
   - Theme preference is preserved
4. This demonstrates **persistent storage** using Hive and flutter_secure_storage

### Step 14: Security Test

1. Try to access the app without authentication
2. The system should:
   - Require PIN entry before showing home screen
   - Encrypt all sensitive data
   - Hash passwords securely
3. Check browser console (F12 > Console) to see security logs:
   - Encryption service initialization
   - Secure storage operations
   - Authentication events

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # MultiProvider setup & MaterialApp
│   └── routes.dart                    # Centralized routing
├── core/
│   ├── constants/
│   │   ├── app_constants.dart        # App-wide constants & enums
│   │   ├── colors.dart               # Color palette
│   │   └── strings.dart              # UI strings
│   ├── theme/
│   │   └── app_theme.dart            # Material 3 theme (light/dark/AMOLED)
│   ├── utils/
│   │   └── logger.dart               # Centralized logging
│   └── services/
│       ├── encryption_service.dart   # AES-256-GCM encryption
│       └── storage_service.dart      # Hive + SecureStorage + SharedPrefs
├── data/
│   └── models/
│       ├── user_settings_model.dart  # User settings with JSON serialization
│       ├── locked_app_model.dart     # Locked app data model
│       └── *.g.dart                  # Generated serialization code
└── presentation/
    ├── providers/                     # State management (Provider pattern)
    │   ├── auth_provider.dart        # Authentication logic
    │   ├── app_lock_provider.dart    # App locking logic
    │   └── theme_provider.dart       # Theme management
    ├── widgets/                       # Reusable UI components
    │   ├── custom_button.dart        # Custom buttons
    │   └── custom_text_field.dart    # Custom text fields
    └── screens/                       # App screens
        ├── splash/
        │   └── splash_screen.dart    # Animated splash
        ├── onboarding/
        │   └── onboarding_screen.dart # 3-page onboarding
        ├── setup/
        │   └── pin_setup_screen.dart # PIN creation flow
        ├── home/
        │   └── home_screen.dart      # Main dashboard
        ├── app_selection/
        │   └── app_selection_screen.dart # App selection UI
        ├── lock_screen/
        │   └── lock_screen.dart      # Authentication screen
        └── settings/
            └── settings_screen.dart  # App settings
```

---

## Development

### Hot Reload (Development Mode)
While the app is running in debug mode:
- **Hot Reload:** Press `r` in terminal (applies code changes instantly)
- **Hot Restart:** Press `R` in terminal (full app restart)
- **DevTools:** Visit http://127.0.0.1:9100 for debugging

### Useful Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Check outdated packages
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade

# Clean build
flutter clean && flutter pub get

# Generate model code (after modifying models)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build for Production

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Build with split ABIs (smaller APK)
flutter build apk --split-per-abi
```

---

## Updating After Code Changes

### Option 1: Hot Reload (Fastest - Development Only)
```bash
# App must be running
# Press 'r' in terminal
```

### Option 2: Hot Restart (Development)
```bash
# App must be running
# Press 'R' in terminal
```

### Option 3: Full Rebuild (Production)
```bash
# Stop running app (Ctrl+C or 'q')
flutter clean
flutter pub get
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## Troubleshooting

### App Won't Start
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

### Storage Errors
```bash
# Clear browser storage
# Open DevTools (F12) > Application > Clear Storage
# Or use browser's "Clear Site Data"
```

### Build Errors
```bash
# Regenerate model files
flutter pub run build_runner build --delete-conflicting-outputs
```

### Permission Errors (Android)
- Ensure all permissions are granted in Settings > Apps > Secure Lock App > Permissions
- Required permissions:
  - Camera (for intruder detection)
  - Storage (for vault)
  - Location (for automation)
  - Biometric (for fingerprint)

### Device Not Detected (Android)
```bash
# Restart ADB
adb kill-server
adb start-server
adb devices
```

### Web Version Limitations
- Biometric authentication not available (gracefully degrades)
- Cannot access real installed apps (uses mock data)
- Native Android features won't work

---

## Features Implementation Status

### ✅ Completed (MVP)
- [x] Core architecture setup
- [x] Encryption service (AES-256-GCM)
- [x] Secure storage (Hive + flutter_secure_storage)
- [x] PIN authentication
- [x] Password authentication
- [x] Biometric authentication (Android only)
- [x] App locking system (basic)
- [x] App selection interface
- [x] Lock screen
- [x] Failed attempt tracking
- [x] Auto-lockout mechanism
- [x] Theme switching (light/dark)
- [x] Onboarding flow
- [x] Settings screen
- [x] Data persistence
- [x] Logger utility

### 🚧 Planned (Future Phases)
- [ ] Intruder detection with camera
- [ ] Location-based automation
- [ ] Time-based automation
- [ ] WiFi-based automation
- [ ] Privacy vault (photos/videos/files)
- [ ] Usage analytics
- [ ] Security logs viewer
- [ ] Break-in alerts
- [ ] Anti-tampering (root detection)
- [ ] Device admin (prevent uninstall)
- [ ] Backup & sync
- [ ] Advanced features (see Complete Prompt.md)

---

## Security Notes

### Data Encryption
- All sensitive data encrypted with **AES-256-GCM**
- Encryption keys stored in **flutter_secure_storage**
- Passwords hashed with **SHA-256 + salt**
- No plain-text storage of credentials

### Storage Layers
1. **flutter_secure_storage**: Encryption keys, authentication tokens
2. **Hive**: User settings, locked apps, logs
3. **SharedPreferences**: Non-sensitive preferences

### Authentication Security
- PIN: 4-6 digits, hashed before storage
- Password: Minimum 6 characters, strength validation
- Failed attempts: Maximum 5, then 5-minute lockout
- Biometric: Uses device secure enclave (Android only)

---

## Additional Resources

- **Full Specification:** See `Complete Prompt.md` in project root
- **Project Guidelines:** See `CLAUDE.md` in project root
- **Flutter Documentation:** https://docs.flutter.dev/
- **Android Developer Guide:** https://developer.android.com/

---

## Support & Contributing

For issues, feature requests, or contributions, please refer to the project repository.

---

## License

[Add your license here]

---

## Summary

**The Secure Lock App MVP is fully functional!**

- ✅ Complete authentication system (PIN/Password/Biometric)
- ✅ App locking with persistent storage
- ✅ Beautiful Material 3 UI with themes
- ✅ Security features (encryption, lockout, hashing)
- ✅ Clean architecture with Provider state management
- ✅ Production-ready code with error handling and logging

**Start testing now:** http://localhost:8080
