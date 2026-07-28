import Foundation

/// 보드에 등장하는 아이템 종류 (총 59종).
/// 순서가 곧 해금 순서다: 과일 27종이 먼저 하나씩 추가되고,
/// 과일이 모두 나온 뒤 야식 32종이 이어서 하나씩 추가된다.
/// (해금된 아이템은 이후 레벨에서도 계속 등장 — 끊기지 않는다)
enum ItemType: String, CaseIterable, Identifiable, Hashable {
    // ── 과일 27종 (먼저 해금)
    case coconut, apple, banana, strawberry, orange, watermelon, pineapple
    case grape, peach, lemon, cherry, kiwi, pear, mango
    case blueberry, melon, persimmon, plum, fig, pomegranate, dragonfruit
    case avocado, tomato, papaya, hallabong, lime, greenGrape
    // ── 야식·음식 32종 (과일 이후 해금)
    case chicken, pizza, burger, tteokbokki, ramen, mandu, gimbap
    case fries, hotdog, donut, cola, onigiri, sushi, bungeoppang
    case hotteok, corndog, friedShrimp, eggTart, croissant, pancake
    case icecream, cupcake, chocolate, cookie, candy, lollipop, skewer
    case friedEgg, toast, sandwich, shavedIce, boba

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
        case .fig: return "🍇"
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
