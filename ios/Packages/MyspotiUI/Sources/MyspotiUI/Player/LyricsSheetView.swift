import SwiftUI
import MyspotiDomain

/// Synchronized lyrics viewer powered by LRCLIB.
public struct LyricsSheetView: View {
    public let lyrics: Lyrics?
    public let currentProgressMs: Int
    public let onSeekToTime: (Int) -> Void

    public init(
        lyrics: Lyrics?,
        currentProgressMs: Int,
        onSeekToTime: @escaping (Int) -> Void
    ) {
        self.lyrics = lyrics
        self.currentProgressMs = currentProgressMs
        self.onSeekToTime = onSeekToTime
    }

    public var body: some View {
        ZStack {
            Color.amoledBlack.ignoresSafeArea()

            if let lyrics = lyrics, !lyrics.lines.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            // LRCLIB Attribution Header
                            HStack {
                                Text("SYNCHRONIZED LYRICS")
                                    .font(.captionTimestamp)
                                    .foregroundColor(.textTertiary)
                                Spacer()
                                Text("Powered by LRCLIB")
                                    .font(.captionTimestamp)
                                    .foregroundColor(.accentGreen)
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                            ForEach(lyrics.lines) { line in
                                let isActive = isLineActive(line, in: lyrics.lines)

                                Text(line.content)
                                    .font(isActive ? .lyricsActive : .lyricsInactive)
                                    .foregroundColor(isActive ? .textPrimary : .textSecondary.opacity(0.35))
                                    .scaleEffect(isActive ? 1.05 : 1.0, anchor: .leading)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isActive)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onSeekToTime(line.startTimeMs)
                                    }
                                    .id(line.id)
                            }

                            Spacer(minLength: 80)
                        }
                        .padding(.horizontal, 24)
                    }
                    .onChange(of: currentProgressMs) { _, newTime in
                        if let activeLine = lyrics.lines.last(where: { $0.startTimeMs <= newTime }) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(activeLine.id, anchor: .center)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "music.mic")
                        .font(.system(size: 44))
                        .foregroundColor(.textTertiary)
                    Text("No Synchronized Lyrics Found")
                        .font(.sectionTitle)
                        .foregroundColor(.textSecondary)
                    Text("Lyrics are sourced independently from LRCLIB.")
                        .font(.captionTimestamp)
                        .foregroundColor(.textTertiary)
                }
                .padding()
            }
        }
    }

    private func isLineActive(_ line: LyricsLine, in allLines: [LyricsLine]) -> Bool {
        guard let index = allLines.firstIndex(where: { $0.id == line.id }) else { return false }
        let nextStartTime = (index + 1 < allLines.count) ? allLines[index + 1].startTimeMs : Int.max
        return currentProgressMs >= line.startTimeMs && currentProgressMs < nextStartTime
    }
}

