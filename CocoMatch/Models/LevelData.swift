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

    static func level(_ n: Int) -> LevelData {
        // 레벨은 끝없이 이어진다 (갈매기 게임식 총량 경제):
        //   · 종당 5세트(15개) 고정
        //   · 레벨 1 = 3종(45개)에서 시작해 매 레벨 1종씩 꾸준히 증가 (최대 71종 전부)
        //   · 총 개수는 화면 밖 대기열로 유지 — 수집할 때마다 새 아이템이 떨어진다
        //   · 제한시간은 레벨 따라 점점 빡빡해짐 (최대 -45%)
        let all = ItemType.allCases
        let typesUsed = min(2 + n, all.count)
        // 해금 풀은 사용 종수보다 살짝 앞서 열려, 레벨마다 회전 선택으로 구성이 바뀐다
        let introduced = min(typesUsed + 6, all.count)
        let types = (0..<typesUsed).map { all[($0 + n - 1) % introduced] }
        let triples = 5
        let total = typesUsed * triples * 3
        // 시간 압박: 레벨이 오를수록 여유가 줄어든다
        let squeeze = min(45, n / 2)
        let timeLimit = (60 + total * 2) * (100 - squeeze) / 100
        return LevelData(
            number: n,
            itemTypes: types,
            triplesPerType: triples,
            timeLimit: timeLimit,
            itemScale: 1.22
        )
    }
}
