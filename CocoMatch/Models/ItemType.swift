import UIKit

/// 보드에 등장하는 아이템 종류. 코코 아일랜드(열대 해변) 테마 12종.
enum ItemType: String, CaseIterable, Identifiable, Hashable {
    case coconut
    case banana
    case pineapple
    case strawberry
    case watermelon
    case shell
    case starfish
    case crab
    case hibiscus
    case fish
    case icecream
    case cocktail

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .coconut: return "🥥"
        case .banana: return "🍌"
        case .pineapple: return "🍍"
        case .strawberry: return "🍓"
        case .watermelon: return "🍉"
        case .shell: return "🐚"
        case .starfish: return "⭐"
        case .crab: return "🦀"
        case .hibiscus: return "🌺"
        case .fish: return "🐠"
        case .icecream: return "🍦"
        case .cocktail: return "🍹"
        }
    }

    /// 블록 배경 파스텔 컬러 (같은 종류를 한눈에 구분하기 위한 색)
    var color: UIColor {
        switch self {
        case .coconut: return UIColor(red: 0.96, green: 0.91, blue: 0.82, alpha: 1)
        case .banana: return UIColor(red: 1.00, green: 0.96, blue: 0.75, alpha: 1)
        case .pineapple: return UIColor(red: 1.00, green: 0.90, blue: 0.62, alpha: 1)
        case .strawberry: return UIColor(red: 1.00, green: 0.82, blue: 0.85, alpha: 1)
        case .watermelon: return UIColor(red: 0.83, green: 0.96, blue: 0.83, alpha: 1)
        case .shell: return UIColor(red: 0.92, green: 0.88, blue: 0.98, alpha: 1)
        case .starfish: return UIColor(red: 1.00, green: 0.93, blue: 0.55, alpha: 1)
        case .crab: return UIColor(red: 1.00, green: 0.85, blue: 0.78, alpha: 1)
        case .hibiscus: return UIColor(red: 1.00, green: 0.80, blue: 0.90, alpha: 1)
        case .fish: return UIColor(red: 0.78, green: 0.92, blue: 1.00, alpha: 1)
        case .icecream: return UIColor(red: 0.98, green: 0.95, blue: 0.93, alpha: 1)
        case .cocktail: return UIColor(red: 0.80, green: 0.98, blue: 0.94, alpha: 1)
        }
    }
}
