# flutter_intra

A Flutter application with pose detection using Google ML Kit.

## Environment Setup

### Prerequisites
- Windows 10/11
- Java JDK 17+
- Git

### 1. Install Flutter

Download the flutter binary for your platfrom: [flutter.dev](https://docs.flutter.dev/install/manual). Then extract the folder called `flutter`

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
2. Extract the zip file — you'll see folders like `bin` and `lib`
3. Rename the parent folder (containing `bin` and `lib`) to `latest`
4. Move the `latest` folder to `C:\Android\sdk\cmdline-tools\latest\`
5. Navigate to the bin directory and run sdkmanager:
```powershell
cd C:\Android\sdk\cmdline-tools\latest\bin
```

#### Install SDK packages:
```powershell
.\sdkmanager "platform-tools"
.\sdkmanager "platforms;android-36.1"
.\sdkmanager "build-tools;36.1.0"
.\sdkmanager "emulator"
.\sdkmanager "system-images;android-36.1;google_apis;x86_64"
.\sdkmanager --licenses
```

#### Add SDK tools to PATH:
After sdkmanager creates the necessary directories, add them permanently to your PATH:
```powershell
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
[System.Environment]::SetEnvironmentVariable('Path', "$currentPath;C:\Android\sdk\cmdline-tools\latest\bin;C:\Android\sdk\platform-tools;C:\Android\sdk\emulator", 'User')
```
Restart your terminal for the changes to take effect.

### 3. Create Android Emulator

List available devices:
```powershell
avdmanager list device
```

Create AVD (Android Virtual Device):
```powershell
avdmanager create avd -n "Pixel_6_x86_64" -k "system-images;android-36.1;google_apis;x86_64" -d "pixel_6"
```

### 4. Verify Setup

```powershell
flutter doctor
```

All items should show green checkmarks. If you see issues, refer to the Troubleshooting section below.

## File Structure

- `lib/main.dart` — Application entry point (runs the app)
- `lib/app.dart` — Global app configuration (theme, MaterialApp setup)
- `lib/app_shell.dart` — Primary app container and homepage (navigation + persistent runtime)
- `lib/pages/` — Screen-level widgets (no business logic)
- `lib/services/` — Domain-based services and infrastructure
- `android/` - Android-specific configuration
- `ios/` - iOS-specific configuration
- `pubspec.yaml` - Project dependencies and configuration

## Project Dependencies

This project uses `camera` and a fork of `flutter_pose_detection`.
Packages are project-scoped via pubspec.yaml (no Python-style virtualenvs).

Install dependencies (run from repo root):
```powershell
flutter pub get
```

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

## Troubleshooting

### Verify PATH Configuration

If commands like `flutter`, `sdkmanager`, or `emulator` are not recognized, verify your PATH includes:
1. `C:\tools\flutter\bin`
2. `C:\Android\sdk\platform-tools`
3. `C:\Android\sdk\cmdline-tools\latest\bin`
4. `C:\Android\sdk\emulator`

Restart your terminal after modifying PATH.

### Emulator Executable Not Found

If the emulator installs but you get "can't find the emulator executable":

1. Verify the emulator directory exists:
```powershell
Test-Path "C:\Android\sdk\emulator"
```

2. Try running with the full path:
```powershell
"C:\Android\sdk\emulator\emulator.exe" -avd Pixel_6_x86_64
```

3. If the directory doesn't exist or the exe isn't there, reinstall the emulator:
```powershell
cd C:\Android\sdk\cmdline-tools\latest\bin
.\sdkmanager "emulator"
```

4. Close all terminals and open a new one to refresh PATH.

### Corrupted Emulator Package

The emulator package itself can corrupt due to interrupted downloads or incomplete installations. If you suspect corruption:

1. Uninstall it:
```powershell
cd C:\Android\sdk\cmdline-tools\latest\bin
.\sdkmanager --uninstall "emulator"
```

2. Clean up any leftover files:
```powershell
Remove-Item "C:\Android\sdk\emulator" -Recurse -Force
```

3. Reinstall:
```powershell
.\sdkmanager "emulator"
```

4. Close all terminals and open a new one.

### Delete and Recreate an Emulator

If you need to delete an AVD and recreate it:

```powershell
avdmanager delete avd -n "Pixel_6_x86_64"
avdmanager create avd -n "Pixel_6_x86_64" -k "system-images;android-36.1;google_apis;x86_64" -d "pixel_6"
```

**Note:** If you get "Android Virtual Device already exists", the AVD is already created. You can either use it as-is or delete and recreate with the commands above.

### AVD System Freezes

If launching the emulator causes your **entire Windows OS to freeze**, it's usually a kernel conflict with HAXM or AEHD acceleration drivers. Switch to the native **Windows Hypervisor Platform (WHPX)**.

#### Step 1: Remove Conflicting Drivers

Open **Command Prompt as Administrator**:

```cmd
:: Check if services exist
sc query intelhaxm
sc query aehd

:: If running, stop and delete them
sc stop aehd & sc delete aehd
sc stop intelhaxm & sc delete intelhaxm

:: Clean up sdkmanager files
sdkmanager --uninstall "extras;intel;Hardware_Accelerated_Execution_Manager"
```

#### Step 2: Enable Native Windows Features

1. Search for **"Turn Windows features on or off"**
2. Enable **Windows Hypervisor Platform** and **Virtual Machine Platform**

#### Step 3: Force Hypervisor Boot Flag

This ensures the hypervisor engine loads on startup:

```cmd
bcdedit /set hypervisorlaunchtype auto
```

> [!IMPORTANT]
> **RESTART YOUR COMPUTER NOW.** The hypervisor will not load into memory until a full system reboot.

#### Step 4: Verify Acceleration

```cmd
"%ANDROID_HOME%\emulator\emulator.exe" -accel-check
```

**Expected output:** `accel: 0 Windows Hypervisor Platform (WHPX) is installed and usable.`

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [ML Kit for Flutter](https://firebase.google.com/docs/ml-kit/flutter-get-started)
- [Android Emulator Documentation](https://developer.android.com/studio/run/emulator)
