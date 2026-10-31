# Myspoti iOS – Integration Risk Register

> **Notice**: This document tracks technical, platform, legal, and operational risks associated with integrating the official Spotify platform on iOS in a personal deployment environment.

---

## 1. Risk Register Summary Matrix

| Risk ID | Category | Risk Description | Severity | Probability | Mitigation Strategy | Owner | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **RISK-01** | Spotify Platform | **Spotify Connect Playback Control Requires Spotify Premium**: Free-tier accounts receive `403 Forbidden` (`PREMIUM_REQUIRED`) when calling `PUT /v1/me/player/play`. | **High** | **100% (for Free accounts)** | Detect subscription tier via `GET /v1/me` (`product: "premium"` vs `"free"`). If Free, gracefully disable remote control buttons and present a clear explanation with a deep-link button to open the official Spotify app. | Audio / Backend | **Documented & Mitigated** |
| **RISK-02** | Spotify Platform | **Active Playback Device Prerequisite**: Spotify Connect cannot start playback on a completely dormant device. | **Medium** | **High** | Check `GET /v1/me/player/devices`. If no device is active, display an interactive prompt: *"No active Spotify player found. Please open Spotify on your iPhone, Mac, or speaker to begin."* | UI / Backend | **Documented & Mitigated** |
| **RISK-03** | Spotify Platform | **Spotify Developer Dashboard Allowlist Limit (5 Users)**: In Development Mode, each Client ID is capped at 5 allowlisted accounts. | **Low** | **Low (Personal Use)** | Document clearly that the user must add their personal Spotify email under **User Management** in the Spotify Developer Dashboard. | DevOps | **Documented & Mitigated** |
| **RISK-04** | Spotify Platform | **Developer App Owner Premium Requirement**: Spotify requires the dashboard app creator account to hold an active Premium subscription. | **Medium** | **Medium** | Explicitly document this prerequisite in `BUILD_AND_INSTALLATION.md`. | DevOps | **Documented & Mitigated** |
| **RISK-05** | Spotify Platform | **API Rate Limiting (HTTP 429)**: Rapid polling of player state triggers Spotify rate limits. | **Medium** | **Medium** | Implement an adaptive polling schedule: poll `/v1/me/player` every 2s while playing, back off to 10s when paused, and strictly observe the `Retry-After` header. | Backend | **Documented & Mitigated** |
| **RISK-06** | iOS Subsystem | **WebKit Background JavaScript Suspension**: iOS terminates WebKit background processes within 30 seconds. | **Critical** | **100% (if using WebKit)** | **Strict Architecture Decision**: Do not rely on `WKWebView` for audio. Use native `AVAudioSession` + `AVPlayer` for native media, and Spotify Connect for remote Spotify playback. | iOS Core | **Resolved by Architecture** |
| **RISK-07** | iOS Subsystem | **Inability to Stream Spotify Catalog Audio Directly via `AVPlayer`**: Spotify does not expose decrypted stream URLs for catalog tracks. | **Critical** | **100%** | Maintain strict separation: `AVPlayer` is reserved exclusively for authorized podcast passthrough feeds, local files, and 30s previews. Full tracks are routed via Connect. | Audio | **Resolved by Architecture** |
| **RISK-08** | iOS Subsystem | **App Remote Socket Disconnection in Background**: The Spotify iOS App Remote SDK terminates its local IPC connection after ~30s of background idle. | **Medium** | **High** | When app returns to foreground, execute a silent re-handshake to restore the connection. Use Web API Connect as the primary remote control mechanism. | Audio | **Documented & Mitigated** |
| **RISK-09** | Security & Auth | **OAuth Token Expiration & Revocation**: Access tokens expire after 60 minutes. | **Medium** | **100% (Hourly)** | Securely store refresh token in Apple Keychain. Implement an automatic interceptor in `SpotifyWebAPIClient` that refreshes the token on HTTP 401 before retrying the request. | Security | **Documented & Mitigated** |
| **RISK-10** | Build & Tooling | **Free Apple Account 7-Day Provisioning Expiration**: Free personal developer certificates expire weekly. | **Medium** | **100% (Weekly)** | Recommend SideStore / AltStore for automated background Wi-Fi resigning, or Sideloadly for simple 1-click re-installation. | DevOps | **Documented & Mitigated** |
| **RISK-11** | Build & Tooling | **Windows 11 Lack of Local Xcode GUI**: Build errors must be diagnosed via Codemagic CI build logs. | **Medium** | **Medium** | Maintain clean, declarative project definitions using XcodeGen (`project.yml`). Validate Swift syntax before pushing code. | DevOps | **Documented & Mitigated** |
| **RISK-12** | Legal & Terms | **GPL-3.0 License & Platform Compliance**: Derivative works must remain open source and respect third-party terms. | **High** | **Low** | Strictly maintain GPL-3.0 attribution to [kota-zo/myspoti](https://github.com/kota-zo/myspoti). Prohibit ad-blocking, DRM circumvention, or closed-source redistribution. | Governance | **Compliant** |
| **RISK-13** | Spotify Platform | **February 2026 API Migrations (Search Limit 10, Playlist /items, Removed Endpoints)**: Spotify deprecated legacy batch routes, capped search at 10 items, and migrated playlist tracks to `/items`. | **High** | **100%** | Hardcode maximum search limit to 10 (`limit=10`). Target `/v1/playlists/{id}/items` and unified `/v1/me/library` exclusively. Exclude deprecated `/recommendations` and `/audio-features`. | Backend | **Documented & Mitigated** |

---

## 2. Risk Mitigation Protocols

### Protocol 1: Graceful Tier Degradation (Free Account Handling)
```swift
// Check subscription tier upon login
if userAccount.product != "premium" {
    // Notify user of remote playback constraints
    playbackCoordinator.setPlaybackMode(.freeTierRestricted)
}
```
* **UI Feedback**: Instead of failing silently with an opaque HTTP 403 error, the playback bar indicates *"Spotify Connect requires Premium"*, offering a single tap to open the Spotify app via Universal Link (`spotify:track:...`).

### Protocol 2: Secure Keychain Token Storage
* All credentials are saved with `kSecAttrAccessibleAfterFirstUnlock`.
* No tokens are written to `UserDefaults`, cache directories, or application logs.
* Logout explicitly purges the Keychain items using `SecItemDelete`.

### Protocol 3: Resilient Network Interception
* Every `SpotifyWebAPIClient` request is monitored:
  1. If HTTP 401 is received, the client pauses pending requests via an `actor`-based lock, fetches a fresh token using `refresh_token`, updates the Keychain, and replays the request.
  2. If HTTP 429 is received, the client reads `Retry-After` (seconds) and suspends the queue.

