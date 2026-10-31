# Myspoti iOS – Design System & UI/UX Architecture

> **Attribution**: The visual styling of Myspoti iOS draws inspiration from Spotui, Metrolist, and BitChord (GPL-3.0), refined specifically for native iOS 17+ and the iPhone hardware aesthetic.

---

## 1. Design Philosophy

Myspoti iOS is built around five core principles:
1. **Pure True Black (AMOLED)**: Designed for OLED displays. Backgrounds are pitch black (`#000000`), minimizing battery consumption and offering contrast that makes vibrant album art stand out.
2. **Glassmorphic Depth**: Subtle frosted glass (`.ultraThinMaterial`), delicate borders, and dynamic multi-color glow derived from album artwork.
3. **Fluid Interactive Motion**: Physics-based springs, interactive gesture dismissals, and seamless matched-geometry transitions between the mini-player and the full-screen Now Playing screen.
4. **Native iOS Navigation & Ergonomics**: Adherence to Apple's Human Interface Guidelines (HIG), thumb-zone optimization, Dynamic Island awareness, and tactile haptic feedback.
5. **Distinctive Identity**: Avoids generic dashboards; presents music with high-editorial typography, custom vinyl discs, and synchronized typography.

---

## 2. Color Palette & Design Tokens

```
                               PITCH BLACK (AMOLED)
                                    #000000
                                       │
            ┌──────────────────────────┼──────────────────────────┐
            ▼                          ▼                          ▼
     ELEVATED SURFACE             CARD SURFACE             ACCENT VIBRANT
         #121212                    #181818                    #1DB954
```

### 2.1 Color Tokens

| Token Name | Hex Value | SwiftUI Definition | Usage |
| :--- | :--- | :--- | :--- |
| `backgroundPrimary` | `#000000` | `Color.black` | Primary window and screen background |
| `backgroundElevated` | `#121212` | `Color(hex: "121212")` | Navigation bars, sheet backdrops, and bottom bar |
| `surfaceCard` | `#181818` | `Color(hex: "181818")` | Media cards, shelf tiles, and list items |
| `surfaceHover` | `#282828` | `Color(hex: "282828")` | Active selection, pressed states, and dividers |
| `accentGreen` | `#1DB954` | `Color(hex: "1DB954")` | Primary buttons, active playback indicators, toggles |
| `textPrimary` | `#FFFFFF` | `Color.white` | Track titles, headers, prominent labels |
| `textSecondary` | `#B3B3B3` | `Color(hex: "B3B3B3")` | Artist names, album subtitles, timestamps |
| `textTertiary` | `#727272` | `Color(hex: "727272")` | Metadata, durations, copyright notices |
| `error` | `#E91429` | `Color(hex: "E91429")` | Error states and warnings |

### 2.2 Dynamic Album Artwork Glow
To create an immersive visual atmosphere, the player extracts dominant colors from the current album cover:
* A gaussian-blurred background mesh (`blur(radius: 60)`) creates ambient glow behind the player controls.
* In Dark AMOLED mode, the mesh opacity is clamped to 25%–35% over `#000000` to preserve deep black levels while bathing the UI in subtle color.

---

## 3. Typography Hierarchy

Myspoti iOS pairs Apple's native **SF Pro Rounded** for numeric/media controls with **Manrope** (SIL Open Font License) for editorial headers.

| Style Role | Font Family | Size | Weight | Line Spacing | Tracking |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Large Display** | Manrope / SF Pro | 34 pt | Bold | 41 pt | -0.5 pt |
| **Section Header** | Manrope / SF Pro | 22 pt | Bold | 28 pt | -0.3 pt |
| **Track Title (Player)**| SF Pro Rounded | 20 pt | Semibold | 24 pt | -0.2 pt |
| **Artist / Subtitle** | SF Pro | 16 pt | Medium | 21 pt | 0 pt |
| **Body Text** | SF Pro | 15 pt | Regular | 20 pt | 0 pt |
| **Lyrics Line (Active)**| Manrope / SF Pro | 24 pt | Heavy | 32 pt | -0.4 pt |
| **Lyrics Line (Inactive)**| Manrope / SF Pro | 20 pt | Bold | 28 pt | -0.2 pt |
| **Timestamp / Caption** | SF Pro Rounded | 12 pt | Medium | 16 pt | +0.2 pt |

---

## 4. Key Interactive Components

### 4.1 Custom Interactive Mini-Player
The mini-player floats above the bottom tab bar:
* **Dimensions**: 64 pt height, pill/capsule corners (16 pt corner radius), inset 8 pt from screen edges.
* **Surface**: Translucent dark acrylic (`.ultraThinMaterial`) with a subtle 0.5 pt border (`Color.white.opacity(0.12)`).
* **Components**:
  * 48 pt rounded album artwork with shadow.
  * Scrolling marquee for long track titles and artist names.
  * Tactile Play/Pause button with spring animation.
  * Swipe Gestures: Swipe left for next track; swipe right for previous track; swipe up or tap to expand full Now Playing.
  * Integrated Progress Bar: A 2 pt progress accent line anchored to the bottom of the pill.

### 4.2 Full-Screen Now Playing Interface
A full-height modal sheet featuring:
* **Header**: Interactive chevron dismiss button, context name (e.g., "Playing from Playlist"), and overflow menu.
* **Hero Artwork**:
  * Large square album art with continuous rounded corners (20 pt radius) and elevated drop shadow.
  * Interactive scrub bar with live time indicators and tactile haptic ticks (`UIImpactFeedbackGenerator`).
* **Control Row**:
  * Shuffle toggle, Previous, large Play/Pause circle (64 pt), Next, and Repeat toggle.
* **Bottom Action Dock**:
  * Heart / Liked button with bursting particle animation.
  * Device selector pill (showing active Spotify Connect device).
  * Lyrics sheet pull-tab.
  * Draggable Queue button.

### 4.3 Synchronized Lyrics Sheet
* **Display Modes**: Word-by-word synced karaoke mode (with syllable-level lighting) or line-by-line smooth auto-scrolling.
* **Typography**: Inactive lines sit at 40% opacity in soft gray; the active singing line expands dynamically to heavy white with a soft glowing halo.
* **Interactivity**: Tapping any lyric line seeks playback directly to that timestamp.

### 4.4 Modern Draggable Queue
* Categorized into three distinct sections:
  1. **Currently Playing**: Highlighted card with equalizer animation.
  2. **Next Up (User Queued)**: Draggable rows with `.onMove` reordering and swipe-to-delete.
  3. **Playing Next From Context**: Playlist or album continuation rows.

---

## 5. Responsive Layouts & iPhone Sizing

The UI is built with adaptive SwiftUI constraints:
* **Dynamic Island & Notch**: Safe area top insets adapt automatically to avoid clipping.
* **Home Indicator**: Floating docks and mini-players sit 8 pt above the home indicator safe area.
* **Compact Devices (iPhone SE / mini)**: Artwork scales smoothly from 320 pt to 240 pt, preserving full visibility of controls without vertical scrolling.
* **Pro Max Devices**: Expands padding to generous 24 pt gutters for optimal one-handed thumb reach.

