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
        // 약 1.7레벨마다 새 아이템이 1종씩 해금된다 (총 59종, 레벨 94쯤 전체 등장).
        // 초반은 과일, 이후 음식·과일이 번갈아 추가된다.
        // 한 레벨에는 "가장 최근 해금된 7종"만 사용해서(슬라이딩 윈도우)
        // 메뉴가 계속 바뀌고, 총 아이템 수 상한은 63개다.
        let all = ItemType.allCases
        let introduced = min(3 + (n * 3) / 5, all.count)
        let windowSize = min(introduced, 7)
        let types = Array(all.prefix(introduced).suffix(windowSize))
        let triples = min(2 + (n - 1) / 5, 3)
        let total = types.count * triples * 3
        return LevelData(
            number: n,
            itemTypes: types,
            triplesPerType: triples,
            timeLimit: 60 + total * 2
        )
    }
}
