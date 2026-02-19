## AVD System Freezes:

If launching the emulator causes your **entire Windows OS to freeze**, it is usually a kernel conflict with HAXM or AEHD drivers acceleration driver. Switch to the native **Windows Hypervisor Platform (WHPX)**.

### Step 1: Remove Conflicting Drivers

Open **Command Prompt as Administrator**:

```cmd
:: 1. Check if services exist
sc query intelhaxm
sc query aehd

:: 2. If running, stop and delete them
sc stop aehd & sc delete aehd
sc stop intelhaxm & sc delete intelhaxm

:: 3. Clean up sdkmanager files
sdkmanager --uninstall "extras;intel;Hardware_Accelerated_Execution_Manager"

```

### Step 2: Enable Native Windows Features

1. Search for **"Turn Windows features on or off"**.
2. Enable **Windows Hypervisor Platform** and **Virtual Machine Platform**.

### Step 3: Force Hypervisor Boot Flag

This command ensures the hypervisor engine get loaded on startup.

```cmd
bcdedit /set hypervisorlaunchtype auto

```

> [!IMPORTANT]
> **RESTART YOUR COMPUTER NOW.** The hypervisor will not load into memory until a full system reboot.

### Step 4: Verify Acceleration

```cmd
"%ANDROID_HOME%\emulator\emulator.exe" -accel-check

```

**Success Output:** `accel: 0 Windows Hypervisor Platform (WHPX) is installed and usable.`