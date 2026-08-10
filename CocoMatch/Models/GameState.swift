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
    /// 빼두기 버퍼: 트레이 위 선반. 같은 종류가 모여 3개가 완성되면 자동으로 돌아와 매치된다.
    @Published var buffer: [ItemType] = []
    @Published var matchedCount = 0
    @Published var score = 0
    @Published var timeRemaining: Int
    @Published var holdLeft = 2
    @Published var magnetLeft = 2
    @Published var timeBoostLeft = 1
    @Published var usedRevive = false

    /// 트레이에 들어가지 못한 아이템을 보드로 되돌릴 때 호출 (총량 보존 — 아이템 증발 방지)
    var onItemReturnedToBoard: ((ItemType) -> Void)?

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
    /// 게임이 진행 중이 아니어서 받지 못했으면 false를 반환한다 (호출측에서 보드로 되돌려야 함).
    @discardableResult
    func collect(_ type: ItemType) -> Bool {
        guard phase == .playing else { return false }
        withAnimation(.spring(duration: 0.25)) {
            tray.append(type)
            tray.sort { $0.rawValue < $1.rawValue }
        }
        // 빼둔 아이템과 합쳐 3개가 완성되면 버퍼에서 자동으로 돌아온다 (갈매기 게임식)
        let inTray = tray.filter { $0 == type }.count
        let inBuffer = buffer.filter { $0 == type }.count
        if inTray < 3, inBuffer > 0, inTray + inBuffer >= 3 {
            withAnimation(.spring(duration: 0.25)) {
                for _ in 0..<(3 - inTray) {
                    if let index = buffer.firstIndex(of: type) {
                        buffer.remove(at: index)
                        tray.append(type)
                    }
                }
                tray.sort { $0.rawValue < $1.rawValue }
            }
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
        return true
    }

    func useTimeBoost() {
        guard phase == .playing, timeBoostLeft > 0 else { return }
        timeBoostLeft -= 1
        timeRemaining += 30
    }

    /// ↩️ 빼두기: 트레이 앞쪽 아이템 최대 3개를 위 선반(버퍼)으로 올려 자리를 비운다.
    /// 빼둔 아이템은 같은 종류 3개가 완성되는 순간 자동으로 돌아와 매치된다.
    func useHold() {
        guard phase == .playing, holdLeft > 0, buffer.isEmpty, !tray.isEmpty else { return }
        holdLeft -= 1
        withAnimation(.spring(duration: 0.3)) {
            let moved = Array(tray.prefix(3))
            tray.removeFirst(moved.count)
            buffer = moved
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func togglePause() {
        if phase == .playing { phase = .paused }
        else if phase == .paused { phase = .playing }
    }

    /// 보상 광고 시청 후 이어하기: 트레이 1칸 비우기 + 15초 추가 (판당 1회)
    /// 비운 아이템은 삭제하지 않고 보드로 되돌린다 (삭제하면 총량이 모자라 클리어 불가)
    func reviveWithAd() {
        guard phase == .lost, !usedRevive else { return }
        usedRevive = true
        if !tray.isEmpty {
            var returned: ItemType?
            withAnimation(.spring(duration: 0.3)) { returned = tray.removeLast() }
            if let returned { onItemReturnedToBoard?(returned) }
        }
        timeRemaining += 15
        phase = .playing
        startTimer()
    }

    /// 보상 광고 시청 후 부스터 충전
    func refillBoosters() {
        holdLeft += 1
        magnetLeft += 1
        timeBoostLeft += 1
    }

    private func finish(won: Bool) {
        phase = won ? .won : .lost
        timerCancellable?.cancel()
        if !won {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
