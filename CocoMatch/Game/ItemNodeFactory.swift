import SceneKit
import UIKit

/// 아이템을 실물처럼 보이는 3D 컴포지트 노드로 만든다. (과일 + 야식 19종)
/// - 절차적 텍스처(튀김옷 얼룩, 빵 그라데이션, 줄무늬 등)로 질감을 입히고
/// - 스케일된 구(타원체)로 자유로운 형태를 만들고
/// - 소스는 광택, 빵은 매트 — 재질 광택을 분리해 "맛있어 보이는" 룩을 만든다.
/// 물리 충돌은 전체 크기를 근사하는 단순 도형(collision)으로 계산한다.
enum ItemNodeFactory {

    static func makeNode(for type: ItemType, scale levelScale: CGFloat = 1.25) -> SCNNode {
        let node = SCNNode()
        node.name = type.rawValue

        let collision: SCNGeometry
        switch type {
        case .coconut: collision = buildCoconut(in: node)
        case .apple: collision = buildApple(in: node)
        case .banana: collision = buildBanana(in: node)
        case .strawberry: collision = buildStrawberry(in: node)
        case .orange: collision = buildOrange(in: node)
        case .watermelon: collision = buildWatermelon(in: node)
        case .pineapple: collision = buildPineapple(in: node)
        case .chicken: collision = buildChicken(in: node)
        case .pizza: collision = buildPizza(in: node)
        case .burger: collision = buildBurger(in: node)
        case .tteokbokki: collision = buildTteokbokki(in: node)
        case .ramen: collision = buildRamen(in: node)
        case .mandu: collision = buildMandu(in: node)
        case .gimbap: collision = buildGimbap(in: node)
        case .fries: collision = buildFries(in: node)
        case .hotdog: collision = buildHotdog(in: node)
        case .donut: collision = buildDonut(in: node)
        case .cola: collision = buildCola(in: node)
        case .onigiri: collision = buildOnigiri(in: node)
        case .grape: collision = buildBerryCluster(in: node, color: UIColor(red: 0.48, green: 0.26, blue: 0.58, alpha: 1), radius: 0.17)
        case .greenGrape: collision = buildBerryCluster(in: node, color: UIColor(red: 0.62, green: 0.80, blue: 0.36, alpha: 1), radius: 0.17)
        case .blueberry: collision = buildBerryCluster(in: node, color: UIColor(red: 0.30, green: 0.36, blue: 0.62, alpha: 1), radius: 0.14)
        case .peach: collision = buildPeach(in: node)
        case .lemon: collision = buildCitrus(in: node, texture: lemonTexture, scaleX: 1.25, nubs: true)
        case .lime: collision = buildCitrus(in: node, texture: limeTexture, scaleX: 1.1, nubs: true)
        case .cherry: collision = buildCherry(in: node)
        case .kiwi: collision = buildKiwi(in: node)
        case .pear: collision = buildPear(in: node)
        case .mango: collision = buildMango(in: node)
        case .melon: collision = buildMelon(in: node)
        case .persimmon: collision = buildPersimmon(in: node)
        case .plum: collision = buildPlum(in: node)
        case .fig: collision = buildFig(in: node)
        case .pomegranate: collision = buildPomegranate(in: node)
        case .dragonfruit: collision = buildDragonfruit(in: node)
        case .avocado: collision = buildAvocado(in: node)
        case .tomato: collision = buildTomato(in: node)
        case .papaya: collision = buildPapaya(in: node)
        case .hallabong: collision = buildHallabong(in: node)
        case .sushi: collision = buildSushi(in: node)
        case .bungeoppang: collision = buildBungeoppang(in: node)
        case .hotteok: collision = buildHotteok(in: node)
        case .corndog: collision = buildCorndog(in: node)
        case .friedShrimp: collision = buildFriedShrimp(in: node)
        case .eggTart: collision = buildEggTart(in: node)
        case .croissant: collision = buildCroissant(in: node)
        case .pancake: collision = buildPancake(in: node)
        case .icecream: collision = buildIcecream(in: node)
        case .cupcake: collision = buildCupcake(in: node)
        case .chocolate: collision = buildChocolate(in: node)
        case .cookie: collision = buildCookie(in: node)
        case .candy: collision = buildCandy(in: node)
        case .lollipop: collision = buildLollipop(in: node)
        case .skewer: collision = buildSkewer(in: node)
        case .friedEgg: collision = buildFriedEgg(in: node)
        case .toast: collision = buildToast(in: node)
        case .sandwich: collision = buildSandwich(in: node)
        case .shavedIce: collision = buildShavedIce(in: node)
        case .boba: collision = buildBoba(in: node)
        case .cheese: collision = buildCheese(in: node)
        case .milk: collision = buildMilk(in: node)
        case .juiceBox: collision = buildJuiceBox(in: node)
        case .cakeSlice: collision = buildCakeSlice(in: node)
        case .watermelonSlice: collision = buildWatermelonSlice(in: node)
        case .popsicle: collision = buildPopsicle(in: node)
        case .waffle: collision = buildWaffle(in: node)
        case .pieSlice: collision = buildPieSlice(in: node)
        case .takeout: collision = buildTakeout(in: node)
        case .popcorn: collision = buildPopcorn(in: node)
        case .butter: collision = buildButter(in: node)
        case .carrot: collision = buildCarrot(in: node)
        }

        // 레벨 스케일 × 종류별 크기 편차 (체리는 한입, 수박은 묵직하게)
        let itemScale: CGFloat = levelScale * sizeMultiplier(for: type)
        node.scale = SCNVector3(Float(itemScale), Float(itemScale), Float(itemScale))
        let shape = SCNPhysicsShape(geometry: collision,
                                    options: [SCNPhysicsShape.Option.scale: itemScale])
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        body.mass = 1
        // 부딪히면 시원하게 확 튀되(0.65), 잔진동은 컨트롤러의 강제 정지가 잡는다
        body.restitution = 0.65
        body.friction = 0.6
        body.rollingFriction = 0.55
        body.angularDamping = 0.85
        body.damping = 0.32
        body.allowsResting = true
        node.physicsBody = body
        return node
    }

    /// 종류별 크기 편차 — 실제 크기 비율을 게임 스케일로 압축해 반영한다.
    /// (체리 한 알 ↔ 수박 한 통이 실제처럼 제각각으로 보이되, 탭 가능한 범위 유지)
    private static func sizeMultiplier(for type: ItemType) -> CGFloat {
        switch type {
        // 미니 — 한입 크기 (체리 알, 초밥 한 점, 사탕)
        case .cherry, .blueberry, .candy, .sushi, .butter:
            return 0.65
        // 소형 — 손 안에 쏙 (딸기, 자두, 쿠키, 만두)
        case .strawberry, .lime, .plum, .fig, .cookie, .eggTart,
             .mandu, .chocolate, .juiceBox, .onigiri:
            return 0.78
        // 중소형 — 주먹보다 작게 (레몬, 키위, 도넛, 컵케이크)
        case .lemon, .kiwi, .peach, .tomato, .grape, .greenGrape,
             .friedEgg, .donut, .cupcake, .hotteok, .croissant,
             .popsicle, .friedShrimp, .carrot:
            return 0.88
        // 중대형 — 묵직한 존재감 (코코넛, 파파야, 라면 그릇, 통닭, 피자)
        case .coconut, .dragonfruit, .papaya, .milk, .ramen,
             .chicken, .pizza, .boba, .shavedIce, .watermelonSlice, .cheese:
            return 1.15
        // 대형 (파인애플, 멜론)
        case .pineapple, .melon:
            return 1.3
        // 최대 (수박 한 통)
        case .watermelon:
            return 1.45
        // 기본 — 사과·오렌지·햄버거급
        default:
            return 1.0
        }
    }

    // MARK: - Helpers

    /// gloss 0 = 완전 매트(빵·밥), 1 = 번들번들(소스·글레이즈)
    private static func material(_ contents: Any, gloss: CGFloat = 0.35,
                                 transparency: CGFloat = 1) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = contents
        m.specular.contents = UIColor(white: 1, alpha: max(0.05, gloss))
        m.shininess = max(0.05, gloss)
        m.transparency = transparency
        return m
    }

    @discardableResult
    private static func part(_ geometry: SCNGeometry, _ contents: Any,
                             position: SCNVector3 = SCNVector3(0, 0, 0),
                             euler: SCNVector3 = SCNVector3(0, 0, 0),
                             scale: SCNVector3 = SCNVector3(1, 1, 1),
                             gloss: CGFloat = 0.35,
                             transparency: CGFloat = 1,
                             in parent: SCNNode) -> SCNNode {
        geometry.materials = [material(contents, gloss: gloss, transparency: transparency)]
        let n = SCNNode(geometry: geometry)
        n.position = position
        n.eulerAngles = euler
        n.scale = scale
        parent.addChildNode(n)
        return n
    }

    private static func texture(width: Int = 256, height: Int = 256,
                                _ draw: (CGContext, CGSize) -> Void) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in draw(ctx.cgContext, size) }
    }

    private static func fillBase(_ c: CGContext, _ s: CGSize, _ color: UIColor) {
        c.setFillColor(color.cgColor)
        c.fill(CGRect(origin: .zero, size: s))
    }

    /// 무작위 얼룩 점 뿌리기 (튀김옷·과일 껍질 질감)
    private static func speckle(_ c: CGContext, _ s: CGSize, color: UIColor,
                                count: Int, minR: CGFloat, maxR: CGFloat) {
        c.setFillColor(color.cgColor)
        for _ in 0..<count {
            let r = CGFloat.random(in: minR...maxR)
            let x = CGFloat.random(in: 0...s.width)
            let y = CGFloat.random(in: 0...s.height)
            c.fillEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
    }

    private static func verticalGradient(_ c: CGContext, _ s: CGSize,
                                         top: UIColor, bottom: UIColor) {
        let colors = [top.cgColor, bottom.cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors, locations: [0, 1]) {
            c.drawLinearGradient(gradient, start: .zero,
                                 end: CGPoint(x: 0, y: s.height), options: [])
        }
    }

    // MARK: - Palette

    private static let bunTan = UIColor(red: 0.93, green: 0.72, blue: 0.42, alpha: 1)
    private static let sauceRed = UIColor(red: 0.83, green: 0.20, blue: 0.12, alpha: 1)
    private static let cheeseYellow = UIColor(red: 0.98, green: 0.80, blue: 0.30, alpha: 1)
    private static let riceWhite = UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 1)
    private static let darkBrown = UIColor(red: 0.28, green: 0.19, blue: 0.12, alpha: 1)
    private static let leafGreen = UIColor(red: 0.30, green: 0.62, blue: 0.32, alpha: 1)
    private static let tomatoRed = UIColor(red: 0.84, green: 0.27, blue: 0.19, alpha: 1)
    private static let mustardYellow = UIColor(red: 0.95, green: 0.76, blue: 0.15, alpha: 1)

    // MARK: - Textures

    /// 바삭한 튀김옷: 황금빛 바탕 + 밝고 어두운 얼룩
    private static let crispyTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.78, green: 0.51, blue: 0.24, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.62, green: 0.37, blue: 0.15, alpha: 0.55), count: 70, minR: 3, maxR: 10)
        speckle(c, s, color: UIColor(red: 0.93, green: 0.68, blue: 0.36, alpha: 0.6), count: 60, minR: 2, maxR: 8)
    }

    /// 노릇하게 구운 빵: 위는 진하고 아래로 밝아지는 그라데이션 + 미세 질감
    private static let bunTexture: UIImage = texture { c, s in
        verticalGradient(c, s,
                         top: UIColor(red: 0.85, green: 0.58, blue: 0.28, alpha: 1),
                         bottom: UIColor(red: 0.96, green: 0.80, blue: 0.55, alpha: 1))
        speckle(c, s, color: UIColor(white: 1, alpha: 0.12), count: 50, minR: 1, maxR: 3)
    }

    /// 불맛 패티: 진갈색 + 그을린 점
    private static let pattyTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.36, green: 0.21, blue: 0.11, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.18, green: 0.09, blue: 0.04, alpha: 0.7), count: 60, minR: 2, maxR: 7)
        speckle(c, s, color: UIColor(red: 0.52, green: 0.32, blue: 0.17, alpha: 0.6), count: 40, minR: 2, maxR: 5)
    }

    /// 소시지: 붉은 바탕 + 그릴 자국 링
    private static let sausageTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.72, green: 0.29, blue: 0.16, alpha: 1))
        c.setFillColor(UIColor(red: 0.50, green: 0.17, blue: 0.08, alpha: 0.8).cgColor)
        for i in 0..<6 {
            c.fill(CGRect(x: 0, y: CGFloat(i) * 44 + 14, width: s.width, height: 7))
        }
    }

    /// 딸기 껍질: 붉은 그라데이션 + 노란 씨앗
    private static let strawberryTexture: UIImage = texture { c, s in
        verticalGradient(c, s,
                         top: UIColor(red: 0.93, green: 0.23, blue: 0.28, alpha: 1),
                         bottom: UIColor(red: 0.80, green: 0.10, blue: 0.16, alpha: 1))
        c.setFillColor(UIColor(red: 0.98, green: 0.87, blue: 0.52, alpha: 0.95).cgColor)
        for row in 0..<6 {
            for col in 0..<8 {
                let x = CGFloat(col) * 32 + (row % 2 == 0 ? 8 : 24)
                let y = CGFloat(row) * 40 + 14
                c.fillEllipse(in: CGRect(x: x, y: y, width: 5, height: 8))
            }
        }
    }

    /// 오렌지 껍질: 주황 + 미세 모공
    private static let orangeTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.96, green: 0.58, blue: 0.12, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.82, green: 0.44, blue: 0.06, alpha: 0.5), count: 130, minR: 1, maxR: 3)
        speckle(c, s, color: UIColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 0.45), count: 60, minR: 1, maxR: 2.5)
    }

    /// 사과 껍질: 광택 있는 붉은 그라데이션 + 세로 결
    private static let appleTexture: UIImage = texture { c, s in
        verticalGradient(c, s,
                         top: UIColor(red: 0.72, green: 0.10, blue: 0.13, alpha: 1),
                         bottom: UIColor(red: 0.92, green: 0.24, blue: 0.22, alpha: 1))
        c.setStrokeColor(UIColor(red: 1.0, green: 0.55, blue: 0.45, alpha: 0.25).cgColor)
        c.setLineWidth(3)
        for i in 0..<10 {
            let x = CGFloat(i) * 26 + 10
            c.move(to: CGPoint(x: x, y: 30))
            c.addLine(to: CGPoint(x: x + 6, y: 150))
            c.strokePath()
        }
    }

    /// 코코넛 섬유질: 갈색 + 거친 세로 털 결
    private static let coconutTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.44, green: 0.30, blue: 0.20, alpha: 1))
        for _ in 0..<160 {
            let shade = CGFloat.random(in: 0...1)
            c.setStrokeColor(UIColor(red: 0.30 + shade * 0.25, green: 0.20 + shade * 0.16,
                                     blue: 0.12 + shade * 0.10, alpha: 0.7).cgColor)
            c.setLineWidth(CGFloat.random(in: 1...2.5))
            let x = CGFloat.random(in: 0...s.width)
            let y = CGFloat.random(in: 0...s.height)
            c.move(to: CGPoint(x: x, y: y))
            c.addLine(to: CGPoint(x: x + CGFloat.random(in: -6...6), y: y + CGFloat.random(in: 14...36)))
            c.strokePath()
        }
    }

    /// 수박: 연두 바탕 + 들쭉날쭉한 진초록 줄무늬
    private static let watermelonTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.45, green: 0.72, blue: 0.36, alpha: 1))
        c.setFillColor(UIColor(red: 0.13, green: 0.38, blue: 0.16, alpha: 1).cgColor)
        for i in 0..<7 {
            let x = CGFloat(i) * 38 + 8
            var y: CGFloat = 0
            while y < s.height {
                let w = CGFloat.random(in: 10...20)
                c.fillEllipse(in: CGRect(x: x + CGFloat.random(in: -4...4), y: y, width: w, height: 26))
                y += 16
            }
        }
    }

    /// 파인애플: 황금 바탕 + 다이아몬드 격자
    private static let pineappleTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.90, green: 0.64, blue: 0.22, alpha: 1))
        c.setStrokeColor(UIColor(red: 0.68, green: 0.44, blue: 0.10, alpha: 0.85).cgColor)
        c.setLineWidth(4)
        var offset: CGFloat = -s.height
        while offset < s.width {
            c.move(to: CGPoint(x: offset, y: 0))
            c.addLine(to: CGPoint(x: offset + s.height, y: s.height))
            c.move(to: CGPoint(x: offset + s.height, y: 0))
            c.addLine(to: CGPoint(x: offset, y: s.height))
            c.strokePath()
            offset += 42
        }
        speckle(c, s, color: UIColor(red: 0.55, green: 0.33, blue: 0.06, alpha: 0.8), count: 36, minR: 2, maxR: 3.5)
    }

    /// 김: 진한 해태색 + 은은한 광택 결
    private static let noriTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.10, green: 0.13, blue: 0.08, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.20, green: 0.30, blue: 0.14, alpha: 0.5), count: 120, minR: 1, maxR: 4)
    }

    /// 밥: 흰 바탕 + 밥알 음영
    private static let riceTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1))
        c.setFillColor(UIColor(red: 0.86, green: 0.84, blue: 0.78, alpha: 0.7).cgColor)
        for _ in 0..<90 {
            c.fillEllipse(in: CGRect(x: CGFloat.random(in: 0...s.width),
                                     y: CGFloat.random(in: 0...s.height),
                                     width: 7, height: 3.5))
        }
    }

    /// 컵라면 몸통: 크림 바탕 + 빨간 브랜드 밴드
    private static let cupRamenTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.96, green: 0.93, blue: 0.86, alpha: 1))
        c.setFillColor(UIColor(red: 0.80, green: 0.16, blue: 0.11, alpha: 1).cgColor)
        c.fill(CGRect(x: 0, y: 60, width: s.width, height: 56))
        c.setFillColor(UIColor.white.cgColor)
        c.fill(CGRect(x: 96, y: 74, width: 64, height: 28))
        c.setFillColor(UIColor(red: 0.80, green: 0.16, blue: 0.11, alpha: 1).cgColor)
        c.fill(CGRect(x: 0, y: 190, width: s.width, height: 8))
    }

    /// 콜라 컵: 빨간 바탕 + 흰 물결 리본
    private static let colaTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.78, green: 0.12, blue: 0.10, alpha: 1))
        c.setFillColor(UIColor.white.cgColor)
        for i in 0..<9 {
            let x = CGFloat(i) * 30 - 6
            let y: CGFloat = i % 2 == 0 ? 108 : 122
            c.fillEllipse(in: CGRect(x: x, y: y, width: 40, height: 22))
        }
    }

    // MARK: - Fruits (초반 레벨)

    /// 🥥 코코넛: 섬유질 텍스처 + 반점 3개
    private static func buildCoconut(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.55), coconutTexture, gloss: 0.15, in: parent)
        for p in [SCNVector3(0, 0.50, 0.25), SCNVector3(-0.22, 0.48, 0.12), SCNVector3(0.22, 0.48, 0.12)] {
            part(SCNSphere(radius: 0.09), darkBrown, position: p, gloss: 0.1, in: parent)
        }
        return SCNSphere(radius: 0.55)
    }

    /// 🍎 사과: 광택 그라데이션 껍질 + 꼭지 홈 + 잎
    private static func buildApple(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.52), appleTexture,
             scale: SCNVector3(1, 0.94, 1), gloss: 0.85, in: parent)
        part(SCNSphere(radius: 0.11), UIColor(red: 0.55, green: 0.07, blue: 0.10, alpha: 1),
             position: SCNVector3(0, 0.44, 0), scale: SCNVector3(1.4, 0.5, 1.4), gloss: 0.3, in: parent)
        part(SCNCylinder(radius: 0.04, height: 0.26), darkBrown,
             position: SCNVector3(0, 0.55, 0), euler: SCNVector3(0, 0, 0.15), gloss: 0.15, in: parent)
        part(SCNSphere(radius: 0.16), leafGreen,
             position: SCNVector3(0.17, 0.54, 0),
             euler: SCNVector3(0, 0, 0.5),
             scale: SCNVector3(1, 0.28, 0.5), gloss: 0.55, in: parent)
        return SCNSphere(radius: 0.52)
    }

    /// 🍌 바나나: 매끈한 크레센트 + 갈색 꼭지 + 능선
    private static func buildBanana(in parent: SCNNode) -> SCNGeometry {
        let yellow = UIColor(red: 0.99, green: 0.83, blue: 0.26, alpha: 1)
        let ridge = UIColor(red: 0.88, green: 0.70, blue: 0.16, alpha: 1)
        part(SCNCapsule(capRadius: 0.17, height: 0.62), yellow,
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.5, in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 0.55), yellow,
             position: SCNVector3(-0.40, 0.14, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 + 0.6), gloss: 0.5, in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 0.55), yellow,
             position: SCNVector3(0.40, 0.14, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 - 0.6), gloss: 0.5, in: parent)
        part(SCNCapsule(capRadius: 0.045, height: 0.60), ridge,
             position: SCNVector3(0, 0.16, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.4, in: parent)
        part(SCNCapsule(capRadius: 0.06, height: 0.14), darkBrown,
             position: SCNVector3(-0.64, 0.32, 0), euler: SCNVector3(0, 0, 0.9), gloss: 0.2, in: parent)
        part(SCNSphere(radius: 0.06), darkBrown, position: SCNVector3(0.63, 0.31, 0), gloss: 0.2, in: parent)
        return SCNBox(width: 1.4, height: 0.6, length: 0.4, chamferRadius: 0.15)
    }

    /// 🍓 딸기: 씨앗 박힌 광택 껍질 + 잎 왕관
    private static func buildStrawberry(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.45, bottomRadius: 0.07, height: 0.85), strawberryTexture,
             gloss: 0.75, in: parent)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi
            part(SCNSphere(radius: 0.17), leafGreen,
                 position: SCNVector3(0.20 * cos(angle), 0.44, 0.20 * sin(angle)),
                 euler: SCNVector3(0.5 * sin(angle), 0, 0.5 * cos(angle)),
                 scale: SCNVector3(1, 0.22, 0.45), gloss: 0.5, in: parent)
        }
        part(SCNCylinder(radius: 0.035, height: 0.16), leafGreen,
             position: SCNVector3(0, 0.50, 0), gloss: 0.3, in: parent)
        return SCNCone(topRadius: 0.45, bottomRadius: 0.07, height: 0.85)
    }

    /// 🍊 오렌지: 모공 있는 껍질 + 꼭지 잎
    private static func buildOrange(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.52), orangeTexture, gloss: 0.45, in: parent)
        part(SCNSphere(radius: 0.06), leafGreen, position: SCNVector3(0, 0.51, 0), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.17), leafGreen,
             position: SCNVector3(0.16, 0.50, 0),
             euler: SCNVector3(0, 0, 0.6),
             scale: SCNVector3(1, 0.25, 0.45), gloss: 0.5, in: parent)
        return SCNSphere(radius: 0.52)
    }

    /// 🍉 수박: 들쭉날쭉 줄무늬 + 꼭지
    private static func buildWatermelon(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.55), watermelonTexture,
             scale: SCNVector3(1, 0.94, 1.04), gloss: 0.65, in: parent)
        part(SCNCylinder(radius: 0.035, height: 0.18),
             UIColor(red: 0.35, green: 0.45, blue: 0.22, alpha: 1),
             position: SCNVector3(0, 0.55, 0), euler: SCNVector3(0.3, 0, 0.3), gloss: 0.2, in: parent)
        return SCNSphere(radius: 0.55)
    }

    /// 🍍 파인애플: 다이아몬드 격자 몸통 + 잎 왕관
    private static func buildPineapple(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.42, height: 0.95), pineappleTexture,
             position: SCNVector3(0, -0.12, 0), gloss: 0.35, in: parent)
        part(SCNCone(topRadius: 0, bottomRadius: 0.09, height: 0.55), leafGreen,
             position: SCNVector3(0, 0.60, 0), gloss: 0.45, in: parent)
        for i in 0..<6 {
            let angle = Float(i) / 6 * 2 * Float.pi
            part(SCNCone(topRadius: 0, bottomRadius: 0.09, height: 0.45), leafGreen,
                 position: SCNVector3(0.13 * cos(angle), 0.52, 0.13 * sin(angle)),
                 euler: SCNVector3(0.45 * sin(angle), 0, 0.45 * cos(angle)),
                 gloss: 0.45, in: parent)
        }
        return SCNCapsule(capRadius: 0.44, height: 1.3)
    }

    // MARK: - Snacks (야식)

    /// 🍗 치킨 다리: 바삭한 튀김옷 덩어리 + 튀김 부스러기 + 뼈
    private static func buildChicken(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.34), crispyTexture,
             position: SCNVector3(0, 0.18, 0),
             scale: SCNVector3(1, 1.18, 0.96), gloss: 0.5, in: parent)
        part(SCNSphere(radius: 0.24), crispyTexture,
             position: SCNVector3(0.15, 0.36, 0.05), gloss: 0.5, in: parent)
        for (x, y, z, r) in [(-0.22, 0.10, 0.16, 0.10), (0.20, 0.02, -0.14, 0.09),
                             (-0.08, 0.44, -0.12, 0.09), (0.05, -0.06, 0.20, 0.08)] {
            part(SCNSphere(radius: CGFloat(r)), crispyTexture,
                 position: SCNVector3(Float(x), Float(y), Float(z)), gloss: 0.5, in: parent)
        }
        part(SCNCylinder(radius: 0.06, height: 0.40), riceWhite,
             position: SCNVector3(0, -0.38, 0), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.09), riceWhite, position: SCNVector3(-0.08, -0.57, 0), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.09), riceWhite, position: SCNVector3(0.08, -0.57, 0), gloss: 0.6, in: parent)
        return SCNCapsule(capRadius: 0.34, height: 1.25)
    }

    /// 🍕 피자 조각: 치즈 웨지 + 노릇한 크러스트 + 페퍼로니 + 흘러내린 치즈
    private static func buildPizza(in parent: SCNNode) -> SCNGeometry {
        part(SCNPyramid(width: 0.95, height: 1.0, length: 0.20), cheeseYellow,
             position: SCNVector3(0, 0.5, 0),
             euler: SCNVector3(Float.pi, 0, 0), gloss: 0.65, in: parent)
        part(SCNCapsule(capRadius: 0.14, height: 0.98), bunTexture,
             position: SCNVector3(0, 0.52, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.3, in: parent)
        for (x, y) in [(-0.17, 0.28), (0.17, 0.28), (0.0, -0.02)] {
            part(SCNCylinder(radius: 0.115, height: 0.035),
                 UIColor(red: 0.72, green: 0.16, blue: 0.12, alpha: 1),
                 position: SCNVector3(Float(x), Float(y), 0.115),
                 euler: SCNVector3(Float.pi / 2, 0, 0), gloss: 0.6, in: parent)
        }
        for (x, y) in [(-0.10, -0.24), (0.08, -0.32)] {
            part(SCNSphere(radius: 0.07), cheeseYellow,
                 position: SCNVector3(Float(x), Float(y), 0.09),
                 scale: SCNVector3(0.8, 1.5, 0.6), gloss: 0.75, in: parent)
        }
        part(SCNSphere(radius: 0.06), leafGreen,
             position: SCNVector3(0.10, 0.10, 0.11),
             scale: SCNVector3(1, 0.4, 0.8), gloss: 0.4, in: parent)
        return SCNBox(width: 1.0, height: 1.15, length: 0.32, chamferRadius: 0.1)
    }

    /// 🍔 햄버거: 참깨 뿌린 돔 번 + 패티 + 치즈 + 양상추 프릴 + 토마토
    private static func buildBurger(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.48), bunTexture,
             position: SCNVector3(0, -0.32, 0),
             scale: SCNVector3(1, 0.42, 1), gloss: 0.3, in: parent)
        part(SCNCylinder(radius: 0.46, height: 0.17), pattyTexture,
             position: SCNVector3(0, -0.17, 0), gloss: 0.25, in: parent)
        part(SCNBox(width: 0.92, height: 0.05, length: 0.92, chamferRadius: 0.01), cheeseYellow,
             position: SCNVector3(0, -0.06, 0),
             euler: SCNVector3(0, 0.4, 0), gloss: 0.7, in: parent)
        for i in 0..<7 {
            let angle = Float(i) / 7 * 2 * Float.pi
            part(SCNSphere(radius: 0.15), leafGreen,
                 position: SCNVector3(0.42 * cos(angle), 0.0, 0.42 * sin(angle)),
                 scale: SCNVector3(1, 0.35, 1), gloss: 0.45, in: parent)
        }
        part(SCNCylinder(radius: 0.40, height: 0.08), tomatoRed,
             position: SCNVector3(0, 0.07, 0), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.50), bunTexture,
             position: SCNVector3(0, 0.14, 0),
             scale: SCNVector3(1, 0.75, 1), gloss: 0.35, in: parent)
        for i in 0..<8 {
            let angle = Float(i) / 8 * 2 * Float.pi + 0.3
            let r: Float = i % 2 == 0 ? 0.26 : 0.14
            part(SCNSphere(radius: 0.032), riceWhite,
                 position: SCNVector3(r * cos(angle), 0.14 + 0.72 * sqrt(max(0, 0.25 - Double(r * r) * 0.25)).f, r * sin(angle)),
                 scale: SCNVector3(1, 0.6, 1), gloss: 0.3, in: parent)
        }
        return SCNCylinder(radius: 0.52, height: 1.05)
    }

    /// 🌶 떡볶이: 분식 접시 + 소스 웅덩이 + 뒹구는 떡 + 어묵 + 계란 반쪽 + 고명
    private static func buildTteokbokki(in parent: SCNNode) -> SCNGeometry {
        let sauceGloss: CGFloat = 0.9
        let tteokRed = UIColor(red: 0.86, green: 0.24, blue: 0.13, alpha: 1)
        let deepSauce = UIColor(red: 0.66, green: 0.13, blue: 0.07, alpha: 1)
        // 하얀 분식 접시
        part(SCNBox(width: 0.95, height: 0.20, length: 0.68, chamferRadius: 0.06), riceWhite,
             position: SCNVector3(0, -0.30, 0), gloss: 0.4, in: parent)
        // 번들거리는 소스 웅덩이
        part(SCNSphere(radius: 0.40), deepSauce,
             position: SCNVector3(0, -0.16, 0),
             scale: SCNVector3(1.05, 0.32, 0.74), gloss: sauceGloss, in: parent)
        // 소스 입은 떡 — 자연스럽게 겹쳐 쌓기
        let tteokLayout: [(Float, Float, Float, Float)] = [
            (0.00, -0.08, -0.13, 0.15), (0.02, -0.08, 0.14, -0.25),
            (0.07, 0.09, 0.01, 0.55), (-0.11, 0.09, -0.04, -0.45),
            (0.00, 0.24, 0.02, 0.95),
        ]
        for (x, y, z, yaw) in tteokLayout {
            part(SCNCapsule(capRadius: 0.125, height: 0.60), tteokRed,
                 position: SCNVector3(x, y, z),
                 euler: SCNVector3(0, yaw, Float.pi / 2), gloss: sauceGloss, in: parent)
        }
        // 어묵 조각
        part(SCNBox(width: 0.30, height: 0.025, length: 0.22, chamferRadius: 0.01),
             UIColor(red: 0.94, green: 0.83, blue: 0.65, alpha: 1),
             position: SCNVector3(0.24, 0.18, 0.10),
             euler: SCNVector3(0.35, 0.4, 0.2), gloss: 0.5, in: parent)
        // 삶은 계란 반쪽
        part(SCNSphere(radius: 0.14), riceWhite,
             position: SCNVector3(-0.29, 0.13, 0.11),
             scale: SCNVector3(1, 0.72, 1), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.075), mustardYellow,
             position: SCNVector3(-0.29, 0.21, 0.11),
             scale: SCNVector3(1, 0.4, 1), gloss: 0.5, in: parent)
        // 참깨 + 파
        for (x, y, z) in [(0.14, 0.30, 0.05), (-0.06, 0.28, -0.10), (0.05, 0.17, 0.20), (-0.18, 0.20, -0.02)] {
            part(SCNSphere(radius: 0.022), riceWhite,
                 position: SCNVector3(Float(x), Float(y), Float(z)), gloss: 0.3, in: parent)
        }
        for (x, y, z, yaw) in [(0.10, 0.32, -0.04, 0.4), (-0.13, 0.27, 0.09, -0.7)] {
            part(SCNCapsule(capRadius: 0.025, height: 0.11), leafGreen,
                 position: SCNVector3(Float(x), Float(y), Float(z)),
                 euler: SCNVector3(Float.pi / 2, Float(yaw), 0), gloss: 0.4, in: parent)
        }
        return SCNBox(width: 1.0, height: 0.75, length: 0.72, chamferRadius: 0.15)
    }

    /// 🍜 컵라면: 브랜드 밴드 컵 + 들린 은박 뚜껑 + 면발 + 나무젓가락
    private static func buildRamen(in parent: SCNNode) -> SCNGeometry {
        let foil = UIColor(red: 0.82, green: 0.83, blue: 0.87, alpha: 1)
        part(SCNCone(topRadius: 0.38, bottomRadius: 0.28, height: 0.72), cupRamenTexture,
             position: SCNVector3(0, -0.10, 0), gloss: 0.35, in: parent)
        part(SCNTorus(ringRadius: 0.38, pipeRadius: 0.035), riceWhite,
             position: SCNVector3(0, 0.26, 0), gloss: 0.4, in: parent)
        part(SCNCylinder(radius: 0.38, height: 0.04), foil,
             position: SCNVector3(0, 0.34, -0.05),
             euler: SCNVector3(-0.38, 0, 0), gloss: 0.9, in: parent)
        part(SCNTorus(ringRadius: 0.15, pipeRadius: 0.055), cheeseYellow,
             position: SCNVector3(0, 0.30, 0.13), gloss: 0.6, in: parent)
        part(SCNTorus(ringRadius: 0.10, pipeRadius: 0.05), cheeseYellow,
             position: SCNVector3(0.09, 0.33, 0.10),
             euler: SCNVector3(0.3, 0, 0.25), gloss: 0.6, in: parent)
        let wood = UIColor(red: 0.80, green: 0.62, blue: 0.40, alpha: 1)
        part(SCNCylinder(radius: 0.026, height: 0.68), wood,
             position: SCNVector3(0.17, 0.52, 0.02),
             euler: SCNVector3(0.32, 0, -0.24), gloss: 0.3, in: parent)
        part(SCNCylinder(radius: 0.026, height: 0.68), wood,
             position: SCNVector3(0.24, 0.51, 0.00),
             euler: SCNVector3(0.32, 0, -0.33), gloss: 0.3, in: parent)
        return SCNCone(topRadius: 0.42, bottomRadius: 0.30, height: 1.0)
    }

    /// 🥟 만두: 통통한 반달 몸통 + 주름 + 노릇하게 구운 바닥
    private static func buildMandu(in parent: SCNNode) -> SCNGeometry {
        let skin = UIColor(red: 0.96, green: 0.91, blue: 0.80, alpha: 1)
        part(SCNSphere(radius: 0.34), skin,
             scale: SCNVector3(1.35, 0.80, 0.95), gloss: 0.5, in: parent)
        for (i, x) in [-0.30, -0.15, 0.0, 0.15, 0.30].enumerated() {
            part(SCNSphere(radius: 0.085), skin,
                 position: SCNVector3(Float(x), 0.24, 0),
                 euler: SCNVector3(0, Float(i) * 0.2 - 0.4, 0),
                 scale: SCNVector3(0.6, 1, 0.5), gloss: 0.5, in: parent)
        }
        part(SCNSphere(radius: 0.30), bunTexture,
             position: SCNVector3(0, -0.20, 0),
             scale: SCNVector3(1.35, 0.25, 0.92), gloss: 0.25, in: parent)
        return SCNBox(width: 1.05, height: 0.65, length: 0.72, chamferRadius: 0.25)
    }

    /// 🍘 김밥: 김 옆면 + 밥알 단면 + 속재료
    private static func buildGimbap(in parent: SCNNode) -> SCNGeometry {
        let roll = SCNCylinder(radius: 0.45, height: 0.40)
        roll.materials = [material(noriTexture, gloss: 0.55),
                          material(riceTexture, gloss: 0.3),
                          material(riceTexture, gloss: 0.3)]
        parent.addChildNode(SCNNode(geometry: roll))
        let fillings: [(UIColor, Float, Float, Float)] = [
            (UIColor(red: 0.93, green: 0.52, blue: 0.12, alpha: 1), 0.17, 0.0, 0.08),   // 당근
            (leafGreen, -0.09, 0.15, 0.08),                                              // 시금치
            (UIColor(red: 0.95, green: 0.62, blue: 0.66, alpha: 1), -0.09, -0.15, 0.09), // 햄
            (mustardYellow, 0.02, 0.0, 0.08),                                            // 계란
            (UIColor(red: 0.55, green: 0.36, blue: 0.18, alpha: 1), -0.20, 0.0, 0.06),   // 우엉
        ]
        for (color, x, z, r) in fillings {
            part(SCNSphere(radius: CGFloat(r)), color,
                 position: SCNVector3(x, 0.20, z),
                 scale: SCNVector3(1, 0.55, 1), gloss: 0.5, in: parent)
        }
        return SCNCylinder(radius: 0.46, height: 0.42)
    }

    /// 🍟 감자튀김: 벌어진 빨간 카톤 + 노릇한 감자
    private static func buildFries(in parent: SCNNode) -> SCNGeometry {
        let carton = UIColor(red: 0.80, green: 0.14, blue: 0.12, alpha: 1)
        let fry = UIColor(red: 0.95, green: 0.76, blue: 0.36, alpha: 1)
        part(SCNBox(width: 0.78, height: 0.56, length: 0.06, chamferRadius: 0.02), carton,
             position: SCNVector3(0, -0.26, 0.21),
             euler: SCNVector3(-0.10, 0, 0), gloss: 0.45, in: parent)
        part(SCNBox(width: 0.78, height: 0.56, length: 0.06, chamferRadius: 0.02), carton,
             position: SCNVector3(0, -0.26, -0.21),
             euler: SCNVector3(0.10, 0, 0), gloss: 0.45, in: parent)
        part(SCNBox(width: 0.06, height: 0.52, length: 0.40, chamferRadius: 0.02), carton,
             position: SCNVector3(0.38, -0.28, 0), gloss: 0.45, in: parent)
        part(SCNBox(width: 0.06, height: 0.52, length: 0.40, chamferRadius: 0.02), carton,
             position: SCNVector3(-0.38, -0.28, 0), gloss: 0.45, in: parent)
        part(SCNBox(width: 0.72, height: 0.06, length: 0.38, chamferRadius: 0.02), carton,
             position: SCNVector3(0, -0.52, 0), gloss: 0.45, in: parent)
        let layout: [(Float, Float, Float, Float)] = [
            (-0.27, 0.10, -0.06, 0.14), (-0.13, 0.16, 0.08, -0.06), (0.0, 0.12, -0.09, 0.02),
            (0.13, 0.18, 0.05, -0.12), (0.27, 0.09, -0.03, 0.10), (0.05, 0.22, 0.11, 0.06),
            (-0.06, 0.05, 0.13, -0.16),
        ]
        for (x, y, z, tilt) in layout {
            part(SCNBox(width: 0.11, height: 0.72, length: 0.11, chamferRadius: 0.03), fry,
                 position: SCNVector3(x, y, z),
                 euler: SCNVector3(tilt * 0.5, 0, tilt), gloss: 0.4, in: parent)
        }
        return SCNBox(width: 0.9, height: 1.15, length: 0.55, chamferRadius: 0.1)
    }

    /// 🌭 핫도그: 갈라진 번 + 그릴 자국 소시지 + 지그재그 머스타드
    private static func buildHotdog(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.21, height: 0.95), bunTexture,
             position: SCNVector3(0, -0.10, 0.12),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.3, in: parent)
        part(SCNCapsule(capRadius: 0.21, height: 0.95), bunTexture,
             position: SCNVector3(0, -0.10, -0.12),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.3, in: parent)
        part(SCNCapsule(capRadius: 0.15, height: 1.05), sausageTexture,
             position: SCNVector3(0, 0.12, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.7, in: parent)
        for i in 0..<7 {
            let x = Float(i) * 0.12 - 0.36
            let z: Float = i % 2 == 0 ? 0.05 : -0.05
            part(SCNSphere(radius: 0.05), mustardYellow,
                 position: SCNVector3(x, 0.26, z), gloss: 0.75, in: parent)
        }
        return SCNBox(width: 1.35, height: 0.6, length: 0.55, chamferRadius: 0.2)
    }

    /// 🍩 도넛: 반죽 위 딸기 글레이즈 + 흘러내림 + 스프링클
    private static func buildDonut(in parent: SCNNode) -> SCNGeometry {
        let glaze = UIColor(red: 0.94, green: 0.45, blue: 0.62, alpha: 1)
        part(SCNTorus(ringRadius: 0.36, pipeRadius: 0.20), bunTexture, gloss: 0.3, in: parent)
        part(SCNTorus(ringRadius: 0.36, pipeRadius: 0.175), glaze,
             position: SCNVector3(0, 0.07, 0), gloss: 0.85, in: parent)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi + 0.4
            part(SCNSphere(radius: 0.055), glaze,
                 position: SCNVector3(0.52 * cos(angle), -0.03, 0.52 * sin(angle)),
                 scale: SCNVector3(0.8, 1.5, 0.8), gloss: 0.85, in: parent)
        }
        let sprinkleColors: [UIColor] = [
            mustardYellow, UIColor(red: 0.35, green: 0.72, blue: 0.90, alpha: 1),
            UIColor(red: 0.45, green: 0.80, blue: 0.38, alpha: 1), riceWhite,
            UIColor(red: 0.95, green: 0.50, blue: 0.20, alpha: 1),
            UIColor(red: 0.60, green: 0.42, blue: 0.85, alpha: 1),
        ]
        for i in 0..<10 {
            let angle = Float(i) / 10 * 2 * Float.pi + Float(i % 3) * 0.2
            let r = Float(0.30 + Float(i % 2) * 0.10)
            part(SCNCapsule(capRadius: 0.028, height: 0.13), sprinkleColors[i % sprinkleColors.count],
                 position: SCNVector3(r * cos(angle), 0.21, r * sin(angle)),
                 euler: SCNVector3(Float.pi / 2, angle + 0.7, 0), gloss: 0.6, in: parent)
        }
        return SCNCylinder(radius: 0.56, height: 0.42)
    }

    /// 🥤 콜라: 물결 리본 컵 + 돔 뚜껑 + 빨대
    private static func buildCola(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.32, height: 0.80), colaTexture,
             position: SCNVector3(0, -0.06, 0), gloss: 0.5, in: parent)
        part(SCNSphere(radius: 0.34), riceWhite,
             position: SCNVector3(0, 0.36, 0),
             scale: SCNVector3(1, 0.40, 1), gloss: 0.55, in: parent)
        part(SCNTorus(ringRadius: 0.33, pipeRadius: 0.035), riceWhite,
             position: SCNVector3(0, 0.35, 0), gloss: 0.55, in: parent)
        part(SCNCylinder(radius: 0.045, height: 0.55), sauceRed,
             position: SCNVector3(0.10, 0.62, 0),
             euler: SCNVector3(0, 0, 0.28), gloss: 0.6, in: parent)
        return SCNCylinder(radius: 0.36, height: 1.28)
    }

    /// 🍙 삼각김밥: 밥알 질감 몸통 + 김 띠
    private static func buildOnigiri(in parent: SCNNode) -> SCNGeometry {
        part(SCNPyramid(width: 1.0, height: 0.85, length: 0.44), riceTexture,
             position: SCNVector3(0, -0.42, 0), gloss: 0.3, in: parent)
        part(SCNBox(width: 0.44, height: 0.42, length: 0.54, chamferRadius: 0.02), noriTexture,
             position: SCNVector3(0, -0.24, 0), gloss: 0.5, in: parent)
        return SCNBox(width: 1.05, height: 0.9, length: 0.5, chamferRadius: 0.12)
    }

    // MARK: - 확장 텍스처

    private static let lemonTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.97, green: 0.85, blue: 0.25, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.84, green: 0.70, blue: 0.12, alpha: 0.5), count: 110, minR: 1, maxR: 3)
    }

    private static let limeTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.55, green: 0.76, blue: 0.25, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.40, green: 0.60, blue: 0.14, alpha: 0.5), count: 110, minR: 1, maxR: 3)
    }

    private static let kiwiTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.55, green: 0.43, blue: 0.27, alpha: 1))
        for _ in 0..<180 {
            c.setStrokeColor(UIColor(red: 0.42, green: 0.32, blue: 0.18, alpha: 0.7).cgColor)
            c.setLineWidth(1.2)
            let x = CGFloat.random(in: 0...s.width)
            let y = CGFloat.random(in: 0...s.height)
            c.move(to: CGPoint(x: x, y: y))
            c.addLine(to: CGPoint(x: x + CGFloat.random(in: -3...3), y: y + CGFloat.random(in: 4...9)))
            c.strokePath()
        }
    }

    private static let melonTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.76, green: 0.82, blue: 0.58, alpha: 1))
        c.setStrokeColor(UIColor(red: 0.93, green: 0.94, blue: 0.85, alpha: 0.9).cgColor)
        c.setLineWidth(2.5)
        for _ in 0..<120 {
            let x = CGFloat.random(in: 0...s.width)
            let y = CGFloat.random(in: 0...s.height)
            c.move(to: CGPoint(x: x, y: y))
            c.addLine(to: CGPoint(x: x + CGFloat.random(in: -18...18), y: y + CGFloat.random(in: -18...18)))
            c.strokePath()
        }
    }

    private static let mangoTexture: UIImage = texture { c, s in
        verticalGradient(c, s,
                         top: UIColor(red: 0.88, green: 0.30, blue: 0.20, alpha: 1),
                         bottom: UIColor(red: 0.97, green: 0.72, blue: 0.20, alpha: 1))
    }

    private static let avocadoTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.22, green: 0.32, blue: 0.13, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.32, green: 0.44, blue: 0.20, alpha: 0.6), count: 140, minR: 1, maxR: 3.5)
    }

    private static let salmonTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.95, green: 0.52, blue: 0.35, alpha: 1))
        c.setStrokeColor(UIColor(white: 1, alpha: 0.75).cgColor)
        c.setLineWidth(9)
        for i in 0..<6 {
            c.move(to: CGPoint(x: CGFloat(i) * 48 - 24, y: 0))
            c.addLine(to: CGPoint(x: CGFloat(i) * 48 + 44, y: s.height))
            c.strokePath()
        }
    }

    private static let cookieTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.82, green: 0.60, blue: 0.34, alpha: 1))
        speckle(c, s, color: UIColor(red: 0.30, green: 0.17, blue: 0.09, alpha: 0.95), count: 22, minR: 4, maxR: 9)
        speckle(c, s, color: UIColor(red: 0.90, green: 0.74, blue: 0.50, alpha: 0.6), count: 40, minR: 2, maxR: 4)
    }

    private static let candyTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.99, green: 0.94, blue: 0.94, alpha: 1))
        c.setFillColor(UIColor(red: 0.93, green: 0.35, blue: 0.50, alpha: 1).cgColor)
        var x: CGFloat = -s.height
        while x < s.width + s.height {
            c.move(to: CGPoint(x: x, y: 0))
            c.addLine(to: CGPoint(x: x + 30, y: 0))
            c.addLine(to: CGPoint(x: x + 30 + s.height, y: s.height))
            c.addLine(to: CGPoint(x: x + s.height, y: s.height))
            c.closePath()
            c.fillPath()
            x += 64
        }
    }

    // MARK: - 확장 과일

    /// 🍇🫐 송이 과일 공용: 알맹이 클러스터 + 꼭지
    private static func buildBerryCluster(in parent: SCNNode, color: UIColor, radius: CGFloat) -> SCNGeometry {
        let offsets: [(Float, Float, Float)] = [
            (0, 0.18, 0), (-0.20, 0.06, 0.10), (0.20, 0.06, 0.10), (0, 0.03, -0.20),
            (-0.13, -0.18, -0.04), (0.15, -0.18, 0.06), (0, -0.36, 0.02), (-0.04, -0.05, 0.22),
        ]
        for o in offsets {
            part(SCNSphere(radius: radius), color,
                 position: SCNVector3(o.0, o.1, o.2), gloss: 0.7, in: parent)
        }
        part(SCNCylinder(radius: 0.035, height: 0.28), darkBrown,
             position: SCNVector3(0, 0.42, 0), euler: SCNVector3(0, 0, 0.2), gloss: 0.2, in: parent)
        return SCNSphere(radius: 0.5)
    }

    /// 🍑 복숭아: 발그레한 몸통 + 골 + 잎
    private static func buildPeach(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.50), UIColor(red: 0.96, green: 0.62, blue: 0.50, alpha: 1),
             scale: SCNVector3(1, 0.95, 1), gloss: 0.4, in: parent)
        part(SCNCapsule(capRadius: 0.045, height: 0.55),
             UIColor(red: 0.85, green: 0.45, blue: 0.38, alpha: 1),
             position: SCNVector3(0, 0.18, 0.44),
             euler: SCNVector3(0.5, 0, 0), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.16), leafGreen,
             position: SCNVector3(0.14, 0.48, 0),
             euler: SCNVector3(0, 0, 0.6),
             scale: SCNVector3(1, 0.25, 0.45), gloss: 0.5, in: parent)
        return SCNSphere(radius: 0.5)
    }

    /// 🍋 시트러스 공용: 타원 몸통 + 양끝 꼭지
    private static func buildCitrus(in parent: SCNNode, texture: UIImage,
                                    scaleX: Float, nubs: Bool) -> SCNGeometry {
        part(SCNSphere(radius: 0.42), texture,
             scale: SCNVector3(scaleX, 0.85, 0.85), gloss: 0.4, in: parent)
        if nubs {
            part(SCNSphere(radius: 0.09), texture, position: SCNVector3(0.42 * scaleX, 0, 0), gloss: 0.4, in: parent)
            part(SCNSphere(radius: 0.09), texture, position: SCNVector3(-0.42 * scaleX, 0, 0), gloss: 0.4, in: parent)
        }
        return SCNSphere(radius: 0.48)
    }

    /// 🍒 체리: 광택 알 2개 + 꼭지 줄기
    private static func buildCherry(in parent: SCNNode) -> SCNGeometry {
        let red = UIColor(red: 0.78, green: 0.10, blue: 0.18, alpha: 1)
        part(SCNSphere(radius: 0.27), red, position: SCNVector3(-0.22, -0.20, 0), gloss: 0.85, in: parent)
        part(SCNSphere(radius: 0.29), red, position: SCNVector3(0.22, -0.16, 0.05), gloss: 0.85, in: parent)
        part(SCNCylinder(radius: 0.028, height: 0.62), leafGreen,
             position: SCNVector3(-0.10, 0.18, 0), euler: SCNVector3(0, 0, 0.35), gloss: 0.3, in: parent)
        part(SCNCylinder(radius: 0.028, height: 0.58), leafGreen,
             position: SCNVector3(0.12, 0.20, 0.02), euler: SCNVector3(0, 0, -0.30), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.13), leafGreen,
             position: SCNVector3(0.01, 0.46, 0),
             scale: SCNVector3(1, 0.3, 0.5), gloss: 0.5, in: parent)
        return SCNSphere(radius: 0.5)
    }

    /// 🥝 키위: 갈색 솜털 타원
    private static func buildKiwi(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.42), kiwiTexture,
             scale: SCNVector3(1.2, 0.9, 0.9), gloss: 0.15, in: parent)
        return SCNSphere(radius: 0.46)
    }

    /// 🍐 배: 황금빛 몸통 + 꼭지
    private static func buildPear(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.50), UIColor(red: 0.88, green: 0.74, blue: 0.44, alpha: 1),
             gloss: 0.35, in: parent)
        part(SCNSphere(radius: 0.50), UIColor(red: 0.88, green: 0.74, blue: 0.44, alpha: 1),
             position: SCNVector3(0, 0.05, 0), scale: SCNVector3(0.98, 1, 0.98), gloss: 0.35, in: parent)
        part(SCNCylinder(radius: 0.04, height: 0.28), darkBrown,
             position: SCNVector3(0, 0.56, 0), euler: SCNVector3(0, 0, 0.2), gloss: 0.2, in: parent)
        return SCNSphere(radius: 0.52)
    }

    /// 🥭 망고: 붉은빛에서 노랑으로 물드는 타원
    private static func buildMango(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.44), mangoTexture,
             euler: SCNVector3(0, 0, 0.25),
             scale: SCNVector3(1.2, 0.95, 0.85), gloss: 0.55, in: parent)
        return SCNSphere(radius: 0.5)
    }

    /// 🍈 멜론: 그물 무늬 + T자 꼭지
    private static func buildMelon(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.52), melonTexture, gloss: 0.3, in: parent)
        part(SCNCylinder(radius: 0.035, height: 0.20),
             UIColor(red: 0.55, green: 0.55, blue: 0.35, alpha: 1),
             position: SCNVector3(0, 0.58, 0), gloss: 0.2, in: parent)
        part(SCNCylinder(radius: 0.03, height: 0.24),
             UIColor(red: 0.55, green: 0.55, blue: 0.35, alpha: 1),
             position: SCNVector3(0, 0.66, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.2, in: parent)
        return SCNSphere(radius: 0.54)
    }

    /// 🟠 감: 납작한 주황 몸통 + 십자 꼭지잎
    private static func buildPersimmon(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.50), UIColor(red: 0.94, green: 0.50, blue: 0.14, alpha: 1),
             scale: SCNVector3(1, 0.78, 1), gloss: 0.6, in: parent)
        for i in 0..<4 {
            let angle = Float(i) / 4 * 2 * Float.pi
            part(SCNSphere(radius: 0.14),
                 UIColor(red: 0.42, green: 0.52, blue: 0.24, alpha: 1),
                 position: SCNVector3(0.14 * cos(angle), 0.38, 0.14 * sin(angle)),
                 euler: SCNVector3(0, -angle, 0),
                 scale: SCNVector3(1, 0.25, 0.55), gloss: 0.35, in: parent)
        }
        part(SCNCylinder(radius: 0.035, height: 0.14), darkBrown,
             position: SCNVector3(0, 0.44, 0), gloss: 0.2, in: parent)
        return SCNSphere(radius: 0.5)
    }

    /// 🟣 자두: 진자주 광택 몸통 + 골
    private static func buildPlum(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.46), UIColor(red: 0.48, green: 0.16, blue: 0.36, alpha: 1),
             gloss: 0.85, in: parent)
        part(SCNCapsule(capRadius: 0.04, height: 0.5),
             UIColor(red: 0.36, green: 0.10, blue: 0.27, alpha: 1),
             position: SCNVector3(0, 0.14, 0.40),
             euler: SCNVector3(0.5, 0, 0), gloss: 0.6, in: parent)
        part(SCNCylinder(radius: 0.03, height: 0.18), darkBrown,
             position: SCNVector3(0, 0.50, 0), gloss: 0.2, in: parent)
        return SCNSphere(radius: 0.48)
    }

    /// 무화과: 보랏빛 물방울 몸통 + 목
    private static func buildFig(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.44), UIColor(red: 0.42, green: 0.22, blue: 0.38, alpha: 1),
             position: SCNVector3(0, -0.08, 0),
             scale: SCNVector3(1, 1.05, 1), gloss: 0.4, in: parent)
        part(SCNCone(topRadius: 0.05, bottomRadius: 0.24, height: 0.4),
             UIColor(red: 0.50, green: 0.32, blue: 0.30, alpha: 1),
             position: SCNVector3(0, 0.42, 0), gloss: 0.3, in: parent)
        return SCNSphere(radius: 0.5)
    }

    /// 석류: 붉은 몸통 + 왕관
    private static func buildPomegranate(in parent: SCNNode) -> SCNGeometry {
        let red = UIColor(red: 0.75, green: 0.14, blue: 0.16, alpha: 1)
        part(SCNSphere(radius: 0.48), red, gloss: 0.5, in: parent)
        part(SCNCylinder(radius: 0.14, height: 0.14), red,
             position: SCNVector3(0, 0.50, 0), gloss: 0.5, in: parent)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi
            part(SCNCone(topRadius: 0, bottomRadius: 0.05, height: 0.14), red,
                 position: SCNVector3(0.10 * cos(angle), 0.60, 0.10 * sin(angle)),
                 euler: SCNVector3(0.3 * sin(angle), 0, 0.3 * cos(angle)), gloss: 0.5, in: parent)
        }
        return SCNSphere(radius: 0.5)
    }

    /// 🐉 용과: 핑크 몸통 + 초록 비늘 잎
    private static func buildDragonfruit(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.44), UIColor(red: 0.92, green: 0.28, blue: 0.48, alpha: 1),
             scale: SCNVector3(1, 1.18, 1), gloss: 0.5, in: parent)
        let scales: [(Float, Float, Float)] = [
            (0.30, 0.30, 0.20), (-0.28, 0.24, -0.18), (0.10, -0.06, 0.40),
            (-0.34, -0.14, 0.16), (0.30, -0.26, -0.16), (0.0, 0.44, -0.24),
        ]
        for (x, y, z) in scales {
            let len = sqrt(x * x + y * y + z * z)
            part(SCNCone(topRadius: 0, bottomRadius: 0.09, height: 0.26),
                 UIColor(red: 0.55, green: 0.78, blue: 0.40, alpha: 1),
                 position: SCNVector3(x * 1.25, y * 1.25, z * 1.25),
                 euler: SCNVector3(atan2(z / len, y / len), 0, -atan2(x / len, y / len)),
                 gloss: 0.4, in: parent)
        }
        return SCNSphere(radius: 0.52)
    }

    /// 🥑 아보카도: 서양배 모양 + 오돌토돌 껍질
    private static func buildAvocado(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.42), avocadoTexture,
             position: SCNVector3(0, -0.12, 0), gloss: 0.25, in: parent)
        part(SCNSphere(radius: 0.30), avocadoTexture,
             position: SCNVector3(0, 0.26, 0), gloss: 0.25, in: parent)
        part(SCNCylinder(radius: 0.035, height: 0.14), darkBrown,
             position: SCNVector3(0, 0.58, 0), euler: SCNVector3(0, 0, 0.3), gloss: 0.2, in: parent)
        return SCNCapsule(capRadius: 0.42, height: 1.15)
    }

    /// 🍅 토마토: 광택 몸통 + 별 모양 꼭지
    private static func buildTomato(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.48), UIColor(red: 0.88, green: 0.20, blue: 0.14, alpha: 1),
             scale: SCNVector3(1, 0.88, 1), gloss: 0.85, in: parent)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi
            part(SCNSphere(radius: 0.13), leafGreen,
                 position: SCNVector3(0.15 * cos(angle), 0.38, 0.15 * sin(angle)),
                 euler: SCNVector3(0, -angle, 0),
                 scale: SCNVector3(1, 0.22, 0.4), gloss: 0.4, in: parent)
        }
        return SCNSphere(radius: 0.48)
    }

    /// 파파야: 주황-초록 긴 타원
    private static func buildPapaya(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.40), mangoTexture,
             scale: SCNVector3(0.95, 1.35, 0.9), gloss: 0.4, in: parent)
        part(SCNCylinder(radius: 0.04, height: 0.14), leafGreen,
             position: SCNVector3(0, 0.60, 0), gloss: 0.3, in: parent)
        return SCNCapsule(capRadius: 0.40, height: 1.15)
    }

    /// 🍊 한라봉: 오렌지 몸통 + 볼록 튀어나온 꼭지
    private static func buildHallabong(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.48), orangeTexture, gloss: 0.4, in: parent)
        part(SCNSphere(radius: 0.17), orangeTexture,
             position: SCNVector3(0, 0.46, 0), gloss: 0.4, in: parent)
        part(SCNCylinder(radius: 0.035, height: 0.12), leafGreen,
             position: SCNVector3(0, 0.62, 0), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.15), leafGreen,
             position: SCNVector3(0.13, 0.60, 0),
             euler: SCNVector3(0, 0, 0.6),
             scale: SCNVector3(1, 0.25, 0.45), gloss: 0.5, in: parent)
        return SCNSphere(radius: 0.52)
    }

    // MARK: - 확장 음식

    /// 🍣 연어 초밥: 밥 위에 줄무늬 연어
    private static func buildSushi(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.36), riceTexture,
             position: SCNVector3(0, -0.12, 0),
             scale: SCNVector3(1.35, 0.62, 0.95), gloss: 0.3, in: parent)
        part(SCNBox(width: 0.92, height: 0.13, length: 0.52, chamferRadius: 0.06), salmonTexture,
             position: SCNVector3(0, 0.14, 0),
             euler: SCNVector3(0, 0, 0.06), gloss: 0.7, in: parent)
        return SCNBox(width: 1.0, height: 0.6, length: 0.65, chamferRadius: 0.2)
    }

    /// 🐟 붕어빵: 노릇한 물고기 모양 + 꼬리
    private static func buildBungeoppang(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.36), bunTexture,
             position: SCNVector3(0.08, 0, 0),
             scale: SCNVector3(1.5, 0.72, 0.5), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.20), bunTexture,
             position: SCNVector3(-0.52, 0.05, 0),
             euler: SCNVector3(0, 0, 0.5),
             scale: SCNVector3(1.1, 0.75, 0.35), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.20), bunTexture,
             position: SCNVector3(-0.52, -0.05, 0),
             euler: SCNVector3(0, 0, -0.5),
             scale: SCNVector3(1.1, 0.75, 0.35), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.045), darkBrown,
             position: SCNVector3(0.44, 0.12, 0.16), gloss: 0.3, in: parent)
        return SCNBox(width: 1.35, height: 0.6, length: 0.45, chamferRadius: 0.15)
    }

    /// 🫓 호떡: 노릇한 원반 + 흑설탕 시럽
    private static func buildHotteok(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.44, height: 0.18), bunTexture, gloss: 0.35, in: parent)
        part(SCNSphere(radius: 0.22),
             UIColor(red: 0.45, green: 0.26, blue: 0.10, alpha: 1),
             position: SCNVector3(0, 0.09, 0),
             scale: SCNVector3(1, 0.3, 1), gloss: 0.9, in: parent)
        return SCNCylinder(radius: 0.46, height: 0.24)
    }

    /// 🍢 핫도그(콘도그): 튀김옷 몸통 + 설탕 + 케첩·머스타드 + 나무 스틱
    private static func buildCorndog(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.22, height: 0.85), crispyTexture,
             position: SCNVector3(0, 0.14, 0), gloss: 0.45, in: parent)
        for (x, y) in [(-0.02, 0.42), (0.05, 0.18), (-0.06, -0.04)] {
            part(SCNSphere(radius: 0.05), mustardYellow,
                 position: SCNVector3(Float(x), Float(y), 0.20), gloss: 0.75, in: parent)
        }
        for (x, y) in [(0.07, 0.32), (-0.05, 0.08)] {
            part(SCNSphere(radius: 0.05), sauceRed,
                 position: SCNVector3(Float(x), Float(y), 0.20), gloss: 0.75, in: parent)
        }
        part(SCNCylinder(radius: 0.045, height: 0.45),
             UIColor(red: 0.80, green: 0.62, blue: 0.40, alpha: 1),
             position: SCNVector3(0, -0.48, 0), gloss: 0.3, in: parent)
        return SCNCapsule(capRadius: 0.24, height: 1.35)
    }

    /// 🍤 새우튀김: 굽은 튀김 몸통 + 빨간 꼬리
    private static func buildFriedShrimp(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.19, height: 0.55), crispyTexture,
             position: SCNVector3(-0.12, 0.02, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 - 0.35), gloss: 0.45, in: parent)
        part(SCNCapsule(capRadius: 0.17, height: 0.45), crispyTexture,
             position: SCNVector3(0.26, 0.14, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 + 0.55), gloss: 0.45, in: parent)
        let tail = UIColor(red: 0.88, green: 0.35, blue: 0.25, alpha: 1)
        part(SCNSphere(radius: 0.13), tail,
             position: SCNVector3(-0.46, -0.14, 0),
             euler: SCNVector3(0, 0, 0.6),
             scale: SCNVector3(1.3, 0.5, 0.3), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.11), tail,
             position: SCNVector3(-0.50, -0.02, 0.06),
             euler: SCNVector3(0, 0.4, 0.9),
             scale: SCNVector3(1.3, 0.5, 0.3), gloss: 0.6, in: parent)
        return SCNBox(width: 1.1, height: 0.7, length: 0.45, chamferRadius: 0.15)
    }

    /// 🥧 에그타르트: 페이스트리 컵 + 노른자 커스터드
    private static func buildEggTart(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.44, bottomRadius: 0.32, height: 0.22), bunTexture,
             position: SCNVector3(0, -0.06, 0), gloss: 0.3, in: parent)
        part(SCNTorus(ringRadius: 0.42, pipeRadius: 0.06), bunTexture,
             position: SCNVector3(0, 0.05, 0), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.34), mustardYellow,
             position: SCNVector3(0, 0.06, 0),
             scale: SCNVector3(1, 0.28, 1), gloss: 0.85, in: parent)
        part(SCNSphere(radius: 0.06), UIColor(red: 0.55, green: 0.32, blue: 0.10, alpha: 1),
             position: SCNVector3(0.12, 0.14, 0.08),
             scale: SCNVector3(1, 0.4, 1), gloss: 0.5, in: parent)
        return SCNCylinder(radius: 0.48, height: 0.35)
    }

    /// 🥐 크루아상: 겹겹이 말린 노릇한 몸통
    private static func buildCroissant(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.20, height: 0.55), bunTexture,
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.35, in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 0.45), bunTexture,
             position: SCNVector3(-0.36, 0.12, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 + 0.65), gloss: 0.35, in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 0.45), bunTexture,
             position: SCNVector3(0.36, 0.12, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 - 0.65), gloss: 0.35, in: parent)
        part(SCNCapsule(capRadius: 0.11, height: 0.3), bunTexture,
             position: SCNVector3(-0.58, 0.30, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 + 1.1), gloss: 0.35, in: parent)
        part(SCNCapsule(capRadius: 0.11, height: 0.3), bunTexture,
             position: SCNVector3(0.58, 0.30, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 - 1.1), gloss: 0.35, in: parent)
        return SCNBox(width: 1.35, height: 0.65, length: 0.45, chamferRadius: 0.15)
    }

    /// 🥞 팬케이크: 3단 스택 + 버터 + 흐르는 시럽
    private static func buildPancake(in parent: SCNNode) -> SCNGeometry {
        for (i, y) in [-0.20, -0.05, 0.10].enumerated() {
            part(SCNCylinder(radius: CGFloat(0.44 - Float(i) * 0.02), height: 0.14), bunTexture,
                 position: SCNVector3(Float(i % 2) * 0.03, Float(y), 0), gloss: 0.3, in: parent)
        }
        part(SCNSphere(radius: 0.30),
             UIColor(red: 0.62, green: 0.36, blue: 0.12, alpha: 1),
             position: SCNVector3(0, 0.18, 0),
             scale: SCNVector3(1.2, 0.25, 1.2), gloss: 0.9, in: parent)
        part(SCNBox(width: 0.18, height: 0.10, length: 0.18, chamferRadius: 0.02), mustardYellow,
             position: SCNVector3(0, 0.28, 0),
             euler: SCNVector3(0, 0.4, 0), gloss: 0.6, in: parent)
        return SCNCylinder(radius: 0.48, height: 0.62)
    }

    /// 🍦 아이스크림: 와플 콘 + 크림 2단 + 체리
    private static func buildIcecream(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.28, bottomRadius: 0.02, height: 0.55), pineappleTexture,
             position: SCNVector3(0, -0.35, 0), gloss: 0.3, in: parent)
        let cream = UIColor(red: 0.98, green: 0.95, blue: 0.88, alpha: 1)
        part(SCNSphere(radius: 0.30), cream, position: SCNVector3(0, 0.05, 0), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.21), cream, position: SCNVector3(0, 0.33, 0), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.13), cream, position: SCNVector3(0, 0.52, 0), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.07), UIColor(red: 0.80, green: 0.12, blue: 0.20, alpha: 1),
             position: SCNVector3(0, 0.64, 0), gloss: 0.85, in: parent)
        return SCNCapsule(capRadius: 0.30, height: 1.3)
    }

    /// 🧁 컵케이크: 주름 컵 + 프로스팅 소용돌이 + 체리
    private static func buildCupcake(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.36, bottomRadius: 0.26, height: 0.35),
             UIColor(red: 0.92, green: 0.55, blue: 0.65, alpha: 1),
             position: SCNVector3(0, -0.28, 0), gloss: 0.4, in: parent)
        let frosting = UIColor(red: 0.98, green: 0.92, blue: 0.88, alpha: 1)
        part(SCNSphere(radius: 0.34), frosting,
             position: SCNVector3(0, 0.0, 0), scale: SCNVector3(1, 0.6, 1), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.26), frosting, position: SCNVector3(0, 0.18, 0), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.16), frosting, position: SCNVector3(0, 0.38, 0), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.07), UIColor(red: 0.80, green: 0.12, blue: 0.20, alpha: 1),
             position: SCNVector3(0, 0.52, 0), gloss: 0.85, in: parent)
        return SCNCylinder(radius: 0.40, height: 1.0)
    }

    /// 🍫 초콜릿: 조각 홈이 파인 다크 초콜릿 바
    private static func buildChocolate(in parent: SCNNode) -> SCNGeometry {
        let choco = UIColor(red: 0.32, green: 0.18, blue: 0.10, alpha: 1)
        part(SCNBox(width: 0.88, height: 0.14, length: 0.58, chamferRadius: 0.03), choco,
             gloss: 0.6, in: parent)
        for row in 0..<2 {
            for col in 0..<3 {
                part(SCNBox(width: 0.22, height: 0.08, length: 0.20, chamferRadius: 0.03), choco,
                     position: SCNVector3(Float(col) * 0.27 - 0.27, 0.10, Float(row) * 0.26 - 0.13),
                     gloss: 0.6, in: parent)
            }
        }
        return SCNBox(width: 0.92, height: 0.28, length: 0.62, chamferRadius: 0.05)
    }

    /// 🍪 쿠키: 초코칩 박힌 원반
    private static func buildCookie(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.45, height: 0.15), cookieTexture, gloss: 0.25, in: parent)
        let chip = UIColor(red: 0.28, green: 0.16, blue: 0.08, alpha: 1)
        for (x, z) in [(-0.20, 0.10), (0.16, -0.18), (0.05, 0.24), (0.28, 0.10), (-0.10, -0.22)] {
            part(SCNSphere(radius: 0.06), chip,
                 position: SCNVector3(Float(x), 0.08, Float(z)),
                 scale: SCNVector3(1, 0.6, 1), gloss: 0.5, in: parent)
        }
        return SCNCylinder(radius: 0.47, height: 0.22)
    }

    /// 🍬 사탕: 줄무늬 알맹이 + 양쪽 포장 꼬임
    private static func buildCandy(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.32), candyTexture, gloss: 0.8, in: parent)
        let wrap = UIColor(red: 0.93, green: 0.42, blue: 0.55, alpha: 1)
        for sign: Float in [-1, 1] {
            part(SCNCone(topRadius: 0.02, bottomRadius: 0.13, height: 0.28), wrap,
                 position: SCNVector3(sign * 0.45, 0, 0),
                 euler: SCNVector3(0, 0, sign * -Float.pi / 2), gloss: 0.6, in: parent)
            part(SCNSphere(radius: 0.09), wrap,
                 position: SCNVector3(sign * 0.60, 0, 0),
                 scale: SCNVector3(0.7, 1, 1), gloss: 0.6, in: parent)
        }
        return SCNBox(width: 1.3, height: 0.65, length: 0.65, chamferRadius: 0.25)
    }

    /// 🍭 롤리팝: 줄무늬 원반 + 흰 막대
    private static func buildLollipop(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.36, height: 0.14), candyTexture,
             position: SCNVector3(0, 0.28, 0),
             euler: SCNVector3(Float.pi / 2, 0, 0), gloss: 0.85, in: parent)
        part(SCNTorus(ringRadius: 0.36, pipeRadius: 0.07), candyTexture,
             position: SCNVector3(0, 0.28, 0),
             euler: SCNVector3(Float.pi / 2, 0, 0), gloss: 0.85, in: parent)
        part(SCNCylinder(radius: 0.045, height: 0.65), riceWhite,
             position: SCNVector3(0, -0.30, 0), gloss: 0.4, in: parent)
        return SCNCapsule(capRadius: 0.40, height: 1.3)
    }

    /// 🍡 닭꼬치: 노릇한 고기 큐브 3개 + 꼬치 + 파
    private static func buildSkewer(in parent: SCNNode) -> SCNGeometry {
        for (i, y) in [-0.28, 0.02, 0.32].enumerated() {
            part(SCNBox(width: 0.30, height: 0.26, length: 0.28, chamferRadius: 0.08), crispyTexture,
                 position: SCNVector3(0, Float(y), 0),
                 euler: SCNVector3(0, Float(i) * 0.5, 0), gloss: 0.55, in: parent)
        }
        part(SCNCapsule(capRadius: 0.04, height: 0.12), leafGreen,
             position: SCNVector3(0.10, 0.17, 0.12),
             euler: SCNVector3(Float.pi / 2, 0.4, 0), gloss: 0.4, in: parent)
        part(SCNCylinder(radius: 0.035, height: 1.15),
             UIColor(red: 0.80, green: 0.62, blue: 0.40, alpha: 1),
             position: SCNVector3(0, -0.05, 0), gloss: 0.3, in: parent)
        return SCNCapsule(capRadius: 0.24, height: 1.3)
    }

    /// 🍳 계란후라이: 흰자 웅덩이 + 탱글한 노른자
    private static func buildFriedEgg(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.42), riceWhite,
             scale: SCNVector3(1.25, 0.18, 1.05), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.36), riceWhite,
             position: SCNVector3(0.22, 0, 0.14),
             scale: SCNVector3(1.1, 0.20, 0.95), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.19), mustardYellow,
             position: SCNVector3(-0.04, 0.08, -0.02),
             scale: SCNVector3(1, 0.65, 1), gloss: 0.9, in: parent)
        return SCNCylinder(radius: 0.56, height: 0.3)
    }

    /// 🍞 식빵: 둥근 윗면의 토스트
    private static func buildToast(in parent: SCNNode) -> SCNGeometry {
        part(SCNBox(width: 0.82, height: 0.72, length: 0.20, chamferRadius: 0.06), bunTexture,
             position: SCNVector3(0, -0.12, 0), gloss: 0.3, in: parent)
        part(SCNCylinder(radius: 0.41, height: 0.20), bunTexture,
             position: SCNVector3(0, 0.24, 0),
             euler: SCNVector3(Float.pi / 2, 0, 0), gloss: 0.3, in: parent)
        part(SCNBox(width: 0.62, height: 0.52, length: 0.06, chamferRadius: 0.04),
             UIColor(red: 0.97, green: 0.88, blue: 0.68, alpha: 1),
             position: SCNVector3(0, -0.06, 0.10), gloss: 0.25, in: parent)
        return SCNBox(width: 0.88, height: 1.0, length: 0.28, chamferRadius: 0.08)
    }

    /// 🥪 샌드위치: 삼각 식빵 2장 사이 양상추·햄·치즈
    private static func buildSandwich(in parent: SCNNode) -> SCNGeometry {
        part(SCNPyramid(width: 0.95, height: 0.80, length: 0.16), bunTexture,
             position: SCNVector3(0, -0.40, -0.14), gloss: 0.3, in: parent)
        part(SCNPyramid(width: 0.95, height: 0.80, length: 0.16), bunTexture,
             position: SCNVector3(0, -0.40, 0.14), gloss: 0.3, in: parent)
        part(SCNPyramid(width: 0.90, height: 0.74, length: 0.07), leafGreen,
             position: SCNVector3(0, -0.38, -0.03), gloss: 0.45, in: parent)
        part(SCNPyramid(width: 0.88, height: 0.72, length: 0.06),
             UIColor(red: 0.95, green: 0.62, blue: 0.66, alpha: 1),
             position: SCNVector3(0, -0.38, 0.03), gloss: 0.5, in: parent)
        part(SCNPyramid(width: 0.86, height: 0.70, length: 0.05), cheeseYellow,
             position: SCNVector3(0, -0.38, 0.08), gloss: 0.6, in: parent)
        return SCNBox(width: 1.0, height: 0.85, length: 0.45, chamferRadius: 0.1)
    }

    /// 🍧 팥빙수: 하늘색 그릇 + 눈꽃 얼음 산 + 팥 + 과일 토핑
    private static func buildShavedIce(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.44, bottomRadius: 0.26, height: 0.35),
             UIColor(red: 0.55, green: 0.75, blue: 0.90, alpha: 1),
             position: SCNVector3(0, -0.30, 0), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.38), riceWhite,
             position: SCNVector3(0, 0.05, 0),
             scale: SCNVector3(1, 0.85, 1), gloss: 0.35, in: parent)
        part(SCNSphere(radius: 0.24),
             UIColor(red: 0.48, green: 0.22, blue: 0.18, alpha: 1),
             position: SCNVector3(0, 0.32, 0),
             scale: SCNVector3(1, 0.45, 1), gloss: 0.6, in: parent)
        part(SCNSphere(radius: 0.08), UIColor(red: 0.80, green: 0.12, blue: 0.20, alpha: 1),
             position: SCNVector3(0.10, 0.44, 0.06), gloss: 0.8, in: parent)
        part(SCNSphere(radius: 0.06), mustardYellow,
             position: SCNVector3(-0.12, 0.42, -0.04), gloss: 0.6, in: parent)
        return SCNCylinder(radius: 0.46, height: 0.95)
    }

    /// 🧋 버블티: 밀크티 컵 + 바닥 타피오카 펄 + 굵은 빨대
    private static func buildBoba(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.30, height: 0.72),
             UIColor(red: 0.91, green: 0.80, blue: 0.66, alpha: 1),
             position: SCNVector3(0, -0.02, 0), gloss: 0.55, in: parent)
        let pearl = UIColor(red: 0.22, green: 0.15, blue: 0.12, alpha: 1)
        for (x, z) in [(-0.16, 0.14), (0.0, 0.20), (0.16, 0.13), (-0.08, 0.19), (0.08, 0.18), (-0.19, 0.05), (0.20, 0.04)] {
            part(SCNSphere(radius: 0.055), pearl,
                 position: SCNVector3(Float(x), -0.30, Float(z)), gloss: 0.8, in: parent)
        }
        part(SCNSphere(radius: 0.31), riceWhite,
             position: SCNVector3(0, 0.36, 0),
             scale: SCNVector3(1, 0.35, 1), gloss: 0.55, in: parent)
        part(SCNCylinder(radius: 0.07, height: 0.55),
             UIColor(red: 0.90, green: 0.50, blue: 0.62, alpha: 1),
             position: SCNVector3(0.06, 0.58, 0),
             euler: SCNVector3(0, 0, 0.18), gloss: 0.6, in: parent)
        return SCNCylinder(radius: 0.34, height: 1.25)
    }

    // MARK: - 각진 아이템 텍스처

    /// 팝콘 상자: 흰 바탕 + 빨간 세로 줄무늬
    private static let popcornTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1))
        c.setFillColor(UIColor(red: 0.82, green: 0.15, blue: 0.13, alpha: 1).cgColor)
        var x: CGFloat = 0
        while x < s.width {
            c.fill(CGRect(x: x, y: 0, width: 26, height: s.height))
            x += 52
        }
    }

    /// 와플: 노릇한 바탕 + 격자 홈
    private static let waffleTexture: UIImage = texture { c, s in
        fillBase(c, s, UIColor(red: 0.88, green: 0.65, blue: 0.34, alpha: 1))
        c.setStrokeColor(UIColor(red: 0.68, green: 0.45, blue: 0.20, alpha: 0.9).cgColor)
        c.setLineWidth(10)
        var p: CGFloat = 32
        while p < s.width {
            c.move(to: CGPoint(x: p, y: 0)); c.addLine(to: CGPoint(x: p, y: s.height))
            c.move(to: CGPoint(x: 0, y: p)); c.addLine(to: CGPoint(x: s.width, y: p))
            c.strokePath()
            p += 64
        }
    }

    // MARK: - 각진 아이템 (신규 12종)

    /// 🧀 치즈 웨지: 옆으로 누운 노란 삼각 + 치즈 구멍
    private static func buildCheese(in parent: SCNNode) -> SCNGeometry {
        let cheddar = UIColor(red: 0.97, green: 0.76, blue: 0.22, alpha: 1)
        let hole = UIColor(red: 0.82, green: 0.60, blue: 0.14, alpha: 1)
        part(SCNPyramid(width: 0.62, height: 0.95, length: 0.55), cheddar,
             position: SCNVector3(-0.47, 0, 0),
             euler: SCNVector3(0, 0, -Float.pi / 2), gloss: 0.45, in: parent)
        for (x, y, z) in [(-0.25, 0.12, 0.16), (0.05, -0.08, 0.14), (-0.38, -0.14, 0.12)] {
            part(SCNSphere(radius: 0.075), hole,
                 position: SCNVector3(Float(x), Float(y), Float(z)),
                 scale: SCNVector3(1, 1, 0.4), gloss: 0.3, in: parent)
        }
        return SCNBox(width: 1.05, height: 0.65, length: 0.6, chamferRadius: 0.06)
    }

    /// 🥛 우유팩: 흰 몸통 + 지붕 접힘 + 파란 띠
    private static func buildMilk(in parent: SCNNode) -> SCNGeometry {
        let blue = UIColor(red: 0.30, green: 0.52, blue: 0.85, alpha: 1)
        part(SCNBox(width: 0.55, height: 0.78, length: 0.55, chamferRadius: 0.02), riceWhite,
             position: SCNVector3(0, -0.12, 0), gloss: 0.35, in: parent)
        part(SCNPyramid(width: 0.57, height: 0.32, length: 0.57), riceWhite,
             position: SCNVector3(0, 0.27, 0), gloss: 0.35, in: parent)
        part(SCNBox(width: 0.57, height: 0.20, length: 0.57, chamferRadius: 0.02), blue,
             position: SCNVector3(0, -0.02, 0), gloss: 0.35, in: parent)
        part(SCNBox(width: 0.10, height: 0.14, length: 0.03, chamferRadius: 0.01), riceWhite,
             position: SCNVector3(0, 0.50, 0), gloss: 0.35, in: parent)
        return SCNBox(width: 0.6, height: 1.15, length: 0.6, chamferRadius: 0.05)
    }

    /// 🧃 주스팩: 작은 주황 팩 + 빨대
    private static func buildJuiceBox(in parent: SCNNode) -> SCNGeometry {
        let orange = UIColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1)
        part(SCNBox(width: 0.52, height: 0.72, length: 0.34, chamferRadius: 0.03), orange,
             position: SCNVector3(0, -0.06, 0), gloss: 0.4, in: parent)
        part(SCNBox(width: 0.40, height: 0.34, length: 0.36, chamferRadius: 0.02), riceWhite,
             position: SCNVector3(0, -0.02, 0), gloss: 0.4, in: parent)
        part(SCNSphere(radius: 0.10), orange,
             position: SCNVector3(0, -0.02, 0.19),
             scale: SCNVector3(1, 1, 0.3), gloss: 0.5, in: parent)
        part(SCNCylinder(radius: 0.035, height: 0.42), riceWhite,
             position: SCNVector3(0.16, 0.44, 0),
             euler: SCNVector3(0, 0, 0.35), gloss: 0.4, in: parent)
        return SCNBox(width: 0.58, height: 1.0, length: 0.4, chamferRadius: 0.05)
    }

    /// 🍰 조각 케이크: 2단 큐브 + 크림 + 딸기
    private static func buildCakeSlice(in parent: SCNNode) -> SCNGeometry {
        let sponge = UIColor(red: 0.98, green: 0.93, blue: 0.80, alpha: 1)
        let pinkCream = UIColor(red: 0.97, green: 0.70, blue: 0.76, alpha: 1)
        part(SCNBox(width: 0.62, height: 0.30, length: 0.62, chamferRadius: 0.02), sponge,
             position: SCNVector3(0, -0.24, 0), gloss: 0.3, in: parent)
        part(SCNBox(width: 0.62, height: 0.12, length: 0.62, chamferRadius: 0.01), pinkCream,
             position: SCNVector3(0, -0.03, 0), gloss: 0.5, in: parent)
        part(SCNBox(width: 0.62, height: 0.30, length: 0.62, chamferRadius: 0.02), sponge,
             position: SCNVector3(0, 0.18, 0), gloss: 0.3, in: parent)
        part(SCNSphere(radius: 0.20), riceWhite,
             position: SCNVector3(0, 0.38, 0),
             scale: SCNVector3(1, 0.5, 1), gloss: 0.55, in: parent)
        part(SCNSphere(radius: 0.10), UIColor(red: 0.85, green: 0.15, blue: 0.22, alpha: 1),
             position: SCNVector3(0, 0.50, 0), gloss: 0.85, in: parent)
        return SCNBox(width: 0.68, height: 1.05, length: 0.68, chamferRadius: 0.05)
    }

    /// 🍉 수박 조각: 위로 뾰족한 빨간 삼각 + 초록 껍질 + 씨
    private static func buildWatermelonSlice(in parent: SCNNode) -> SCNGeometry {
        part(SCNPyramid(width: 0.95, height: 0.90, length: 0.30),
             UIColor(red: 0.94, green: 0.30, blue: 0.30, alpha: 1),
             position: SCNVector3(0, -0.38, 0), gloss: 0.55, in: parent)
        part(SCNBox(width: 0.98, height: 0.07, length: 0.34, chamferRadius: 0.01), riceWhite,
             position: SCNVector3(0, -0.40, 0), gloss: 0.4, in: parent)
        part(SCNBox(width: 0.98, height: 0.13, length: 0.34, chamferRadius: 0.02),
             UIColor(red: 0.20, green: 0.50, blue: 0.24, alpha: 1),
             position: SCNVector3(0, -0.50, 0), gloss: 0.5, in: parent)
        for (x, y) in [(-0.14, -0.10), (0.12, -0.16), (0.0, 0.10), (-0.05, -0.28)] {
            part(SCNSphere(radius: 0.035), UIColor(red: 0.14, green: 0.10, blue: 0.08, alpha: 1),
                 position: SCNVector3(Float(x), Float(y), 0.14),
                 scale: SCNVector3(0.8, 1.2, 0.4), gloss: 0.5, in: parent)
        }
        return SCNBox(width: 1.0, height: 1.05, length: 0.38, chamferRadius: 0.08)
    }

    /// 🍨 아이스바: 둥근 모서리 바 + 한입 + 나무 스틱
    private static func buildPopsicle(in parent: SCNNode) -> SCNGeometry {
        let soda = UIColor(red: 0.45, green: 0.78, blue: 0.92, alpha: 1)
        part(SCNBox(width: 0.52, height: 0.80, length: 0.26, chamferRadius: 0.13), soda,
             position: SCNVector3(0, 0.16, 0), gloss: 0.7, in: parent)
        part(SCNSphere(radius: 0.11),
             UIColor(red: 0.30, green: 0.62, blue: 0.80, alpha: 1),
             position: SCNVector3(0.24, 0.48, 0),
             scale: SCNVector3(1, 1, 0.5), gloss: 0.5, in: parent)
        part(SCNBox(width: 0.12, height: 0.42, length: 0.06, chamferRadius: 0.03),
             UIColor(red: 0.80, green: 0.62, blue: 0.40, alpha: 1),
             position: SCNVector3(0, -0.42, 0), gloss: 0.3, in: parent)
        return SCNBox(width: 0.58, height: 1.25, length: 0.32, chamferRadius: 0.1)
    }

    /// 🧇 와플: 격자 사각판 + 버터 + 시럽
    private static func buildWaffle(in parent: SCNNode) -> SCNGeometry {
        part(SCNBox(width: 0.88, height: 0.16, length: 0.88, chamferRadius: 0.04), waffleTexture,
             gloss: 0.35, in: parent)
        for row in 0..<3 {
            for col in 0..<3 {
                part(SCNBox(width: 0.20, height: 0.08, length: 0.20, chamferRadius: 0.03), waffleTexture,
                     position: SCNVector3(Float(col) * 0.27 - 0.27, 0.10, Float(row) * 0.27 - 0.27),
                     gloss: 0.35, in: parent)
            }
        }
        part(SCNBox(width: 0.18, height: 0.10, length: 0.18, chamferRadius: 0.02), mustardYellow,
             position: SCNVector3(0, 0.20, 0),
             euler: SCNVector3(0, 0.4, 0), gloss: 0.6, in: parent)
        return SCNBox(width: 0.92, height: 0.35, length: 0.92, chamferRadius: 0.06)
    }

    /// 🥧 파이 조각: 노릇한 웨지 + 크러스트 + 딸기잼
    private static func buildPieSlice(in parent: SCNNode) -> SCNGeometry {
        part(SCNPyramid(width: 0.85, height: 0.95, length: 0.30), bunTexture,
             position: SCNVector3(0, 0.47, 0),
             euler: SCNVector3(Float.pi, 0, 0), gloss: 0.3, in: parent)
        part(SCNCapsule(capRadius: 0.13, height: 0.88), bunTexture,
             position: SCNVector3(0, 0.48, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.3, in: parent)
        for (x, y) in [(-0.12, 0.20), (0.10, 0.05), (0.0, -0.18)] {
            part(SCNSphere(radius: 0.07), sauceRed,
                 position: SCNVector3(Float(x), Float(y), 0.14),
                 scale: SCNVector3(1, 1, 0.5), gloss: 0.8, in: parent)
        }
        return SCNBox(width: 0.9, height: 1.1, length: 0.36, chamferRadius: 0.08)
    }

    /// 🥡 테이크아웃 박스: 흰 상자 + 빨간 줄 + 손잡이
    private static func buildTakeout(in parent: SCNNode) -> SCNGeometry {
        part(SCNBox(width: 0.62, height: 0.70, length: 0.52, chamferRadius: 0.03), riceWhite,
             position: SCNVector3(0, -0.08, 0), gloss: 0.35, in: parent)
        part(SCNBox(width: 0.64, height: 0.06, length: 0.54, chamferRadius: 0.01), riceWhite,
             position: SCNVector3(0, 0.28, 0), gloss: 0.35, in: parent)
        part(SCNBox(width: 0.05, height: 0.34, length: 0.54, chamferRadius: 0.01), sauceRed,
             position: SCNVector3(0, -0.10, 0),
             scale: SCNVector3(1, 1, 1.01), gloss: 0.35, in: parent)
        part(SCNTorus(ringRadius: 0.20, pipeRadius: 0.025),
             UIColor(red: 0.65, green: 0.65, blue: 0.68, alpha: 1),
             position: SCNVector3(0, 0.40, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), gloss: 0.7, in: parent)
        return SCNBox(width: 0.68, height: 1.0, length: 0.58, chamferRadius: 0.05)
    }

    /// 🍿 팝콘: 줄무늬 상자 + 넘치는 팝콘
    private static func buildPopcorn(in parent: SCNNode) -> SCNGeometry {
        let kernel = UIColor(red: 0.98, green: 0.92, blue: 0.75, alpha: 1)
        part(SCNBox(width: 0.66, height: 0.72, length: 0.46, chamferRadius: 0.03), popcornTexture,
             position: SCNVector3(0, -0.20, 0), gloss: 0.35, in: parent)
        let puffs: [(Float, Float, Float, Float)] = [
            (0, 0.28, 0, 0.16), (-0.22, 0.22, 0.08, 0.13), (0.22, 0.24, -0.06, 0.13),
            (-0.10, 0.40, -0.10, 0.12), (0.12, 0.42, 0.10, 0.12), (0.0, 0.52, 0.0, 0.11),
        ]
        for (x, y, z, r) in puffs {
            part(SCNSphere(radius: CGFloat(r)), kernel,
                 position: SCNVector3(x, y, z), gloss: 0.3, in: parent)
        }
        return SCNBox(width: 0.72, height: 1.15, length: 0.52, chamferRadius: 0.06)
    }

    /// 🧈 버터: 황금빛 사각 덩어리 + 윗장
    private static func buildButter(in parent: SCNNode) -> SCNGeometry {
        let gold = UIColor(red: 0.97, green: 0.85, blue: 0.45, alpha: 1)
        part(SCNBox(width: 0.78, height: 0.34, length: 0.50, chamferRadius: 0.06), gold,
             position: SCNVector3(0, -0.09, 0), gloss: 0.55, in: parent)
        part(SCNBox(width: 0.46, height: 0.18, length: 0.34, chamferRadius: 0.05),
             UIColor(red: 0.99, green: 0.92, blue: 0.62, alpha: 1),
             position: SCNVector3(-0.05, 0.14, 0),
             euler: SCNVector3(0, 0.25, 0), gloss: 0.55, in: parent)
        return SCNBox(width: 0.82, height: 0.62, length: 0.55, chamferRadius: 0.08)
    }

    /// 🥕 당근: 주황 원뿔 + 초록 줄기
    private static func buildCarrot(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.26, bottomRadius: 0.02, height: 1.0),
             UIColor(red: 0.95, green: 0.52, blue: 0.12, alpha: 1),
             position: SCNVector3(0, -0.10, 0), gloss: 0.4, in: parent)
        for (dx, tilt) in [(-0.08, 0.35), (0.0, 0.0), (0.08, -0.35)] {
            part(SCNCapsule(capRadius: 0.05, height: 0.36), leafGreen,
                 position: SCNVector3(Float(dx), 0.52, 0),
                 euler: SCNVector3(0, 0, Float(tilt)), gloss: 0.4, in: parent)
        }
        return SCNCapsule(capRadius: 0.28, height: 1.3)
    }
}

private extension Double {
    /// Float 변환 축약 (버거 참깨 배치 계산용)
    var f: Float { Float(self) }
}
