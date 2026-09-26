import SwiftUI

@main
struct WatchKitDemoApp: App {
    @StateObject private var sessionStore = WatchSessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .onAppear { sessionStore.activate() }
        }
    }
}
