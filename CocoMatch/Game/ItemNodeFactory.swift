import SceneKit
import UIKit

/// 아이템을 실물처럼 보이는 3D 컴포지트 노드로 만든다. (과일 + 야식 19종)
/// - 절차적 텍스처(튀김옷 얼룩, 빵 그라데이션, 줄무늬 등)로 질감을 입히고
/// - 스케일된 구(타원체)로 자유로운 형태를 만들고
/// - 소스는 광택, 빵은 매트 — 재질 광택을 분리해 "맛있어 보이는" 룩을 만든다.
/// 물리 충돌은 전체 크기를 근사하는 단순 도형(collision)으로 계산한다.
enum ItemNodeFactory {

    static func makeNode(for type: ItemType) -> SCNNode {
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
        }

        // 아이템을 큼직하게 (화면 가로에 4개 남짓)
        let itemScale: CGFloat = 1.25
        node.scale = SCNVector3(Float(itemScale), Float(itemScale), Float(itemScale))
        let shape = SCNPhysicsShape(geometry: collision,
                                    options: [SCNPhysicsShape.Option.scale: itemScale])
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        body.mass = 1
        body.restitution = 0.5
        body.friction = 0.6
        body.rollingFriction = 0.3
        body.angularDamping = 0.45
        body.damping = 0.1
        node.physicsBody = body
        return node
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
}

private extension Double {
    /// Float 변환 축약 (버거 참깨 배치 계산용)
    var f: Float { Float(self) }
}
