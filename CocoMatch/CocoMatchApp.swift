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
                // 게임은 자체 색으로 그려지므로 다크 모드에서 텍스트가
                // 사라지지 않도록 항상 라이트 모드로 고정한다
                .preferredColorScheme(.light)
        }
    }
}
