import Foundation

/// 보드에 등장하는 아이템 종류.
/// 순서가 곧 등장 순서다: 초반 레벨은 과일, 레벨이 오르면 야식이 계속 추가된다.
enum ItemType: String, CaseIterable, Identifiable, Hashable {
    // 과일 (초반 레벨)
    case coconut      // 코코넛 (마스코트!)
    case apple        // 사과
    case banana       // 바나나
    case strawberry   // 딸기
    case orange       // 오렌지
    case watermelon   // 수박
    case pineapple    // 파인애플
    // 야식 (레벨 16부터 순차 등장)
    case chicken      // 치킨 다리
    case pizza        // 피자 조각
    case burger       // 햄버거
    case tteokbokki   // 떡볶이
    case ramen        // 컵라면
    case mandu        // 만두
    case gimbap       // 김밥
    case fries        // 감자튀김
    case hotdog       // 핫도그
    case donut        // 도넛
    case cola         // 콜라
    case onigiri      // 삼각김밥

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .coconut: return "🥥"
        case .apple: return "🍎"
        case .banana: return "🍌"
        case .strawberry: return "🍓"
        case .orange: return "🍊"
        case .watermelon: return "🍉"
        case .pineapple: return "🍍"
        case .chicken: return "🍗"
        case .pizza: return "🍕"
        case .burger: return "🍔"
        case .tteokbokki: return "🌶"
        case .ramen: return "🍜"
        case .mandu: return "🥟"
        case .gimbap: return "🍘"
        case .fries: return "🍟"
        case .hotdog: return "🌭"
        case .donut: return "🍩"
        case .cola: return "🥤"
        case .onigiri: return "🍙"
        }
    }
}
