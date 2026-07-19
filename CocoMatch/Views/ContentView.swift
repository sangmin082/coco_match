import SwiftUI

/// 루트 화면: 메뉴(레벨 선택) ↔ 게임 화면 전환
struct ContentView: View {
    @AppStorage("unlockedLevel") private var unlockedLevel = 1
    @State private var currentLevel: Int?
    @State private var session = 0

    var body: some View {
        if let level = currentLevel {
            GameView(
                levelNumber: level,
                onExit: { currentLevel = nil },
                onNext: {
                    if level < LevelData.maxLevel {
                        currentLevel = level + 1
                        session += 1
                    } else {
                        currentLevel = nil
                    }
                },
                onRetry: { session += 1 }
            )
            .id("game-\(level)-\(session)")
        } else {
            MenuView(unlockedLevel: unlockedLevel) { level in
                currentLevel = level
                session += 1
            }
        }
    }
}

/// 메인 메뉴 + 레벨 선택 그리드
struct MenuView: View {
    let unlockedLevel: Int
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.85, blue: 0.55),
                    Color(red: 0.55, green: 0.83, blue: 0.93)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                Text("🥥")
                    .font(.system(size: 72))
                Text("코코 매치")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
                Text("기울이고 · 흔들고 · 3개씩 맞추세요!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.bottom, 12)

                Button {
                    onSelect(unlockedLevel)
                } label: {
                    Text("플레이 ▶ 레벨 \(min(unlockedLevel, LevelData.maxLevel))")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.orange, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...LevelData.maxLevel, id: \.self) { level in
                            LevelCell(
                                level: level,
                                unlocked: level <= unlockedLevel,
                                action: { onSelect(level) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .padding(.top, 30)
        }
    }
}

struct LevelCell: View {
    let level: Int
    let unlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(unlocked ? Color.white.opacity(0.95) : Color.white.opacity(0.35))
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                if unlocked {
                    Text("\(level)")
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                }
            }
            .frame(height: 60)
        }
        .disabled(!unlocked)
    }
}
