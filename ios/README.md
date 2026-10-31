# Myspoti iOS – Enhanced Edition

A native, high-performance iOS music client derived from [Myspoti](https://github.com/kota-zo/myspoti) by kota-zo.  
Licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

---

## Project Overview

Myspoti iOS is engineered for personal deployment on modern Apple devices (iPhone running iOS 17+). Developed on Windows 11 and compiled on cloud-based macOS build automation (Codemagic), the application provides a native, dark AMOLED music experience with synchronized lyrics, full Spotify catalog browsing, and Apple media subsystem integration (`AVAudioSession`, `MPNowPlayingInfoCenter`, and `MPRemoteCommandCenter`).

---

## Architecture & Engineering Documentation

The architecture audit has been completed. Detailed engineering specifications are available in the `docs/` directory:

1. [**System Architecture & Audit**](docs/ARCHITECTURE.md): Comprehensive module analysis of the original Android repository, platform gap analysis, Kotlin Multiplatform vs. native Swift evaluation, and modular package architecture.
2. [**Feature Matrix & Feasibility**](docs/FEATURE_MATRIX.md): Detailed capability matrix comparing Android and iOS features, platform feasibility, constraints, and target release versions.
3. [**Technical Roadmap & Milestones**](docs/TECHNICAL_ROADMAP.md): Phased roadmap from architecture audit through MVP and subsequent releases, including story point estimates and risk registers.
4. [**Spotify Integration Guide**](docs/SPOTIFY_INTEGRATION.md): Deep technical breakdown of official Spotify OAuth PKCE, Web API REST endpoints, Connect remote control, account tier requirements, and audio architecture.
5. [**iOS Design System**](docs/IOS_DESIGN_SYSTEM.md): AMOLED dark theme tokens, glassmorphism, dynamic artwork glow, typography hierarchy, custom mini-player, full-screen Now Playing, and responsive iPhone sizing.
6. [**Build & Installation Guide**](docs/BUILD_AND_INSTALLATION.md): Guide for compiling on cloud macOS (Codemagic CI via XcodeGen) and sideloading onto a personal iPhone using a free Apple Account via Sideloadly, AltStore, or SideStore.
7. [**Integration Risk Register**](docs/INTEGRATION_RISK_REGISTER.md): Granular tracking of Spotify platform constraints (Premium requirements for Connect, Dev Mode user allowlists), iOS background limits, and mitigation protocols.

---

## Structure of the iOS Project

```
ios/
├── docs/                   # Engineering specifications and architecture documentation
│   ├── ARCHITECTURE.md
│   ├── FEATURE_MATRIX.md
│   ├── TECHNICAL_ROADMAP.md
│   ├── SPOTIFY_INTEGRATION.md
│   ├── IOS_DESIGN_SYSTEM.md
│   ├── BUILD_AND_INSTALLATION.md
│   └── INTEGRATION_RISK_REGISTER.md
├── project.yml             # XcodeGen project specification
├── codemagic.yaml          # Cloud CI build definition for macOS
├── Packages/               # Modular Swift Package Manager targets
│   ├── MyspotiDomain/      # Pure domain models and protocols (1:1 with :api)
│   ├── MyspotiSpotify/     # Direct GraphQL & Spotify session client
│   ├── MyspotiAudio/       # AVAudioSession, AVPlayer, and Connect coordinator
│   └── MyspotiUI/          # AMOLED SwiftUI views and design components
└── Sources/
    └── MyspotiApp/         # Application entry point, Info.plist, and entitlements
```

---

## Licensing & Credit

This project is free software licensed under **GPL-3.0**.  
Original project: [https://github.com/kota-zo/myspoti](https://github.com/kota-zo/myspoti)  
Copyright (C) 2024-2026 kota-zo and Myspoti contributors.  
See `LICENSE` in the repository root for complete terms.

