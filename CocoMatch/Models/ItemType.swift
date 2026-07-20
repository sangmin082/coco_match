import Foundation

/// 보드에 등장하는 아이템 종류. 맛있는 야식 테마 12종.
enum ItemType: String, CaseIterable, Identifiable, Hashable {
    case chicken      // 치킨 다리
    case pizza        // 피자 조각
    case burger       // 햄버거
    case tteokbokki   // 떡볶이
    case ramen        // 라면
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
