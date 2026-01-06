# Flutter Installation Guide for Windows (Using Chocolatey)

## Prerequisites
- Windows 10 or later
- Chocolatey installed (you already have this ✅)
- Administrator privileges (for Chocolatey installation)

## Step-by-Step Installation

### Step 1: Install Flutter using Chocolatey

Open PowerShell as Administrator and run:

```powershell
choco install flutter -y
```

This will:
- Install Flutter SDK
- Add Flutter to your PATH
- Install Git (if not already installed)
- Install Android Studio dependencies

**Note:** The installation may take 10-15 minutes depending on your internet speed.

### Step 2: Verify Installation

Close and reopen PowerShell (or restart your terminal), then run:

```powershell
flutter --version
```

You should see output like:
```
Flutter 3.x.x • channel stable • ...
```

### Step 3: Run Flutter Doctor

Check for any missing dependencies:

```powershell
flutter doctor
```

This will show you what's installed and what's missing.

### Step 4: Install Required Dependencies

Based on `flutter doctor` output, you may need to install:

#### A. Android Studio (for Android development)
```powershell
choco install androidstudio -y
```

After installation:
1. Open Android Studio
2. Go through the setup wizard
3. Install Android SDK (API level 33 or higher)
4. Install Android SDK Command-line Tools
5. Accept Android licenses

#### B. Visual Studio (for Windows desktop development - optional)
```powershell
choco install visualstudio2022community -y
```

Or if you only need the build tools:
```powershell
choco install visualstudio2022buildtools -y
```

#### C. Accept Android Licenses
```powershell
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

### Step 5: Verify Complete Setup

Run again:
```powershell
flutter doctor -v
```

You should see checkmarks (✓) for:
- Flutter
- Android toolchain
- Android Studio
- VS Code (optional but recommended)
- Connected device (when you connect a device/emulator)

### Step 6: Install VS Code (Recommended)

For better Flutter development experience:

```powershell
choco install vscode -y
```

Then install Flutter and Dart extensions in VS Code:
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Flutter" and install
4. Search for "Dart" and install

### Step 7: Set Up Android Emulator (Optional but Recommended)

1. Open Android Studio
2. Go to Tools → Device Manager
3. Click "Create Device"
4. Select a device (e.g., Pixel 5)
5. Download a system image (e.g., API 33)
6. Finish the setup

### Step 8: Verify Everything Works

Create a test project:
```powershell
cd C:\Users\umair\OneDrive\Desktop\Digi-Khata-Clone
flutter create test_app
cd test_app
flutter run
```

If everything is set up correctly, the app should launch.

## Troubleshooting

### Issue: Flutter not found in PATH
**Solution:** Restart your terminal/PowerShell after installation.

### Issue: Android licenses not accepted
**Solution:** Run `flutter doctor --android-licenses` and accept all.

### Issue: Missing Android SDK
**Solution:** 
1. Open Android Studio
2. Go to Settings → Appearance & Behavior → System Settings → Android SDK
3. Install Android SDK Platform-Tools and Android SDK Build-Tools

### Issue: Git not found
**Solution:** 
```powershell
choco install git -y
```

## Next Steps

After installation is complete:
1. Verify with `flutter doctor`
2. Create the Flutter project for DigiKhata Clone
3. Set up the project structure
4. Install required packages

## Quick Reference Commands

```powershell
# Check Flutter version
flutter --version

# Check setup status
flutter doctor

# Check setup status (verbose)
flutter doctor -v

# Accept Android licenses
flutter doctor --android-licenses

# Update Flutter
flutter upgrade

# List available devices
flutter devices
```

---

**Once Flutter is installed, we'll proceed with creating the Flutter project structure.**




