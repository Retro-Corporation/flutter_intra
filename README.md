# flutter_intra

A Flutter application with pose detection using Google ML Kit.

## Environment Setup

### Prerequisites
- Windows 10/11
- Java JDK 17+
- Git

### 1. Install Flutter

Download and install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).

Add Flutter to PATH:
- Extract to `C:\tools\flutter`
- Add `C:\tools\flutter\bin` to your system PATH

Verify installation:
```powershell
flutter --version
dart --version
```

### 2. Android SDK Setup (Without Android Studio)

#### Set ANDROID_HOME environment variable:
```powershell
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android\sdk', 'User')
```

#### Download and install cmdline-tools:
1. Download from [Android Studio Command Line Tools](https://developer.android.com/studio#command-line-tools-only)
2. Extract to `C:\Android\sdk\cmdline-tools\latest\`
3. Add to PATH:
```powershell
$env:PATH += ";C:\Android\sdk\cmdline-tools\latest\bin;C:\Android\sdk\platform-tools;C:\Android\sdk\emulator"
```

#### Install SDK packages:
```powershell
sdkmanager "platform-tools"
sdkmanager "platforms;android-36.1"
sdkmanager "build-tools;36.1.0"
sdkmanager "emulator"
sdkmanager "system-images;android-36.1;google_apis;x86_64"
sdkmanager --licenses
```

### 3. Create Android Emulator

List available devices:
```powershell
avdmanager list device
```

Create AVD (Android Virtual Device):
```powershell
avdmanager create avd -n "Pixel_6_x86_64" -k "system-images;android-36.1;google_apis;x86_64" -d "pixel_6"
```

### 4. PATH Configuration

Ensure your PATH includes (in order):
1. `C:\tools\flutter\bin`
2. `C:\Android\sdk\platform-tools`
3. `C:\Android\sdk\cmdline-tools\latest\bin`
4. `C:\Android\sdk\emulator`

**Important:** Remove standalone Dart SDK from PATH if present. Flutter includes its own Dart in `C:\tools\flutter\bin\cache\dart-sdk`.

### 5. Verify Setup

```powershell
flutter doctor
```

All items should show green checkmarks.

## Running the App

### Start the emulator:
```powershell
emulator -avd Pixel_6_x86_64
```

### In a new terminal, run the app:
```powershell
flutter run
```

Or specify the device:
```powershell
flutter run -d emulator-5554
```

### During development:
- Press `r` for hot reload
- Press `R` for full restart
- Press `p` for debug paint
- Press `q` to quit

## Project Dependencies

- `google_mlkit_pose_detection` - For real-time pose detection

Install dependencies:
```powershell
flutter pub get
```

## File Structure

- `lib/main.dart` — Application entry point (runs the app)
- `lib/app.dart` — Global app configuration (theme, MaterialApp setup)
- `lib/app_shell.dart` — Primary app container and homepage (navigation + persistent runtime)
- `lib/pages/` — Screen-level widgets (no business logic)
- `lib/services/` — Domain-based services and infrastructure
- `android/` - Android-specific configuration
- `ios/` - iOS-specific configuration
- `pubspec.yaml` - Project dependencies and configuration

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [ML Kit for Flutter](https://firebase.google.com/docs/ml-kit/flutter-get-started)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
