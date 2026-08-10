import Foundation

/// 보드에 등장하는 아이템 종류 (총 71종 = 과일·채소 29 + 음식 42).
/// 순서가 곧 해금 순서다: 과일이 먼저 하나씩 추가되고, 이후 음식이 이어서 추가된다.
/// (해금된 아이템은 이후 레벨에서도 계속 등장 — 끊기지 않는다)
enum ItemType: String, CaseIterable, Identifiable, Hashable {
    // ── 과일·채소 29종 (먼저 해금)
    case coconut, apple, banana, strawberry, orange, watermelon, watermelonSlice
    case pineapple, grape, peach, lemon, cherry, kiwi, pear
    case mango, blueberry, melon, persimmon, plum, fig, pomegranate
    case dragonfruit, avocado, tomato, carrot, papaya, hallabong, lime, greenGrape
    // ── 음식 42종 (과일 이후 해금)
    case chicken, pizza, burger, cheese, tteokbokki, ramen, milk
    case mandu, gimbap, takeout, fries, popcorn, hotdog, donut
    case cola, juiceBox, onigiri, sushi, bungeoppang, hotteok, corndog
    case friedShrimp, eggTart, pieSlice, croissant, pancake, waffle, icecream
    case popsicle, cupcake, cakeSlice, chocolate, cookie, candy, lollipop
    case skewer, friedEgg, toast, butter, sandwich, shavedIce, boba

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .coconut: return "🥥"
        case .apple: return "🍎"
        case .banana: return "🍌"
        case .strawberry: return "🍓"
        case .orange: return "🍊"
        case .watermelon: return "🍉"
        case .watermelonSlice: return "🍉"
        case .pineapple: return "🍍"
        case .grape: return "🍇"
        case .peach: return "🍑"
        case .lemon: return "🍋"
        case .cherry: return "🍒"
        case .kiwi: return "🥝"
        case .pear: return "🍐"
        case .mango: return "🥭"
        case .blueberry: return "🫐"
        case .melon: return "🍈"
        case .persimmon: return "🟠"
        case .plum: return "🟣"
        case .fig: return "🍇"
        case .pomegranate: return "❤️"
        case .dragonfruit: return "🐉"
        case .avocado: return "🥑"
        case .tomato: return "🍅"
        case .carrot: return "🥕"
        case .papaya: return "🧡"
        case .hallabong: return "🍊"
        case .lime: return "🟢"
        case .greenGrape: return "💚"
        case .chicken: return "🍗"
        case .pizza: return "🍕"
        case .burger: return "🍔"
        case .cheese: return "🧀"
        case .tteokbokki: return "🌶"
        case .ramen: return "🍜"
        case .milk: return "🥛"
        case .mandu: return "🥟"
        case .gimbap: return "🍘"
        case .takeout: return "🥡"
        case .fries: return "🍟"
        case .popcorn: return "🍿"
        case .hotdog: return "🌭"
        case .donut: return "🍩"
        case .cola: return "🥤"
        case .juiceBox: return "🧃"
        case .onigiri: return "🍙"
        case .sushi: return "🍣"
        case .bungeoppang: return "🐟"
        case .hotteok: return "🫓"
        case .corndog: return "🍢"
        case .friedShrimp: return "🍤"
        case .eggTart: return "🥧"
        case .pieSlice: return "🥧"
        case .croissant: return "🥐"
        case .pancake: return "🥞"
        case .waffle: return "🧇"
        case .icecream: return "🍦"
        case .popsicle: return "🍨"
        case .cupcake: return "🧁"
        case .cakeSlice: return "🍰"
        case .chocolate: return "🍫"
        case .cookie: return "🍪"
        case .candy: return "🍬"
        case .lollipop: return "🍭"
        case .skewer: return "🍡"
        case .friedEgg: return "🍳"
        case .toast: return "🍞"
        case .butter: return "🧈"
        case .sandwich: return "🥪"
        case .shavedIce: return "🍧"
        case .boba: return "🧋"
        }
    }
}
