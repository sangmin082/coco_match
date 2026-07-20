import SceneKit
import UIKit

/// 아이템을 실제 사물 모양의 3D 컴포지트 노드로 만든다.
/// 각 아이템은 여러 프리미티브(구/캡슐/원뿔 등)의 조합이며,
/// 물리 충돌은 전체 크기를 근사하는 단순 도형(collision)으로 계산해 성능과 안정성을 확보한다.
enum ItemNodeFactory {

    static func makeNode(for type: ItemType) -> SCNNode {
        let node = SCNNode()
        node.name = type.rawValue

        let collision: SCNGeometry
        switch type {
        case .coconut: collision = buildCoconut(in: node)
        case .banana: collision = buildBanana(in: node)
        case .pineapple: collision = buildPineapple(in: node)
        case .strawberry: collision = buildStrawberry(in: node)
        case .watermelon: collision = buildWatermelon(in: node)
        case .shell: collision = buildShell(in: node)
        case .starfish: collision = buildStarfish(in: node)
        case .crab: collision = buildCrab(in: node)
        case .hibiscus: collision = buildHibiscus(in: node)
        case .fish: collision = buildFish(in: node)
        case .icecream: collision = buildIcecream(in: node)
        case .cocktail: collision = buildCocktail(in: node)
        }

        let body = SCNPhysicsBody(type: .dynamic,
                                  shape: SCNPhysicsShape(geometry: collision, options: nil))
        body.mass = 1
        body.restitution = 0.5
        body.friction = 0.6
        body.rollingFriction = 0.3
        body.angularDamping = 0.3
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

    private static let brown = UIColor(red: 0.45, green: 0.31, blue: 0.21, alpha: 1)
    private static let darkBrown = UIColor(red: 0.28, green: 0.19, blue: 0.12, alpha: 1)
    private static let leafGreen = UIColor(red: 0.27, green: 0.63, blue: 0.34, alpha: 1)

    // MARK: - Items

    /// 🥥 코코넛: 갈색 구 + 위쪽 반점 3개
    private static func buildCoconut(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.55), brown, in: parent)
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

    /// 🍍 파인애플: 노란 캡슐 몸통 + 초록 잎 4개
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

    /// 🍓 딸기: 붉은 역원뿔 + 씨앗 + 꼭지잎
    private static func buildStrawberry(in parent: SCNNode) -> SCNGeometry {
        let red = UIColor(red: 0.89, green: 0.20, blue: 0.27, alpha: 1)
        part(SCNCone(topRadius: 0.45, bottomRadius: 0.06, height: 0.85), red, in: parent)
        for i in 0..<6 {
            let angle = Float(i) / 6 * 2 * Float.pi
            let y: Float = i % 2 == 0 ? 0.12 : -0.10
            let r: Float = i % 2 == 0 ? 0.34 : 0.26
            part(SCNSphere(radius: 0.035), UIColor(white: 0.98, alpha: 1),
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

    /// 🐚 조개: 크림색 구 + 진주
    private static func buildShell(in parent: SCNNode) -> SCNGeometry {
        part(SCNSphere(radius: 0.50), UIColor(red: 0.96, green: 0.87, blue: 0.80, alpha: 1), in: parent)
        part(SCNSphere(radius: 0.16), UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1),
             position: SCNVector3(0, 0.48, 0), in: parent)
        part(SCNSphere(radius: 0.11), UIColor(red: 0.90, green: 0.78, blue: 0.70, alpha: 1),
             position: SCNVector3(0.40, -0.28, 0), in: parent)
        return SCNSphere(radius: 0.50)
    }

    /// ⭐ 불가사리: 중심 구 + 팔 5개
    private static func buildStarfish(in parent: SCNNode) -> SCNGeometry {
        let orange = UIColor(red: 1.0, green: 0.62, blue: 0.20, alpha: 1)
        part(SCNSphere(radius: 0.24), orange, in: parent)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi
            let dir = SCNVector3(sin(angle), 0, cos(angle))
            part(SCNCapsule(capRadius: 0.13, height: 0.62), orange,
                 position: SCNVector3(dir.x * 0.36, 0, dir.z * 0.36),
                 euler: SCNVector3(Float.pi / 2, angle, 0), in: parent)
        }
        return SCNCylinder(radius: 0.58, height: 0.32)
    }

    /// 🦀 게: 붉은 몸통 + 집게 2개 + 눈
    private static func buildCrab(in parent: SCNNode) -> SCNGeometry {
        let red = UIColor(red: 0.91, green: 0.32, blue: 0.25, alpha: 1)
        part(SCNSphere(radius: 0.42), red, in: parent)
        part(SCNSphere(radius: 0.20), red, position: SCNVector3(-0.50, 0.06, 0.24), in: parent)
        part(SCNSphere(radius: 0.20), red, position: SCNVector3(0.50, 0.06, 0.24), in: parent)
        for dx: Float in [-0.15, 0.15] {
            part(SCNSphere(radius: 0.09), .white, position: SCNVector3(dx, 0.36, 0.24), in: parent)
            part(SCNSphere(radius: 0.045), .black, position: SCNVector3(dx, 0.38, 0.31), in: parent)
        }
        return SCNBox(width: 1.3, height: 0.8, length: 0.95, chamferRadius: 0.25)
    }

    /// 🌺 히비스커스: 분홍 꽃잎 5장 + 노란 수술
    private static func buildHibiscus(in parent: SCNNode) -> SCNGeometry {
        let pink = UIColor(red: 0.96, green: 0.45, blue: 0.65, alpha: 1)
        for i in 0..<5 {
            let angle = Float(i) / 5 * 2 * Float.pi
            part(SCNSphere(radius: 0.27), pink,
                 position: SCNVector3(0.33 * sin(angle), 0, 0.33 * cos(angle)), in: parent)
        }
        part(SCNSphere(radius: 0.16), UIColor(red: 1.0, green: 0.85, blue: 0.30, alpha: 1),
             position: SCNVector3(0, 0.14, 0), in: parent)
        return SCNCylinder(radius: 0.58, height: 0.52)
    }

    /// 🐠 열대어: 파란 몸통 + 꼬리 + 눈
    private static func buildFish(in parent: SCNNode) -> SCNGeometry {
        let blue = UIColor(red: 0.30, green: 0.65, blue: 0.92, alpha: 1)
        let darkBlue = UIColor(red: 0.18, green: 0.45, blue: 0.75, alpha: 1)
        part(SCNCapsule(capRadius: 0.32, height: 0.95), blue,
             euler: SCNVector3(0, 0, Float.pi / 2), in: parent)
        part(SCNCone(topRadius: 0, bottomRadius: 0.24, height: 0.34), darkBlue,
             position: SCNVector3(-0.58, 0, 0),
             euler: SCNVector3(0, 0, -Float.pi / 2), in: parent)
        part(SCNCone(topRadius: 0, bottomRadius: 0.14, height: 0.26), darkBlue,
             position: SCNVector3(0.02, 0.34, 0), in: parent)
        part(SCNSphere(radius: 0.08), .white, position: SCNVector3(0.32, 0.08, 0.26), in: parent)
        part(SCNSphere(radius: 0.04), .black, position: SCNVector3(0.34, 0.08, 0.32), in: parent)
        return SCNBox(width: 1.35, height: 0.7, length: 0.65, chamferRadius: 0.2)
    }

    /// 🍦 아이스크림: 콘 + 크림 2단 + 체리
    private static func buildIcecream(in parent: SCNNode) -> SCNGeometry {
        part(SCNCone(topRadius: 0.30, bottomRadius: 0.03, height: 0.60),
             UIColor(red: 0.85, green: 0.64, blue: 0.40, alpha: 1),
             position: SCNVector3(0, -0.32, 0), in: parent)
        let cream = UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1)
        part(SCNSphere(radius: 0.32), cream, position: SCNVector3(0, 0.10, 0), in: parent)
        part(SCNSphere(radius: 0.22), cream, position: SCNVector3(0, 0.40, 0), in: parent)
        part(SCNSphere(radius: 0.09), UIColor(red: 0.85, green: 0.15, blue: 0.25, alpha: 1),
             position: SCNVector3(0, 0.60, 0), in: parent)
        return SCNCapsule(capRadius: 0.32, height: 1.3)
    }

    /// 🍹 칵테일: 반투명 잔 + 빨대 + 체리
    private static func buildCocktail(in parent: SCNNode) -> SCNGeometry {
        let teal = UIColor(red: 0.35, green: 0.80, blue: 0.75, alpha: 1)
        part(SCNCone(topRadius: 0.40, bottomRadius: 0.13, height: 0.58), teal,
             position: SCNVector3(0, 0.04, 0), transparency: 0.85, in: parent)
        part(SCNCylinder(radius: 0.22, height: 0.09), teal,
             position: SCNVector3(0, -0.34, 0), in: parent)
        part(SCNCylinder(radius: 0.045, height: 0.55),
             UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1),
             position: SCNVector3(0.20, 0.42, 0),
             euler: SCNVector3(0, 0, 0.35), in: parent)
        part(SCNSphere(radius: 0.09), UIColor(red: 0.85, green: 0.15, blue: 0.25, alpha: 1),
             position: SCNVector3(-0.28, 0.38, 0), in: parent)
        return SCNCylinder(radius: 0.42, height: 1.0)
    }
}
