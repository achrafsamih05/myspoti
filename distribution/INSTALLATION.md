# Myspoti iOS — Sideloading & Installation Guide

This document explains how to sign and install the unsigned `Myspoti.ipa` binary onto your iPhone using a **free personal Apple ID**.

> **Important Notice**:  
> `Myspoti.ipa` is distributed as an **unsigned application package**. iOS security blocks direct installation of unsigned packages without personal code signing. You must sign the binary using your own Apple ID with a trusted sideloading tool. A paid Apple Developer account is **NOT** required.

---

## 1. Prerequisites

1. **iPhone Hardware**:
   - iPhone running **iOS 17.0 or higher** (iOS 17.5 / 18+ supported).
   - Compatible models: iPhone XR, XS, 11, 12, 13, 14, 15, and 16 series, plus iPhone SE (2nd & 3rd Gen).
2. **Apple Account**:
   - Free personal Apple ID (your everyday iCloud account).
3. **Computer**:
   - Windows 11 / 10 PC (or Mac).
   - Genuine Apple USB / Lightning cable.
4. **Downloaded Files**:
   - `Myspoti.ipa` (from the latest [GitHub Release](https://github.com/achrafsamih05/myspoti/releases)).
   - `SHA256SUMS.txt` (optional, to verify file integrity).

---

## 2. Integrity Verification (Optional but Recommended)

Before installing, you can verify that the downloaded `Myspoti.ipa` has not been corrupted or tampered with.

### On Windows PowerShell
```powershell
Get-FileHash -Algorithm SHA256 .\Myspoti.ipa
```
Compare the resulting hash against the hash listed in `SHA256SUMS.txt` or on the GitHub Release page.

### On macOS / Linux
```bash
shasum -a 256 Myspoti.ipa
# Or if SHA256SUMS.txt is in the same directory:
sha256sum -c SHA256SUMS.txt
```

---

## 3. Installation Methods

### Method 1: Sideloadly (Recommended for Windows 11)

Sideloadly is the most direct tool for sideloading IPAs on Windows.

1. **Install Prerequisites on Windows**:
   - Download and install **iTunes for Windows (64-bit)** directly from Apple ([Direct Link](https://www.apple.com/itunes/download/win64)) — **do not** use the Microsoft Store version.
   - Download and install **iCloud for Windows** directly from Apple ([Direct Link](https://updates.cdn-apple.com/2020/windows/001-39935-20200911-1A70AA56-F448-11EA-8109-99D40553A420/iCloudSetup.exe)) — **do not** use the Microsoft Store version.
2. **Download Sideloadly**:
   - Download from [sideloadly.io](https://sideloadly.io/) and install it.
3. **Connect Your iPhone**:
   - Connect your iPhone to your PC using a USB cable.
   - Unlock your iPhone and tap **"Trust This Computer"** when prompted, entering your passcode.
4. **Sign and Sideload**:
   - Open Sideloadly. Verify that your connected iPhone appears in the **iDevice** field.
   - Drag and drop `Myspoti.ipa` onto the large IPA icon on the left.
   - In the **Apple ID** field, type your personal Apple ID email address.
   - Click the **Start** button.
   - When prompted, enter your Apple ID password and 2-Factor Authentication (2FA) verification code.
     *(Sideloadly communicates directly with Apple's developer API to generate a free 7-day personal development certificate).*
5. **Complete Device Setup**:
   - Once Sideloadly displays `Done`, proceed to [Section 4: Device Configuration](#4-device-configuration).

---

### Method 2: AltStore Classic (Windows + iPhone)

1. **Install AltServer**:
   - Download and install [AltServer for Windows](https://altstore.io/).
   - Ensure iTunes and iCloud (non-Store versions) are installed and running.
2. **Install AltStore to iPhone**:
   - Connect iPhone via USB.
   - In the Windows system tray, click the AltServer diamond icon → **Install AltStore** → select your iPhone.
   - Enter your Apple ID and password.
3. **Sideload Myspoti**:
   - On your iPhone, download `Myspoti.ipa` from Safari into the **Files** app.
   - Open the **AltStore** app on your iPhone.
   - Navigate to **My Apps** → tap the **+** button in the top-left corner.
   - Select `Myspoti.ipa`. AltStore will sign and install the application over Wi-Fi.

---

### Method 3: SideStore (On-Device Computer-Free Renewal)

1. Follow the [SideStore setup guide](https://sidestore.io/) to perform the one-time computer pairing via the local WireGuard VPN profile.
2. Download `Myspoti.ipa` directly in Mobile Safari on your iPhone.
3. Open SideStore, ensure the local WireGuard VPN toggle is connected, tap **+**, and choose `Myspoti.ipa`.
4. SideStore signs and refreshes the application on-device over Wi-Fi without ever needing a PC again.

---

## 4. Device Configuration (Mandatory for iOS 16 & 17+)

Before you can open Myspoti for the first time, iOS requires two standard security steps:

### A. Enable Developer Mode (iOS 16 & iOS 17+)
1. On your iPhone, open **Settings**.
2. Tap **Privacy & Security**.
3. Scroll to the very bottom and tap **Developer Mode**.
4. Toggle Developer Mode to **ON**.
5. Tap **Restart** when prompted.
6. After your iPhone reboots, unlock it and tap **Turn On**, then enter your passcode.

### B. Trust the Personal Certificate
1. On your iPhone, open **Settings**.
2. Tap **General** → **VPN & Device Management**.
3. Under the **Developer App** section, tap your Apple ID email address.
4. Tap **Trust "[Your Apple ID]"** and confirm.
5. You can now launch **Myspoti** from your Home Screen!

---

## 5. Free Apple ID Expiration & Renewal

- **7-Day Validity**: Apple restricts apps signed with free personal Apple IDs to a 7-day certificate window.
- **Renewal**:
  - **With Sideloadly**: Connect your iPhone to your PC once a week, drag `Myspoti.ipa` into Sideloadly, and click Start (takes ~15 seconds).
  - **With AltStore / SideStore**: The app refreshes automatically in the background when connected to your home Wi-Fi.
- **Data Preservation**: Refreshing or reinstalling Myspoti in-place **never deletes your data**, cache, or app settings.

---

## 6. Troubleshooting Common Issues

| Error Message | Cause | Resolution |
| :--- | :--- | :--- |
| **"Developer Mode Disabled"** | Developer Mode is off on iOS 16/17+. | Open Settings → Privacy & Security → Developer Mode → Toggle ON and restart device. |
| **"Untrusted Developer"** | Certificate not yet trusted in iOS settings. | Open Settings → General → VPN & Device Management → Tap Apple ID → Tap Trust. |
| **"App ID Limit Reached"** | Apple allows max 3 active sideloaded apps per free Apple ID. | Deactivate or uninstall unused sideloaded apps, or wait for expired App IDs to cycle (7 days). |
| **"Incorrect Apple ID or Password"** | Typo or 2FA challenge timed out. | Retype Apple ID credentials carefully in Sideloadly; check iPhone screen for 2FA prompt. |
| **"iTunes / iCloud not found"** | Windows Store versions installed. | Uninstall Windows Store versions and install the direct setup executables from Apple. |

---

## 7. Security and Privacy

- **No Credentials Handled by Myspoti**: Myspoti and its distribution system never request, store, or transmit your Apple ID or password. Sideloading tools communicate directly with Apple's authentication servers.
- **Open Source**: Myspoti is licensed under **GPL-3.0**. The source code is publicly inspectable at [https://github.com/achrafsamih05/myspoti](https://github.com/achrafsamih05/myspoti).

