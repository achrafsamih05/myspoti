import SwiftUI
import MyspotiDomain

/// User Profile and Settings view displaying tier status and legal attribution.
public struct ProfileView: View {
    public let user: UserProfile?
    public let onSignOut: () -> Void

    public init(user: UserProfile?, onSignOut: @escaping () -> Void) {
        self.user = user
        self.onSignOut = onSignOut
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.amoledBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // User Avatar & Name
                        VStack(spacing: 12) {
                            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    Circle()
                                        .fill(Color.surfaceCard)
                                        .overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.textTertiary))
                                }
                            }
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))

                            Text(user?.displayName ?? "Myspoti User")
                                .font(.sectionTitle)
                                .foregroundColor(.textPrimary)

                            if let email = user?.email {
                                Text(email)
                                    .font(.trackArtist)
                                    .foregroundColor(.textSecondary)
                            }

                            // Subscription Tier Badge
                            HStack(spacing: 6) {
                                Circle()
                                    .fill((user?.isPremium ?? false) ? Color.accentGreen : Color.orange)
                                    .frame(width: 8, height: 8)

                                Text((user?.isPremium ?? false) ? "SPOTIFY PREMIUM" : "SPOTIFY FREE")
                                    .font(.captionTimestamp)
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.surfaceCard)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 24)

                        // Tier Capabilities Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TIER CAPABILITIES (2026)")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Catalog Search (max 10)")
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.accentGreen)
                            }
                            .font(.trackArtist)
                            .foregroundColor(.textPrimary)

                            HStack {
                                Image(systemName: "music.mic")
                                Text("Synchronized Lyrics (LRCLIB)")
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.accentGreen)
                            }
                            .font(.trackArtist)
                            .foregroundColor(.textPrimary)

                            HStack {
                                Image(systemName: "airplayaudio")
                                Text("Spotify Connect Remote Control")
                                Spacer()
                                if user?.isPremium ?? false {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.accentGreen)
                                } else {
                                    Text("Premium Required")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.orange)
                                }
                            }
                            .font(.trackArtist)
                            .foregroundColor(.textPrimary)
                        }
                        .padding(16)
                        .background(Color.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 20)

                        // Open-Source License & Legal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ABOUT & LEGAL")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            Text("Myspoti iOS is an open-source personal music client licensed under GNU General Public License v3.0 (GPL-3.0).")
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

                        // Sign Out Button
                        Button(action: onSignOut) {
                            Text("Sign Out")
                                .font(.trackTitle)
                                .foregroundColor(.errorRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

