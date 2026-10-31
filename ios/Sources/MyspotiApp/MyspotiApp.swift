import SwiftUI
import MyspotiDomain
import MyspotiUI

@main
struct MyspotiApp: App {
    @StateObject private var container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootNavigationView(
                catalogRepository: container.catalogRepository,
                libraryRepository: container.libraryRepository,
                playbackRepository: container.playbackRepository,
                lyricsRepository: container.lyricsRepository
            )
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                // Handle OAuth PKCE callback (myspoti://callback?code=...)
                if url.scheme == "myspoti" && url.host == "callback" {
                    // Handled by PKCE authentication flow
                }
            }
        }
    }
}

