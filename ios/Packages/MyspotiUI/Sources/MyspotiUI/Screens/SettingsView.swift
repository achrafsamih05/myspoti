import SwiftUI

/// Settings view providing integration status indicators, audio configuration, and GPL-3.0 attribution.
public struct SettingsView: View {
    @State private var audioQuality: String = "High (320 kbps)"
    @State private var enableCrossfade: Bool = false
    @State private var crossfadeDuration: Double = 3.0
    @State private var cacheCleared: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.amoledBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        Text("Settings")
                            .font(.displayLarge)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        // 1. Integration Status Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("INTEGRATION STATUS")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Operating Mode")
                                        .font(.trackTitle)
                                        .foregroundColor(.textPrimary)
                                    Text("Standalone Native Audio & Mock Engine")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                HStack(spacing: 6) {
                                    Circle().fill(Color.accentGreen).frame(width: 8, height: 8)
                                    Text("Active")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.accentGreen)
                                }
                            }

                            Divider().background(Color.surfaceHover)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Spotify Premium Requirement")
                                        .font(.trackTitle)
                                        .foregroundColor(.textPrimary)
                                    Text("Bypassed / Not Required")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                                Text("Free Tier Safe")
                                    .font(.captionTimestamp)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                        .padding(16)
                        .background(Color.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 20)

                        // 2. Audio Playback Settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("AUDIO ENGINE")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            HStack {
                                Text("Streaming Engine")
                                    .font(.trackTitle)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text("AVPlayer + AVAudioSession")
                                    .font(.captionTimestamp)
                                    .foregroundColor(.textSecondary)
                            }

                            Divider().background(Color.surfaceHover)

                            Toggle(isOn: $enableCrossfade) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Crossfade Tracks")
                                        .font(.trackTitle)
                                        .foregroundColor(.textPrimary)
                                    Text("Smooth transition between songs")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .tint(.accentGreen)

                            if enableCrossfade {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Duration: \(Int(crossfadeDuration))s")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textTertiary)
                                    Slider(value: $crossfadeDuration, in: 1...10, step: 1)
                                        .tint(.accentGreen)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 20)

                        // 3. Storage & Cache
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STORAGE & CACHE")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            Button(action: {
                                URLCache.shared.removeAllCachedResponses()
                                cacheCleared = true
                            }) {
                                HStack {
                                    Text(cacheCleared ? "Cache Cleared!" : "Clear Image & Lyrics Cache")
                                        .font(.trackTitle)
                                        .foregroundColor(cacheCleared ? .accentGreen : .textPrimary)
                                    Spacer()
                                    Image(systemName: "trash")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(Color.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 20)

                        // 4. Open-Source Legal & Attribution
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CREDITS & ATTRIBUTION")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            Text("Myspoti iOS is licensed under GNU General Public License v3.0 (GPL-3.0).")
                                .font(.captionTimestamp)
                                .foregroundColor(.textSecondary)

                            Text("Origin project: kota-zo/myspoti (https://github.com/kota-zo/myspoti)")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 20)

                        Spacer(minLength: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

