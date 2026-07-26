import SwiftUI
import SceneKit

/// SceneKit 뷰를 SwiftUI에 올리는 컨테이너
struct SceneKitContainer: UIViewRepresentable {
    let controller: GameController

    func makeUIView(context: Context) -> SCNView {
        controller.scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

/// 게임 플레이 화면: 3D 통 + HUD + 부스터 + 트레이 + 결과 오버레이
struct GameView: View {
    let levelNumber: Int
    let onExit: () -> Void
    let onNext: () -> Void
    let onRetry: () -> Void

    @StateObject private var gameState: GameState
    @ObservedObject private var ads = AdManager.shared
    @State private var controller: GameController?
    @AppStorage("unlockedLevel") private var unlockedLevel = 1

    init(levelNumber: Int,
         onExit: @escaping () -> Void,
         onNext: @escaping () -> Void,
         onRetry: @escaping () -> Void) {
        self.levelNumber = levelNumber
        self.onExit = onExit
        self.onNext = onNext
        self.onRetry = onRetry
        _gameState = StateObject(wrappedValue: GameState(level: LevelData.level(levelNumber)))
    }

    var body: some View {
        ZStack {
            Color(red: 0.55, green: 0.83, blue: 0.93).ignoresSafeArea()

            if let controller {
                SceneKitContainer(controller: controller)
                    .ignoresSafeArea()
            }

            VStack(spacing: 10) {
                hud
                Spacer()
                boosterRow
                TrayView(gameState: gameState)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            resultOverlay
        }
        .onAppear {
            if controller == nil {
                controller = GameController(gameState: gameState)
            }
            AdManager.shared.reloadIfNeeded()
        }
        .onChange(of: gameState.phase) { _, phase in
            controller?.setPaused(phase != .playing)
            if phase == .won {
                unlockedLevel = max(unlockedLevel, levelNumber + 1)
            }
        }
        .onDisappear {
            controller?.stop()
        }
    }

    // MARK: - HUD

    private var hud: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    gameState.togglePause()
                } label: {
                    Image(systemName: gameState.phase == .paused ? "play.fill" : "pause.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.black.opacity(0.25), in: Circle())
                }

                Spacer()

                Text("레벨 \(levelNumber)")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .shadow(radius: 2)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                    Text(timeString)
                        .monospacedDigit()
                }
                .font(.headline)
                .foregroundStyle(gameState.timeRemaining <= 15 ? .red : .white)
                .frame(width: 86, height: 40)
                .background(.black.opacity(0.25), in: Capsule())
            }

            ProgressView(value: Double(gameState.matchedCount),
                         total: Double(gameState.level.totalItems))
                .tint(.yellow)
                .background(.white.opacity(0.4), in: Capsule())
                .scaleEffect(y: 2)

            HStack {
                Text("🎯 \(gameState.matchedCount)/\(gameState.level.totalItems)")
                Spacer()
                Text("⭐ \(gameState.score)")
                    .monospacedDigit()
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .shadow(radius: 1)
        }
    }

    private var timeString: String {
        String(format: "%d:%02d", gameState.timeRemaining / 60, gameState.timeRemaining % 60)
    }

    // MARK: - Boosters

    private var boosterRow: some View {
        HStack(spacing: 14) {
            BoosterButton(emoji: "🌪", title: "셔플", count: gameState.shuffleLeft) {
                controller?.useShuffle()
            }
            BoosterButton(emoji: "🧲", title: "자석", count: gameState.magnetLeft) {
                controller?.useMagnet()
            }
            BoosterButton(emoji: "⏰", title: "+30초", count: gameState.timeBoostLeft) {
                gameState.useTimeBoost()
            }
            // 부스터를 모두 쓰면 광고 보고 충전
            if gameState.shuffleLeft == 0, gameState.magnetLeft == 0,
               gameState.timeBoostLeft == 0, ads.boosterAdReady {
                Button {
                    AdManager.shared.showBoosterAd { [weak gameState] in
                        gameState?.refillBoosters()
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text("📺").font(.system(size: 26))
                        Text("충전").font(.caption2.bold())
                    }
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 58)
                    .background(.green.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Result overlays

    @ViewBuilder
    private var resultOverlay: some View {
        switch gameState.phase {
        case .won:
            ResultOverlay(
                title: "레벨 클리어! 🎉",
                subtitle: "점수 \(gameState.score)점",
                primary: ("다음 레벨", {
                    AdManager.shared.registerLevelCompleted()
                    onNext()
                }),
                secondary: ("메뉴로", onExit)
            )
        case .lost:
            ResultOverlay(
                title: gameState.timeRemaining == 0 ? "시간 초과 ⏰" : "트레이가 가득 찼어요 😵",
                subtitle: "다시 도전해 보세요!",
                primary: ("재도전", onRetry),
                secondary: ("메뉴로", onExit),
                extra: (ads.continueAdReady && !gameState.usedRevive)
                    ? ("📺 광고 보고 이어하기", { [weak gameState] in
                        AdManager.shared.showContinueAd {
                            gameState?.reviveWithAd()
                        }
                    })
                    : nil
            )
        case .paused:
            ResultOverlay(
                title: "일시정지",
                subtitle: "레벨 \(levelNumber)",
                primary: ("계속하기", { gameState.togglePause() }),
                secondary: ("그만두기", onExit)
            )
        case .playing:
            EmptyView()
        }
    }
}
