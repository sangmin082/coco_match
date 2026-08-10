import Foundation
import CoreGraphics

/// 레벨 구성. 기획서(docs/GAME_DESIGN.md)의 난이도 공식으로 50레벨을 생성한다.
struct LevelData {
    let number: Int
    let itemTypes: [ItemType]
    let triplesPerType: Int
    let timeLimit: Int
    let itemScale: CGFloat

    var totalItems: Int { itemTypes.count * triplesPerType * 3 }

    static let maxLevel = 100

    static func level(_ n: Int) -> LevelData {
        // 레벨마다 새 아이템이 해금되어 풀에 "누적"된다 (총 71종, 과일 먼저 → 음식).
        // 난이도는 세 축으로 함께 조여든다:
        //   ① 등장 종류 3 → 7 → 10 → 12 → 14종 (트레이 관리가 어려워짐)
        //   ② 제한시간이 레벨 따라 점점 빡빡해짐 (최대 -40%)
        //   ③ 고레벨은 아이템이 조금 작아지며 개수가 60 → 72 → 84개로 증가
        let all = ItemType.allCases
        let introduced = min(3 + (n * 7) / 10, all.count)
        let typeCap = n >= 75 ? 14 : (n >= 50 ? 12 : (n >= 25 ? 10 : 7))
        let typesUsed = min(introduced, min(3 + (n - 1) / 3, typeCap))
        // 종류가 많아지면 종류당 세트 수를 줄여 총량을 박스 용량 안으로 유지
        let triples = typesUsed > 7 ? 2 : min(2 + (n - 1) / 5, 3)
        // 해금 풀 전체에서 고르게 + 레벨마다 회전 선택 (과일·음식이 골고루 섞임)
        let strideStep = max(1, introduced / typesUsed)
        let types = (0..<typesUsed).map { all[(($0 * strideStep) + n) % introduced] }
        let total = types.count * triples * 3
        // 시간 압박: 레벨이 오를수록 여유가 줄어든다
        let squeeze = min(40, n / 2)
        let timeLimit = (60 + total * 2) * (100 - squeeze) / 100
        // 고레벨은 아이템을 조금 줄여 더 많은 개수를 담는다
        let itemScale: CGFloat = n >= 75 ? 1.05 : (n >= 50 ? 1.12 : 1.25)
        return LevelData(
            number: n,
            itemTypes: types,
            triplesPerType: triples,
            timeLimit: timeLimit,
            itemScale: itemScale
        )
    }
}
