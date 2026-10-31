# Myspoti iOS – Build Automation & Personal Installation Guide

> **Notice**: Myspoti iOS is a GPL-3.0 open-source project. This guide enables developers on Windows 11 to register their Spotify Client ID, compile on cloud macOS (Codemagic CI), and sideload the application onto an iPhone using a free personal Apple ID.

---

## 1. Prerequisites

1. **Development Host (Windows 11)**:
   * Git for Windows.
   * Visual Studio Code or text editor.
2. **Apple Device**:
   * Physical iPhone running iOS 17.0+.
   * Free personal Apple Account (no paid Apple Developer membership needed).
3. **Cloud Infrastructure**:
   * GitHub repository.
   * Free [Codemagic](https://codemagic.io) account connected to the repository.
4. **Spotify Developer Registration**:
   * Free Spotify Developer account at [developer.spotify.com](https://developer.spotify.com).

---

## 2. Spotify Developer Dashboard Setup

Because Myspoti iOS uses the official Spotify Web API with OAuth 2.0 PKCE, you need to register a Spotify Client ID:

1. Log in to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).
2. Click **Create an App**:
   * **App Name**: `Myspoti iOS`
   * **App Description**: `Personal native iOS music player`
   * **Redirect URI**: `myspoti://callback`
   * **Which API/SDKs are you planning to use?**: Select **Web API** and **iOS SDK**.
3. Under **Settings**, copy your **Client ID**. *(Note: With PKCE, you NEVER need or use the Client Secret).*
4. Navigate to **User Management**:
   * Add your personal Spotify account email address to the allowlist (Spotify Development Mode allows up to 5 allowlisted accounts).
   * *Requirement*: The owner account of the Spotify Developer app must hold an active Spotify Premium subscription.

---

## 3. Project Generation with XcodeGen (`project.yml`)

The iOS project is maintained using **XcodeGen**. This code-first approach eliminates manual `.xcodeproj` edits on Windows.

### 3.1 Project Specification (`ios/project.yml`)

```yaml
name: Myspoti
options:
  bundleIdPrefix: app.myspoti
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "15.4"

settings:
  base:
    SWIFT_VERSION: "5.10"
    IPHONEOS_DEPLOYMENT_TARGET: "17.0"
    ENABLE_PREVIEWS: YES
    DEVELOPMENT_TEAM: ""

packages:
  MyspotiDomain:
    path: Packages/MyspotiDomain
  MyspotiNetwork:
    path: Packages/MyspotiNetwork
  MyspotiAudio:
    path: Packages/MyspotiAudio
  MyspotiUI:
    path: Packages/MyspotiUI

targets:
  Myspoti:
    type: application
    platform: iOS
    sources:
      - path: Sources/MyspotiApp
    dependencies:
      - package: MyspotiDomain
      - package: MyspotiNetwork
      - package: MyspotiAudio
      - package: MyspotiUI
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: app.myspoti.ios
      INFOPLIST_FILE: Sources/MyspotiApp/Info.plist
      ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
    entitlements:
      path: Sources/MyspotiApp/Myspoti.entitlements
```

---

## 4. Codemagic Cloud Build Pipeline (`codemagic.yaml`)

Codemagic compiles the app on cloud Apple Silicon macOS machines.

### 4.1 Build Workflow

```yaml
workflows:
  ios-build-and-test:
    name: Myspoti iOS – Build and Test
    instance_type: mac_mini_m2
    max_build_duration: 30
    environment:
      xcode: 15.4
      cocoapods: default
    scripts:
      - name: Install XcodeGen
        script: |
          brew install xcodegen
      - name: Generate Xcode Project via XcodeGen
        script: |
          cd ios
          xcodegen generate
      - name: Resolve Swift Package Dependencies
        script: |
          cd ios
          xcodebuild -resolvePackageDependencies -project Myspoti.xcodeproj -scheme Myspoti
      - name: Execute Unit Test Suite
        script: |
          cd ios
          xcodebuild test \
            -project Myspoti.xcodeproj \
            -scheme Myspoti \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO
      - name: Build for Generic iOS Device
        script: |
          cd ios
          xcodebuild build \
            -project Myspoti.xcodeproj \
            -scheme Myspoti \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO
      - name: Build and Archive Release Candidate
        script: |
          cd ios
          xcodebuild archive \
            -project Myspoti.xcodeproj \
            -scheme Myspoti \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            -archivePath build/Myspoti.xcarchive \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO
      - name: Package Payload into Sideloadable .ipa
        script: |
          cd ios
          mkdir -p build/Payload
          cp -r build/Myspoti.xcarchive/Products/Applications/Myspoti.app build/Payload/
          cd build
          zip -qr Myspoti.ipa Payload
    artifacts:
      - ios/build/Myspoti.ipa
      - ios/build/Myspoti.xcarchive
```

---

## 5. Sideloading onto Your iPhone

Download `Myspoti.ipa` from the Codemagic build artifacts page to your Windows PC.

### 5.1 Installation via Sideloadly (Windows 11)
1. Download and launch [Sideloadly](https://sideloadly.io/).
2. Connect your iPhone to your PC via USB cable.
3. Drag `Myspoti.ipa` into Sideloadly.
4. Enter your personal Apple ID email.
5. Click **Start**. Sideloadly signs and installs the app onto your iPhone.

### 5.2 Wireless Installation via SideStore / AltStore
1. With SideStore installed on your iPhone, place `Myspoti.ipa` in your iCloud Drive or local Files app.
2. Open SideStore, tap `+`, select `Myspoti.ipa`, and install directly over local Wi-Fi.

---

## 6. iOS Device Setup & Trust

1. **Enable Developer Mode (iOS 16 & 17+)**:
   * Open **Settings** → **Privacy & Security** → scroll to **Developer Mode**.
   * Toggle **ON** and reboot the iPhone when prompted.
2. **Trust Certificate**:
   * Open **Settings** → **General** → **VPN & Device Management**.
   * Under **Developer App**, select your Apple ID and tap **Trust**.
