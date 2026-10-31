import Foundation
import MyspotiDomain
import MyspotiNetwork
import MyspotiAudio
import MyspotiUI

/// Central composition root wiring dependencies for standalone / free-tier execution and preview environments.
@MainActor
public final class AppDependencyContainer: ObservableObject {
    public let catalogRepository: CatalogRepositoryProtocol
    public let libraryRepository: LibraryRepositoryProtocol
    public let playbackRepository: PlaybackRepositoryProtocol
    public let lyricsRepository: LyricsRepositoryProtocol
    public let keychainStore: KeychainTokenStore
    public let pkceCoordinator: PKCECoordinator

    public init(
        catalogRepository: CatalogRepositoryProtocol? = nil,
        libraryRepository: LibraryRepositoryProtocol? = nil,
        playbackRepository: PlaybackRepositoryProtocol? = nil,
        lyricsRepository: LyricsRepositoryProtocol? = nil,
        clientId: String = "d8a5de950d384ed7945d5cc3486d8a49"
    ) {
        let keychain = KeychainTokenStore()
        self.keychainStore = keychain
        self.pkceCoordinator = PKCECoordinator(clientId: clientId)

        // Free Account Strategy: Initialize with NativeAudioEngine backed by AVPlayer
        let nativeAudio = NativePlaybackRepository()

        // Repositories default to rich standalone mock datasets to allow immediate functionality
        // without requiring Spotify login or Spotify Premium subscriptions.
        self.catalogRepository = catalogRepository ?? MockCatalogRepository()
        self.libraryRepository = libraryRepository ?? MockLibraryRepository()
        self.playbackRepository = playbackRepository ?? nativeAudio
        self.lyricsRepository = lyricsRepository ?? MockLyricsRepository()
    }
}
