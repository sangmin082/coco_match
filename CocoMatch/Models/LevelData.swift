import Foundation

/// 레벨 구성. 기획서(docs/GAME_DESIGN.md)의 난이도 공식으로 50레벨을 생성한다.
struct LevelData {
    let number: Int
    let itemTypes: [ItemType]
    let triplesPerType: Int
    let timeLimit: Int

    var totalItems: Int { itemTypes.count * triplesPerType * 3 }

    static let maxLevel = 50

    static func level(_ n: Int) -> LevelData {
        let all = ItemType.allCases
        let typeCount = min(3 + (n - 1) / 3, 10)
        let triples = min(2 + (n - 1) / 5, 3)
        let total = typeCount * triples * 3
        return LevelData(
            number: n,
            itemTypes: Array(all.prefix(typeCount)),
            triplesPerType: triples,
            timeLimit: 60 + total * 2
        )
    }
}
