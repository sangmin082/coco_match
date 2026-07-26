import Foundation
import GoogleMobileAds
import UIKit

/// AdMob 광고 관리.
/// - 보상형 ①: 실패 시 "광고 보고 이어하기" (트레이 1칸 비우기 + 15초)
/// - 보상형 ②: 부스터 전부 소진 시 "광고 보고 충전"
/// - 전면: 3레벨 클리어마다 1회
final class AdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    static let shared = AdManager()

    /// 디버그 빌드와 TestFlight 빌드에서는 구글 테스트 광고를 사용한다.
    /// 실제 광고 단위는 앱스토어 정식 릴리즈에서만 사용 (개발 중 실광고 노출은 계정 정지 사유).
    private static let useTestAds = AppEnvironment.isTestBuild

    private let continueAdUnitID = AdManager.useTestAds
        ? "ca-app-pub-3940256099942544/1712485313"
        : "ca-app-pub-1063542820867439/3020443798"
    private let boosterAdUnitID = AdManager.useTestAds
        ? "ca-app-pub-3940256099942544/1712485313"
        : "ca-app-pub-1063542820867439/6068324677"
    private let interstitialAdUnitID = AdManager.useTestAds
        ? "ca-app-pub-3940256099942544/4411468910"
        : "ca-app-pub-1063542820867439/5032509406"

    @Published var continueAdReady = false
    @Published var boosterAdReady = false

    private var continueAd: GADRewardedAd?
    private var boosterAd: GADRewardedAd?
    private var interstitialAd: GADInterstitialAd?
    private var levelsSinceInterstitial = 0
    private let interstitialInterval = 3

    private override init() {
        super.init()
    }

    func start() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loadAds()
    }

    // MARK: - Loading

    private func loadAds() {
        loadContinueAd()
        loadBoosterAd()
        loadInterstitialAd()
    }

    /// 아직 로드되지 않은 광고가 있으면 다시 로드한다 (레벨 진입 시 등)
    func reloadIfNeeded() {
        loadAds()
    }

    private func loadContinueAd() {
        guard continueAd == nil else { return }
        GADRewardedAd.load(withAdUnitID: continueAdUnitID, request: GADRequest()) { [weak self] ad, _ in
            guard let self else { return }
            ad?.fullScreenContentDelegate = self
            DispatchQueue.main.async {
                self.continueAd = ad
                self.continueAdReady = ad != nil
                if ad == nil { self.scheduleRetry { $0.loadContinueAd() } }
            }
        }
    }

    private func loadBoosterAd() {
        guard boosterAd == nil else { return }
        GADRewardedAd.load(withAdUnitID: boosterAdUnitID, request: GADRequest()) { [weak self] ad, _ in
            guard let self else { return }
            ad?.fullScreenContentDelegate = self
            DispatchQueue.main.async {
                self.boosterAd = ad
                self.boosterAdReady = ad != nil
                if ad == nil { self.scheduleRetry { $0.loadBoosterAd() } }
            }
        }
    }

    private func loadInterstitialAd() {
        guard interstitialAd == nil else { return }
        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest()) { [weak self] ad, _ in
            guard let self else { return }
            ad?.fullScreenContentDelegate = self
            DispatchQueue.main.async {
                self.interstitialAd = ad
                if ad == nil { self.scheduleRetry { $0.loadInterstitialAd() } }
            }
        }
    }

    /// 로드 실패 시 30초 뒤 재시도 (네트워크 일시 장애/no-fill 대응)
    private func scheduleRetry(_ retry: @escaping (AdManager) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self else { return }
            retry(self)
        }
    }

    // MARK: - Presenting

    /// 실패 시 이어하기 보상 광고
    func showContinueAd(onReward: @escaping () -> Void) {
        guard let ad = continueAd, let root = Self.rootViewController() else { return }
        continueAd = nil
        continueAdReady = false
        ad.present(fromRootViewController: root) {
            DispatchQueue.main.async { onReward() }
        }
    }

    /// 부스터 충전 보상 광고
    func showBoosterAd(onReward: @escaping () -> Void) {
        guard let ad = boosterAd, let root = Self.rootViewController() else { return }
        boosterAd = nil
        boosterAdReady = false
        ad.present(fromRootViewController: root) {
            DispatchQueue.main.async { onReward() }
        }
    }

    /// 레벨 클리어마다 호출 — interstitialInterval 레벨마다 전면 광고
    func registerLevelCompleted() {
        levelsSinceInterstitial += 1
        guard levelsSinceInterstitial >= interstitialInterval,
              let ad = interstitialAd,
              let root = Self.rootViewController() else { return }
        levelsSinceInterstitial = 0
        interstitialAd = nil
        ad.present(fromRootViewController: root)
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadAds()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        loadAds()
    }

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}
