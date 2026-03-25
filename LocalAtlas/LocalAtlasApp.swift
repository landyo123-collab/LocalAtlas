import SwiftUI

@main
struct LocalAtlasApp: App {
    @StateObject private var tabManager = TabManager()
    @StateObject private var settings = AtlasSettings()
    @StateObject private var serverManager = LocalServerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabManager)
                .environmentObject(settings)
                .environmentObject(serverManager)
        }
    }
}
