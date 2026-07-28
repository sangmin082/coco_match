import Foundation

/// 레벨 구성. 기획서(docs/GAME_DESIGN.md)의 난이도 공식으로 50레벨을 생성한다.
struct LevelData {
    let number: Int
    let itemTypes: [ItemType]
    let triplesPerType: Int
    let timeLimit: Int

    var totalItems: Int { itemTypes.count * triplesPerType * 3 }

    static let maxLevel = 100

    static func level(_ n: Int) -> LevelData {
        // 약 1.7레벨마다 새 아이템이 1종씩 해금되어 풀에 "누적"된다 (총 59종).
        // 과일 27종이 먼저 차례로, 그다음 야식 32종이 이어서 해금된다.
        // 한 판에 등장하는 종류 수는 레벨에 따라 3종 → 10종으로 늘어나고,
        // 해금된 전체 풀에서 고르게 회전 선택하므로 과일도 끝까지 계속 등장한다.
        let all = ItemType.allCases
        let introduced = min(3 + (n * 3) / 5, all.count)
        // 등장 종류: 3종에서 시작해 3레벨마다 +1, 레벨 25부터 최대 10종
        let typeCap = n >= 25 ? 10 : 7
        let typesUsed = min(introduced, min(3 + (n - 1) / 3, typeCap))
        // 종류가 많아지면 종류당 세트 수를 줄여 총량을 박스 용량(약 63개) 안으로 유지
        let triples = typesUsed > 7 ? 2 : min(2 + (n - 1) / 5, 3)
        // 해금 풀 전체에서 고르게 + 레벨마다 회전 선택 (과일·야식이 골고루 섞임)
        let strideStep = max(1, introduced / typesUsed)
        let types = (0..<typesUsed).map { all[(($0 * strideStep) + n) % introduced] }
        let total = types.count * triples * 3
        return LevelData(
            number: n,
            itemTypes: types,
            triplesPerType: triples,
            timeLimit: 60 + total * 2
        )
    }
}
