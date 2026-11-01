# Myspoti iOS — Release Publishing Procedure

This document provides step-by-step instructions for publishing official releases of Myspoti iOS on GitHub Releases.

---

## 1. Release Artifacts Checklist

Every official release includes three core files:

| Artifact | Description | Source |
| :--- | :--- | :--- |
| **`Myspoti.ipa`** | The compiled unsigned iOS application archive. | Downloaded from Codemagic CI build artifacts. |
| **`SHA256SUMS.txt`** | Cryptographic SHA-256 hash file for integrity verification. | Generated via `tools/generate_release_checksums.ps1`. |
| **`INSTALLATION.md`** | Sideloading instructions for end users. | Copied from `distribution/INSTALLATION.md`. |

> **Security Rule**: Never commit `.ipa` binary files directly to the Git repository. Store and distribute them exclusively as GitHub Release assets.

---

## 2. Step-by-Step Publishing Guide

### Step 1: Obtain the Compiled `Myspoti.ipa` from Codemagic
1. In your browser, log in to [Codemagic](https://codemagic.io/).
2. Select your `achrafsamih05/myspoti` project.
3. Start or navigate to the latest successful build of the **`Myspoti iOS – Build, Test & Device Release (.ipa)`** workflow.
4. Under the **Artifacts** section on the right, click **`Myspoti.ipa`** to download it to your Windows computer (e.g., to `Downloads` or `ios/build/`).

### Step 2: Generate Cryptographic Checksums
Open PowerShell in the repository root and run:

```powershell
.\tools\generate_release_checksums.ps1 -IpaPath "$HOME\Downloads\Myspoti.ipa"
```

This generates `SHA256SUMS.txt` containing the exact 64-character hex hash:
```text
<hash>  Myspoti.ipa
```

### Step 3: Create the GitHub Release
1. Navigate to: [https://github.com/achrafsamih05/myspoti/releases/new](https://github.com/achrafsamih05/myspoti/releases/new)
2. **Tag version**: Type `v1.0.0` and select **Create new tag: v1.0.0 on publish** (target: `ios-integration` or `main`).
3. **Release title**: `Myspoti iOS v1.0.0 (Unsigned IPA)`
4. **Description**: Paste the release notes template below.
5. **Attach binaries**:
   - Drag and drop `Myspoti.ipa`.
   - Drag and drop `SHA256SUMS.txt`.
   - Drag and drop `distribution/INSTALLATION.md`.
6. Ensure **Set as the latest release** is checked.
7. Click **Publish release**.

---

## 3. Release Notes Template

```markdown
# Myspoti iOS v1.0.0 — Initial Public Release (Unsigned IPA)

Myspoti is an enhanced, native iOS music application engineered for personal sideloading on modern iPhones running iOS 17.0 and later.

### Highlights
- **True Dark AMOLED Palette**: Optimized for battery efficiency and high-contrast Super Retina displays.
- **Native AVPlayer Engine**: Full background audio playback, Lock Screen controls, and audio route handling.
- **Synchronized Lyrics**: Line-by-line real-time scrolling lyrics powered by LRCLIB.
- **100% Free & Standalone**: Operates out of the box with authorized Creative Commons audio without requiring paid Spotify subscriptions.
- **Official Spotify Web API Linking**: Optional metadata browsing via OAuth 2.0 PKCE.

---

### ⚠️ Important Notice Regarding Unsigned IPAs
This release is distributed as an **unsigned application binary**. iOS does not allow direct installation of unsigned packages. You must sign this IPA using your own free personal Apple ID with a sideloading utility like **Sideloadly**, **AltStore**, or **SideStore**.

---

### Verification
Verify file integrity using SHA-256 before sideloading:
- **Windows PowerShell**: `(Get-FileHash -Algorithm SHA256 .\Myspoti.ipa).Hash`
- **macOS / Linux**: `shasum -a 256 -c SHA256SUMS.txt`

Refer to the attached `INSTALLATION.md` for complete step-by-step installation instructions.
```

---

## 4. URL Endpoints

Once published, GitHub automatically provides these permanent download URLs:

- **Latest Release Web Page**:
  `https://github.com/achrafsamih05/myspoti/releases/latest`
- **Direct IPA Download**:
  `https://github.com/achrafsamih05/myspoti/releases/latest/download/Myspoti.ipa`
- **Specific Version Download (`v1.0.0`)**:
  `https://github.com/achrafsamih05/myspoti/releases/download/v1.0.0/Myspoti.ipa`
- **Public Distribution Website**:
  `https://achrafsamih05.github.io/myspoti/`
