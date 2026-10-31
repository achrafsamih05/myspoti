import SwiftUI
import MyspotiDomain

/// Interactive view displaying currently playing track and upcoming queue.
public struct QueueView: View {
    public let queue: PlaybackQueue
    public let onRemoveItem: (String) -> Void
    public let onPlayTrack: (Track) -> Void

    @Environment(\.dismiss) private var dismiss

    public init(
        queue: PlaybackQueue,
        onRemoveItem: @escaping (String) -> Void,
        onPlayTrack: @escaping (Track) -> Void
    ) {
        self.queue = queue
        self.onRemoveItem = onRemoveItem
        self.onPlayTrack = onPlayTrack
    }

    public var body: some View {
        ZStack {
            Color.amoledBlack.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Play Queue")
                        .font(.sectionTitle)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.trackTitle)
                        .foregroundColor(.accentGreen)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Currently Playing
                        if let current = queue.currentTrack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("NOW PLAYING")
                                    .font(.captionTimestamp)
                                    .foregroundColor(.accentGreen)

                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: current.album?.coverUrl ?? "")) { phase in
                                        if case .success(let image) = phase {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.surfaceHover
                                        }
                                    }
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(current.name)
                                            .font(.trackTitle)
                                            .foregroundColor(.textPrimary)
                                            .lineLimit(1)
                                        Text(current.artistNamesSummary)
                                            .font(.trackArtist)
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: "waveform")
                                        .foregroundColor(.accentGreen)
                                }
                                .padding(12)
                                .background(Color.surfaceCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }

                        // Upcoming in Queue
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NEXT IN QUEUE (\(queue.upcomingTracks.count))")
                                .font(.captionTimestamp)
                                .foregroundColor(.textTertiary)

                            if queue.upcomingTracks.isEmpty {
                                Text("No upcoming tracks. Queue songs from search, albums, or playlists.")
                                    .font(.trackArtist)
                                    .foregroundColor(.textSecondary)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(queue.upcomingTracks) { track in
                                    HStack(spacing: 12) {
                                        Button(action: { onPlayTrack(track) }) {
                                            HStack(spacing: 12) {
                                                AsyncImage(url: URL(string: track.album?.coverUrl ?? "")) { phase in
                                                    if case .success(let image) = phase {
                                                        image.resizable().aspectRatio(contentMode: .fill)
                                                    } else {
                                                        Color.surfaceHover
                                                    }
                                                }
                                                .frame(width: 44, height: 44)
                                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(track.name)
                                                        .font(.trackTitle)
                                                        .foregroundColor(.textPrimary)
                                                        .lineLimit(1)
                                                    Text(track.artistNamesSummary)
                                                        .font(.captionTimestamp)
                                                        .foregroundColor(.textSecondary)
                                                        .lineLimit(1)
                                                }

                                                Spacer()
                                            }
                                        }
                                        .buttonStyle(.plain)

                                        Button(action: { onRemoveItem(track.id) }) {
                                            Image(systemName: "minus.circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(.textTertiary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

