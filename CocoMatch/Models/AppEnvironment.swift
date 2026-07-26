import Foundation

/// 빌드 환경 판별.
/// 디버그 빌드와 TestFlight(샌드박스 영수증)에서는 테스트 기능·테스트 광고를 노출하고,
/// 앱스토어 정식 빌드에서는 숨긴다.
enum AppEnvironment {
    static let isTestBuild: Bool = {
        #if DEBUG
        return true
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }()
}
