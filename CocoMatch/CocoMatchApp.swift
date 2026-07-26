import SwiftUI

@main
struct CocoMatchApp: App {
    init() {
        AdManager.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBarHidden()
                .persistentSystemOverlays(.hidden)
        }
    }
}
