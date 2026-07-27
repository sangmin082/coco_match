import SceneKit
import UIKit

/// 아이템을 실제 사물 모양의 3D 컴포지트 노드로 만든다. (야식 테마 12종)
/// 각 아이템은 여러 프리미티브(구/캡슐/원뿔/원기둥 등)의 조합이며,
/// 물리 충돌은 전체 크기를 근사하는 단순 도형(collision)으로 계산해 성능과 안정성을 확보한다.
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

    private static func material(_ color: UIColor, transparency: CGFloat = 1) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = color
        m.specular.contents = UIColor(white: 1, alpha: 0.35)
        m.transparency = transparency
        return m
    }

    @discardableResult
    private static func part(_ geometry: SCNGeometry, _ color: UIColor,
                             position: SCNVector3 = SCNVector3(0, 0, 0),
                             euler: SCNVector3 = SCNVector3(0, 0, 0),
                             transparency: CGFloat = 1,
                             in parent: SCNNode) -> SCNNode {
        geometry.materials = [material(color, transparency: transparency)]
        let n = SCNNode(geometry: geometry)
        n.position = position
        n.eulerAngles = euler
        parent.addChildNode(n)
        return n
    }

    // MARK: - Palette

    private static let friedBrown = UIColor(red: 0.80, green: 0.52, blue: 0.25, alpha: 1)
    private static let bunTan = UIColor(red: 0.93, green: 0.72, blue: 0.42, alpha: 1)
    private static let sauceRed = UIColor(red: 0.88, green: 0.22, blue: 0.15, alpha: 1)
    private static let cheeseYellow = UIColor(red: 0.98, green: 0.82, blue: 0.35, alpha: 1)
    private static let riceWhite = UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 1)
    private static let seaweedBlack = UIColor(red: 0.12, green: 0.14, blue: 0.10, alpha: 1)
    private static let coconutBrown = UIColor(red: 0.45, green: 0.31, blue: 0.21, alpha: 1)
    private static let darkBrown = UIColor(red: 0.28, green: 0.19, blue: 0.12, alpha: 1)
    private static let leafGreen = UIColor(red: 0.27, green: 0.63, blue: 0.34, alpha: 1)

    // MARK: - Fruits (초반 레벨)

    /// 🥥 코코넛: 갈색 구 + 위쪽 반점 3개
    private static func buildCoconut(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.55), coconutBrown, in: parent)
        let spots: [SCNVector3] = [
            SCNVector3(0.0, 0.50, 0.25),
            SCNVector3(-0.22, 0.48, 0.12),
            SCNVector3(0.22, 0.48, 0.12),
        ]
        for p in spots {
            part(SCNSphere(radius: 0.09), darkBrown, position: p, in: parent)
        }
        return SCNSphere(radius: 0.55)
    }

    /// 🍎 사과: 빨간 구 + 꼭지 + 잎
    private static func buildApple(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.50), UIColor(red: 0.88, green: 0.18, blue: 0.20, alpha: 1), in: parent)
        part(SCNCylinder(radius: 0.045, height: 0.24), darkBrown,
             position: SCNVector3(0, 0.56, 0),
             euler: SCNVector3(0, 0, 0.15), in: parent)
        part(SCNCapsule(capRadius: 0.07, height: 0.30), leafGreen,
             position: SCNVector3(0.15, 0.56, 0),
             euler: SCNVector3(0, 0, 1.1), in: parent)
        return SCNSphere(radius: 0.52)
    }

    /// 🍌 바나나: 캡슐 3개를 호 모양으로 배치 + 양끝 꼭지
    private static func buildBanana(in parent: SCNNode) -> SCNGeometry {
        let yellow = UIColor(red: 1.0, green: 0.84, blue: 0.30, alpha: 1)
        part(SCNCapsule(capRadius: 0.17, height: 0.62), yellow,
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 0.55), yellow,
             position: SCNVector3(-0.40, 0.14, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 + 0.6), in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 0.55), yellow,
             position: SCNVector3(0.40, 0.14, 0),
             euler: SCNVector3(0, 0, Float.pi / 2 - 0.6), in: parent)
        part(SCNSphere(radius: 0.07), darkBrown, position: SCNVector3(-0.62, 0.30, 0), in: parent)
        part(SCNSphere(radius: 0.07), darkBrown, position: SCNVector3(0.62, 0.30, 0), in: parent)
        return SCNBox(width: 1.4, height: 0.6, length: 0.4, chamferRadius: 0.15)
    }

    /// 🍓 딸기: 붉은 역원뿔 + 씨앗 + 꼭지잎
    private static func buildStrawberry(in parent: SCNNode) -> SCNGeometry {
        let red = UIColor(red: 0.89, green: 0.20, blue: 0.27, alpha: 1)
        part(SCNCone(topRadius: 0.45, bottomRadius: 0.06, height: 0.85), red, in: parent)
        for i in 0..<6 {
            let angle = Float(i) / 6 * 2 * Float.pi
            let y: Float = i % 2 == 0 ? 0.12 : -0.10
            let r: Float = i % 2 == 0 ? 0.34 : 0.26
            part(SCNSphere(radius: 0.035), riceWhite,
                 position: SCNVector3(r * cos(angle), y, r * sin(angle)), in: parent)
        }
        for i in 0..<3 {
            let angle = Float(i) / 3 * 2 * Float.pi
            part(SCNCone(topRadius: 0, bottomRadius: 0.09, height: 0.28), leafGreen,
                 position: SCNVector3(0.14 * cos(angle), 0.48, 0.14 * sin(angle)),
                 euler: SCNVector3(0.4 * sin(angle), 0, 0.4 * cos(angle)), in: parent)
        }
        return SCNCone(topRadius: 0.45, bottomRadius: 0.06, height: 0.85)
    }

    /// 🍊 오렌지: 주황 구 + 꼭지 + 잎
    private static func buildOrange(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.50), UIColor(red: 0.98, green: 0.60, blue: 0.15, alpha: 1), in: parent)
        part(SCNCylinder(radius: 0.05, height: 0.14), leafGreen,
             position: SCNVector3(0, 0.54, 0), in: parent)
        part(SCNCapsule(capRadius: 0.08, height: 0.32), leafGreen,
             position: SCNVector3(0.17, 0.52, 0),
             euler: SCNVector3(0, 0, 1.2), in: parent)
        return SCNSphere(radius: 0.52)
    }

    /// 🍉 수박: 초록 줄무늬 텍스처 구
    private static func buildWatermelon(in parent: SCNNode) -> SCNGeometry {
        let sphere = SCNSphere(radius: 0.55)
        let m = SCNMaterial()
        m.diffuse.contents = watermelonTexture
        m.specular.contents = UIColor(white: 1, alpha: 0.35)
        sphere.materials = [m]
        let n = SCNNode(geometry: sphere)
        parent.addChildNode(n)
        return SCNSphere(radius: 0.55)
    }

    private static let watermelonTexture: UIImage = {
        let size = CGSize(width: 256, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(red: 0.28, green: 0.66, blue: 0.33, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor(red: 0.15, green: 0.44, blue: 0.21, alpha: 1).setFill()
            for i in 0..<8 {
                ctx.fill(CGRect(x: CGFloat(i) * 32 + 9, y: 0, width: 14, height: 128))
            }
        }
    }()

    /// 🍍 파인애플: 노란 캡슐 몸통 + 초록 잎
    private static func buildPineapple(in parent: SCNNode) -> SCNGeometry {
        let body = UIColor(red: 0.95, green: 0.72, blue: 0.25, alpha: 1)
        part(SCNCapsule(capRadius: 0.40, height: 1.0), body,
             position: SCNVector3(0, -0.08, 0), in: parent)
        let leafPositions: [(SCNVector3, SCNVector3)] = [
            (SCNVector3(0.10, 0.55, 0), SCNVector3(0, 0, -0.35)),
            (SCNVector3(-0.10, 0.55, 0), SCNVector3(0, 0, 0.35)),
            (SCNVector3(0, 0.55, 0.10), SCNVector3(0.35, 0, 0)),
            (SCNVector3(0, 0.60, -0.05), SCNVector3(-0.15, 0, 0)),
        ]
        for (p, e) in leafPositions {
            part(SCNCone(topRadius: 0, bottomRadius: 0.10, height: 0.42), leafGreen,
                 position: p, euler: e, in: parent)
        }
        return SCNCapsule(capRadius: 0.42, height: 1.25)
    }

    // MARK: - Snacks (야식)

    /// 🍗 치킨 다리: 튀김옷 몸통 + 흰 뼈 + 뼈끝 혹 2개
    private static func buildChicken(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.32, height: 0.72), friedBrown,
             position: SCNVector3(0, 0.16, 0), in: parent)
        part(SCNSphere(radius: 0.20), friedBrown,
             position: SCNVector3(0.14, 0.38, 0.08), in: parent)
        part(SCNCylinder(radius: 0.07, height: 0.38), riceWhite,
             position: SCNVector3(0, -0.40, 0), in: parent)
        part(SCNSphere(radius: 0.10), riceWhite,
             position: SCNVector3(-0.09, -0.58, 0), in: parent)
        part(SCNSphere(radius: 0.10), riceWhite,
             position: SCNVector3(0.09, -0.58, 0), in: parent)
        return SCNCapsule(capRadius: 0.33, height: 1.25)
    }

    /// 🍕 피자 조각: 치즈색 웨지 + 크러스트 + 페퍼로니
    private static func buildPizza(in parent: SCNNode) -> SCNGeometry {
        // 아래로 뾰족한 조각 (밑변이 위)
        part(SCNPyramid(width: 0.95, height: 1.0, length: 0.22), cheeseYellow,
             position: SCNVector3(0, 0.5, 0),
             euler: SCNVector3(Float.pi, 0, 0), in: parent)
        part(SCNCapsule(capRadius: 0.13, height: 0.95), bunTan,
             position: SCNVector3(0, 0.5, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        part(SCNSphere(radius: 0.10), sauceRed, position: SCNVector3(-0.16, 0.42, 0.10), in: parent)
        part(SCNSphere(radius: 0.10), sauceRed, position: SCNVector3(0.16, 0.42, 0.10), in: parent)
        return SCNBox(width: 1.0, height: 1.15, length: 0.32, chamferRadius: 0.1)
    }

    /// 🍔 햄버거: 빵-패티-치즈-양상추-빵 스택 + 참깨
    private static func buildBurger(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.46, height: 0.16), bunTan,
             position: SCNVector3(0, -0.30, 0), in: parent)
        part(SCNCylinder(radius: 0.48, height: 0.16),
             UIColor(red: 0.45, green: 0.27, blue: 0.15, alpha: 1),
             position: SCNVector3(0, -0.15, 0), in: parent)
        part(SCNBox(width: 0.95, height: 0.06, length: 0.95, chamferRadius: 0.01), cheeseYellow,
             position: SCNVector3(0, -0.05, 0),
             euler: SCNVector3(0, 0.4, 0), in: parent)
        part(SCNCylinder(radius: 0.49, height: 0.09),
             UIColor(red: 0.45, green: 0.75, blue: 0.30, alpha: 1),
             position: SCNVector3(0, 0.03, 0), in: parent)
        part(SCNSphere(radius: 0.48), bunTan,
             position: SCNVector3(0, 0.08, 0), in: parent)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi
            part(SCNSphere(radius: 0.035), riceWhite,
                 position: SCNVector3(0.24 * cos(angle), 0.48, 0.24 * sin(angle)), in: parent)
        }
        return SCNCylinder(radius: 0.52, height: 1.0)
    }

    /// 🌶 떡볶이: 빨간 소스 입힌 떡 3가닥 + 참깨 + 파
    private static func buildTteokbokki(in parent: SCNNode) -> SCNGeometry {
        let tteok = UIColor(red: 0.90, green: 0.27, blue: 0.16, alpha: 1)
        part(SCNCapsule(capRadius: 0.15, height: 0.75), tteok,
             position: SCNVector3(0, 0.10, 0.05),
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        part(SCNCapsule(capRadius: 0.15, height: 0.72), tteok,
             position: SCNVector3(0.05, -0.12, -0.08),
             euler: SCNVector3(0, 0.5, Float.pi / 2), in: parent)
        part(SCNCapsule(capRadius: 0.15, height: 0.70), tteok,
             position: SCNVector3(-0.06, 0.30, -0.04),
             euler: SCNVector3(0, -0.4, Float.pi / 2), in: parent)
        part(SCNSphere(radius: 0.03), riceWhite, position: SCNVector3(0.15, 0.28, 0.12), in: parent)
        part(SCNSphere(radius: 0.03), riceWhite, position: SCNVector3(-0.18, 0.10, 0.16), in: parent)
        part(SCNCapsule(capRadius: 0.045, height: 0.22),
             UIColor(red: 0.35, green: 0.70, blue: 0.30, alpha: 1),
             position: SCNVector3(0.20, 0.42, 0),
             euler: SCNVector3(0, 0, 0.9), in: parent)
        return SCNBox(width: 1.05, height: 0.75, length: 0.6, chamferRadius: 0.2)
    }

    /// 🍜 컵라면: 위가 넓은 컵 + 빨간 띠 + 은박 뚜껑(살짝 열림) + 삐져나온 면발
    private static func buildRamen(in parent: SCNNode) -> SCNGeometry {
        let cup = UIColor(red: 0.97, green: 0.94, blue: 0.88, alpha: 1)
        let foil = UIColor(red: 0.82, green: 0.83, blue: 0.86, alpha: 1)
        // 위가 넓은 컵 몸통
        part(SCNCone(topRadius: 0.38, bottomRadius: 0.28, height: 0.72), cup,
             position: SCNVector3(0, -0.10, 0), in: parent)
        // 빨간 브랜드 띠
        part(SCNCone(topRadius: 0.365, bottomRadius: 0.325, height: 0.22), sauceRed,
             position: SCNVector3(0, -0.05, 0), in: parent)
        // 컵 상단 테두리
        part(SCNTorus(ringRadius: 0.38, pipeRadius: 0.035), cup,
             position: SCNVector3(0, 0.26, 0), in: parent)
        // 살짝 들린 은박 뚜껑
        part(SCNCylinder(radius: 0.38, height: 0.04), foil,
             position: SCNVector3(0, 0.34, -0.04),
             euler: SCNVector3(-0.35, 0, 0), in: parent)
        // 틈으로 삐져나온 면발
        part(SCNTorus(ringRadius: 0.16, pipeRadius: 0.06), cheeseYellow,
             position: SCNVector3(0, 0.30, 0.12), in: parent)
        return SCNCone(topRadius: 0.42, bottomRadius: 0.30, height: 1.0)
    }

    /// 🥟 만두: 통통한 베이지 몸통 + 주름 3개
    private static func buildMandu(in parent: SCNNode) -> SCNGeometry {
        let skin = UIColor(red: 0.96, green: 0.90, blue: 0.78, alpha: 1)
        part(SCNCapsule(capRadius: 0.30, height: 0.85), skin,
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        for dx: Float in [-0.20, 0, 0.20] {
            part(SCNSphere(radius: 0.09), skin,
                 position: SCNVector3(dx, 0.26, 0), in: parent)
        }
        return SCNBox(width: 1.1, height: 0.62, length: 0.62, chamferRadius: 0.25)
    }

    /// 🍘 김밥 한 조각: 김(옆면) + 밥(윗면) + 속재료
    private static func buildGimbap(in parent: SCNNode) -> SCNGeometry {
        let roll = SCNCylinder(radius: 0.45, height: 0.38)
        roll.materials = [material(seaweedBlack), material(riceWhite), material(riceWhite)]
        let rollNode = SCNNode(geometry: roll)
        parent.addChildNode(rollNode)
        let fillings: [(UIColor, Float, Float)] = [
            (UIColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1), 0.16, 0),        // 당근
            (UIColor(red: 0.30, green: 0.65, blue: 0.25, alpha: 1), -0.09, 0.14),    // 시금치
            (UIColor(red: 0.98, green: 0.65, blue: 0.70, alpha: 1), -0.09, -0.14),   // 햄
            (cheeseYellow, 0.02, 0),                                                  // 계란
        ]
        for (color, x, z) in fillings {
            part(SCNSphere(radius: 0.08), color,
                 position: SCNVector3(x, 0.20, z), in: parent)
        }
        return SCNCylinder(radius: 0.46, height: 0.40)
    }

    /// 🍟 감자튀김: 빨간 상자 + 노란 감자 5개
    private static func buildFries(in parent: SCNNode) -> SCNGeometry {
        part(SCNBox(width: 0.75, height: 0.55, length: 0.42, chamferRadius: 0.04), sauceRed,
             position: SCNVector3(0, -0.28, 0), in: parent)
        let fry = cheeseYellow
        let xs: [Float] = [-0.24, -0.12, 0, 0.12, 0.24]
        for (i, x) in xs.enumerated() {
            part(SCNBox(width: 0.12, height: 0.72, length: 0.12, chamferRadius: 0.03), fry,
                 position: SCNVector3(x, 0.12, Float(i % 2) * 0.12 - 0.06),
                 euler: SCNVector3(0, 0, Float(i - 2) * 0.08), in: parent)
        }
        return SCNBox(width: 0.85, height: 1.15, length: 0.5, chamferRadius: 0.1)
    }

    /// 🌭 핫도그: 빵 + 소시지 + 머스타드
    private static func buildHotdog(in parent: SCNNode) -> SCNGeometry {
        part(SCNCapsule(capRadius: 0.25, height: 0.95), bunTan,
             position: SCNVector3(0, -0.08, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        part(SCNCapsule(capRadius: 0.16, height: 1.05),
             UIColor(red: 0.72, green: 0.30, blue: 0.18, alpha: 1),
             position: SCNVector3(0, 0.14, 0),
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        for dx: Float in [-0.26, 0, 0.26] {
            part(SCNSphere(radius: 0.06), cheeseYellow,
                 position: SCNVector3(dx, 0.30, 0), in: parent)
        }
        return SCNBox(width: 1.35, height: 0.6, length: 0.55, chamferRadius: 0.2)
    }

    /// 🍩 도넛: 분홍 글레이즈 토러스 + 스프링클
    private static func buildDonut(in parent: SCNNode) -> SCNGeometry {
        part(SCNTorus(ringRadius: 0.36, pipeRadius: 0.19),
             UIColor(red: 0.95, green: 0.55, blue: 0.70, alpha: 1), in: parent)
        let colors: [UIColor] = [
            cheeseYellow,
            UIColor(red: 0.35, green: 0.75, blue: 0.90, alpha: 1),
            UIColor(red: 0.45, green: 0.80, blue: 0.35, alpha: 1),
            riceWhite,
            UIColor(red: 0.95, green: 0.45, blue: 0.20, alpha: 1),
            UIColor(red: 0.60, green: 0.40, blue: 0.85, alpha: 1),
        ]
        for (i, color) in colors.enumerated() {
            let angle = Float(i) / 6 * 2 * Float.pi
            part(SCNCapsule(capRadius: 0.03, height: 0.14), color,
                 position: SCNVector3(0.36 * cos(angle), 0.16, 0.36 * sin(angle)),
                 euler: SCNVector3(Float.pi / 2, angle + 0.6, 0), in: parent)
        }
        return SCNCylinder(radius: 0.56, height: 0.42)
    }

    /// 🥤 콜라: 빨간 컵 + 흰 뚜껑 + 빨대
    private static func buildCola(in parent: SCNNode) -> SCNGeometry {
        part(SCNCylinder(radius: 0.32, height: 0.78), sauceRed,
             position: SCNVector3(0, -0.05, 0), in: parent)
        part(SCNSphere(radius: 0.11), riceWhite,
             position: SCNVector3(0, -0.05, 0.28), in: parent)
        part(SCNCylinder(radius: 0.34, height: 0.09), riceWhite,
             position: SCNVector3(0, 0.38, 0), in: parent)
        part(SCNCylinder(radius: 0.05, height: 0.5), riceWhite,
             position: SCNVector3(0.10, 0.62, 0),
             euler: SCNVector3(0, 0, 0.28), in: parent)
        return SCNCylinder(radius: 0.36, height: 1.25)
    }

    /// 🍙 삼각김밥: 흰 삼각 주먹밥 + 김 띠
    private static func buildOnigiri(in parent: SCNNode) -> SCNGeometry {
        part(SCNPyramid(width: 1.0, height: 0.85, length: 0.42), riceWhite,
             position: SCNVector3(0, -0.42, 0), in: parent)
        part(SCNBox(width: 0.42, height: 0.42, length: 0.52, chamferRadius: 0.02), seaweedBlack,
             position: SCNVector3(0, -0.24, 0), in: parent)
        return SCNBox(width: 1.05, height: 0.9, length: 0.5, chamferRadius: 0.12)
    }
}
