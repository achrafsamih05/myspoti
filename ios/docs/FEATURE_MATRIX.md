# Myspoti iOS – Feature Matrix & Feasibility (2026 Verified)

> **Notice**: Derived from [Myspoti](https://github.com/kota-zo/myspoti) (GPL-3.0).  
> Validated against the **February 2026 Spotify Developer Platform changes** and Apple iOS platform guidelines.

---

## 1. Feature Feasibility & Specification Matrix

| Feature | Implementation Method | Required API / Source | Account Tier Requirement | Platform & API Limitations (2026) | Free Personal Install Feasible? | Target Phase |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **OAuth 2.0 PKCE Login** | `ASWebAuthenticationSession` with SHA-256 challenge | Spotify Accounts (`/authorize`, `/api/token`) | Free or Premium (Dev app owner requires Premium) | Custom URL scheme (`myspoti://callback`); max 5 allowlisted users in Dev Mode | ✅ **Yes** | **Phase 1 (MVP)** |
| **Catalog Search** | Single-item query execution via Web API | Spotify Web API `GET /v1/search` | Free or Premium | **Capped at max 10 items** (`limit=10`); batch catalog routes removed | ✅ **Yes** | **Phase 1 (MVP)** |
| **Album & Artist Details** | Individual REST lookups (`/v1/albums/{id}`, `/v1/artists/{id}`) | Spotify Web API | Free or Premium | Legacy batch routes (`/albums`, `/artists`) removed; `popularity` stripped | ✅ **Yes** | **Phase 1 (MVP)** |
| **User Library (Saved Items)**| Unified library API (`/v1/me/library`) | Spotify Web API `PUT/DELETE /v1/me/library`, `GET /v1/me/library/contains` | Free or Premium | Replaces deprecated `/me/tracks` & `/me/albums` | ✅ **Yes** | **Phase 1 (MVP)** |
| **User Playlists** | Read and display user's owned and followed playlists | Spotify Web API `GET /v1/me/playlists` | Free or Premium | Primarily restricted to user-owned and collaborative playlists | ✅ **Yes** | **Phase 1 (MVP)** |
| **Playlist Item Management**| Fetch, add, and remove playlist rows | Spotify Web API `GET/POST/DELETE /v1/playlists/{id}/items` | Free or Premium (Owner / Collab) | **Migrated from `/tracks` to `/items`** | ✅ **Yes** | **Phase 1 (MVP)** |
| **Spotify Remote Playback** | Control playback on official Spotify application | Spotify Connect API / App Remote SDK | **STRICTLY PREMIUM** | Returns `403 Forbidden` (`PREMIUM_REQUIRED`) on Free accounts; requires active device | ❌ **Requires Spotify Premium** | **Phase 1 (MVP)** |
| **Playback Monitoring** | Periodic polling of active track and device state | Spotify Web API `GET /v1/me/player` | Free or Premium | Polling interval throttled (2s active, 10s idle) to avoid 429 rate limits | ✅ **Yes (when music is active)** | **Phase 1 (MVP)** |
| **Direct Spotify Track Streaming** | *Excluded (Unsupported)* | *None* | *N/A* | Spotify does not expose clear audio streams; DRM circumvention is strictly prohibited | ❌ **No (Unsupported)** | **Excluded** |
| **Native Podcast Streaming** | Streaming publisher audio files | Authorized Publisher RSS feeds / direct MP3/M4A | Free or Premium | Spotify metadata does not contain raw audio; requires publisher RSS enclosure | ✅ **Yes** | **Phase 2** |
| **Native Track Previews** | 30-second audio preview playback | Native `AVPlayer` (`preview_url`) | Free or Premium | Subject to label availability (`preview_url` may be null) | ✅ **Yes** | **Phase 1 (MVP)** |
| **System Media Controls** | `MPNowPlayingInfoCenter` + `MPRemoteCommandCenter` | Apple MediaPlayer framework | Free or Premium | **Active ONLY for native AVPlayer playback**; official Spotify app owns session during Connect | ✅ **Yes (Native audio only)** | **Phase 1 (MVP)** |
| **Synchronized Lyrics** | Syllable & line-synced lyrics | [LRCLIB](https://lrclib.net) Public REST API | Free or Premium | Independent community database; attribution required; no private Spotify endpoints | ✅ **Yes** | **Phase 2** |
| **Ad-Free Free Playback** | *Excluded (Unsupported)* | *None* | *N/A* | Ad-blocking and state-machine tampering are strictly excluded per platform terms | ❌ **No (Policy Excluded)** | **Excluded** |
| **Offline Music Downloads** | *Excluded (Unsupported)* | *None* | *N/A* | Spotify catalog downloading without DRM is unauthorized | ❌ **No (Policy Excluded)** | **Excluded** |

---

## 2. Key Constraints for Personal Installation (2026)

1. **Spotify Development Mode Constraints**:
   * App owner **must have Spotify Premium**.
   * Only **1 Client ID** per developer.
   * Maximum **5 authorized users** on the allowlist.
2. **Playback Realities**:
   * **Free Accounts**: Can search (up to 10 results), browse library, view playlists, and read lyrics. Attempting to trigger remote Spotify playback receives `403 Forbidden (PREMIUM_REQUIRED)`.
   * **Premium Accounts**: Enjoy full remote control through Spotify Connect / App Remote.
3. **Audio Ownership**:
   * Spotify App Remote is a remote controller for the official Spotify app. The official Spotify app owns the iOS system media session when active. Myspoti manages system media controls (`MPNowPlayingInfoCenter`) exclusively when playing native audio in `AVPlayer`.
