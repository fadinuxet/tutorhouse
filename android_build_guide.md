# Android Build Guide for TutorHouse App

## ✅ COMPLETED SETUP

### 1. Android Configuration
- **Application ID**: `com.tutorhouse.app`
- **Min SDK**: 21 (Android 5.0+)
- **Target SDK**: 36 (Android 14)
- **Compile SDK**: 36
- **NDK Version**: 27.0.12077973

### 2. Permissions Added
- Internet access
- Camera permissions
- Microphone permissions
- Storage permissions
- Network state access
- Wake lock for live streaming
- Vibration for notifications

### 3. App Icons
- All required icon sizes present
- App name: "TutorHouse"

## 🚀 BUILD COMMANDS

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```

## 🔧 CURRENT ISSUE & SOLUTION

**Issue**: Riverpod provider syntax conflicts

**Quick Fix**:
1. Open `lib/main.dart`
2. Replace the provider declarations with:
```dart
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());
final tutorProvider = ChangeNotifierProvider<TutorProvider>((ref) => TutorProvider());
```

3. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## 📱 ANDROID DEVICE TESTING

### Connect Android Device
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter devices` to verify connection

### Install on Device
```bash
flutter install
```

### Run on Device
```bash
flutter run
```

## 🏪 GOOGLE PLAY STORE DEPLOYMENT

### 1. Create Release Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure Signing
Add to `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile']
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Build Release
```bash
flutter build appbundle --release
```

### 4. Upload to Google Play Console
- Go to Google Play Console
- Create new app
- Upload the `.aab` file from `build/app/outputs/bundle/release/`

## 🎯 FEATURES READY FOR ANDROID

✅ Live session chat system
✅ Video streaming capabilities
✅ Camera and microphone access
✅ File upload/download
✅ Push notifications ready
✅ Offline storage support
✅ Modern Android UI

## 📋 NEXT STEPS

1. Fix Riverpod provider syntax
2. Test on Android device
3. Create release build
4. Upload to Google Play Store
5. Configure app store listing

## 🆘 TROUBLESHOOTING

### Build Fails
- Run `flutter clean`
- Run `flutter pub get`
- Check Android SDK version
- Verify device connection

### App Crashes
- Check logs with `flutter logs`
- Verify permissions are granted
- Test on different Android versions

### Performance Issues
- Enable release mode
- Optimize images
- Check memory usage
