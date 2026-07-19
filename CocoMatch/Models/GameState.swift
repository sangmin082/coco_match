import SwiftUI
import Combine
import UIKit

enum GamePhase: Equatable {
    case playing
    case paused
    case won
    case lost
}

/// 한 판(레벨)의 진행 상태. 트레이·매치·타이머·부스터 횟수를 관리한다.
final class GameState: ObservableObject {
    let level: LevelData
    let trayCapacity = 7

    @Published var phase: GamePhase = .playing
    @Published var tray: [ItemType] = []
    @Published var matchedCount = 0
    @Published var score = 0
    @Published var timeRemaining: Int
    @Published var shuffleLeft = 3
    @Published var magnetLeft = 2
    @Published var timeBoostLeft = 1

    private var timerCancellable: AnyCancellable?

    init(level: LevelData) {
        self.level = level
        self.timeRemaining = level.timeLimit
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.phase == .playing else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.timeRemaining = 0
                    self.finish(won: false)
                }
            }
    }

    /// 보드에서 아이템 하나를 트레이로 가져온다. 3개가 모이면 즉시 매치.
    func collect(_ type: ItemType) {
        guard phase == .playing else { return }
        withAnimation(.spring(duration: 0.25)) {
            tray.append(type)
            tray.sort { $0.rawValue < $1.rawValue }
        }
        if tray.filter({ $0 == type }).count >= 3 {
            score += 30
            matchedCount += 3
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(duration: 0.35)) {
                tray.removeAll { $0 == type }
            }
            if matchedCount >= level.totalItems {
                score += timeRemaining * 5
                finish(won: true)
            }
        } else if tray.count >= trayCapacity {
            finish(won: false)
        }
    }

    func useTimeBoost() {
        guard phase == .playing, timeBoostLeft > 0 else { return }
        timeBoostLeft -= 1
        timeRemaining += 30
    }

    func togglePause() {
        if phase == .playing { phase = .paused }
        else if phase == .paused { phase = .playing }
    }

    private func finish(won: Bool) {
        phase = won ? .won : .lost
        timerCancellable?.cancel()
        if !won {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
