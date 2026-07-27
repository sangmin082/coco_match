import Foundation

/// 보드에 등장하는 아이템 종류 (총 59종).
/// 순서가 곧 해금 순서다: 초반은 과일 7종으로 시작하고,
/// 이후 음식과 과일이 번갈아 추가되며 메뉴가 계속 풍성해진다.
enum ItemType: String, CaseIterable, Identifiable, Hashable {
    // ── 시작 과일 7종
    case coconut, apple, banana, strawberry, orange, watermelon, pineapple
    // ── 이후 음식·과일 번갈아 해금
    case chicken, grape, pizza, peach, burger, lemon, tteokbokki, cherry
    case ramen, kiwi, mandu, pear, gimbap, mango, fries, blueberry
    case hotdog, melon, donut, persimmon, cola, plum, onigiri, fig
    case sushi, pomegranate, bungeoppang, dragonfruit, hotteok, avocado, corndog, tomato
    case friedShrimp, papaya, eggTart, hallabong, croissant, lime, pancake, greenGrape
    case icecream, cupcake, chocolate, cookie, candy, lollipop, skewer, friedEgg
    case toast, sandwich, shavedIce, boba

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
        case .grape: return "🍇"
        case .pizza: return "🍕"
        case .peach: return "🍑"
        case .burger: return "🍔"
        case .lemon: return "🍋"
        case .tteokbokki: return "🌶"
        case .cherry: return "🍒"
        case .ramen: return "🍜"
        case .kiwi: return "🥝"
        case .mandu: return "🥟"
        case .pear: return "🍐"
        case .gimbap: return "🍘"
        case .mango: return "🥭"
        case .fries: return "🍟"
        case .blueberry: return "🫐"
        case .hotdog: return "🌭"
        case .melon: return "🍈"
        case .donut: return "🍩"
        case .persimmon: return "🟠"
        case .cola: return "🥤"
        case .plum: return "🟣"
        case .onigiri: return "🍙"
        case .sushi: return "🍣"
        case .pomegranate: return "❤️"
        case .bungeoppang: return "🐟"
        case .dragonfruit: return "🐉"
        case .hotteok: return "🫓"
        case .avocado: return "🥑"
        case .corndog: return "🍢"
        case .tomato: return "🍅"
        case .friedShrimp: return "🍤"
        case .papaya: return "🧡"
        case .eggTart: return "🥧"
        case .hallabong: return "🍊"
        case .croissant: return "🥐"
        case .lime: return "🟢"
        case .pancake: return "🥞"
        case .greenGrape: return "💚"
        case .icecream: return "🍦"
        case .cupcake: return "🧁"
        case .chocolate: return "🍫"
        case .cookie: return "🍪"
        case .candy: return "🍬"
        case .lollipop: return "🍭"
        case .skewer: return "🍡"
        case .friedEgg: return "🍳"
        case .toast: return "🍞"
        case .sandwich: return "🥪"
        case .shavedIce: return "🍧"
        case .boba: return "🧋"
        }
    }
}
