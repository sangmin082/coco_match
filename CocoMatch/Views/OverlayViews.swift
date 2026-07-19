import SwiftUI

/// 하단 트레이: 7칸, 같은 종류끼리 정렬되어 표시된다.
struct TrayView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<gameState.trayCapacity, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    if index < gameState.tray.count {
                        Text(gameState.tray[index].emoji)
                            .font(.system(size: 28))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 44, height: 52)
            }
        }
        .padding(10)
        .background(.brown.opacity(0.75), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// 부스터 버튼 (남은 횟수 배지 포함)
struct BoosterButton: View {
    let emoji: String
    let title: String
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(emoji).font(.system(size: 26))
                Text(title).font(.caption2.bold())
            }
            .foregroundStyle(.white)
            .frame(width: 64, height: 58)
            .background(.black.opacity(count > 0 ? 0.35 : 0.15), in: RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .topTrailing) {
                Text("\(count)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(count > 0 ? Color.orange : Color.gray, in: Circle())
                    .offset(x: 5, y: -5)
            }
        }
        .disabled(count == 0)
    }
}

/// 클리어/실패/일시정지 공용 팝업
struct ResultOverlay: View {
    let title: String
    let subtitle: String
    let primary: (String, () -> Void)
    let secondary: (String, () -> Void)

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 18) {
                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Button(action: primary.1) {
                    Text(primary.0)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.orange, in: RoundedRectangle(cornerRadius: 14))
                }

                Button(action: secondary.1) {
                    Text(secondary.0)
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(24)
            .background(.white, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 40)
        }
    }
}
