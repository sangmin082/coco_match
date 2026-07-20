import SceneKit
import UIKit

/// 트레이 UI에 표시할 아이템 썸네일.
/// 보드와 동일한 ItemNodeFactory 3D 모델을 오프스크린 렌더링해 캐싱한다.
enum ItemThumbnail {
    private static var cache: [ItemType: UIImage] = [:]

    static func image(for type: ItemType) -> UIImage {
        if let cached = cache[type] { return cached }

        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let node = ItemNodeFactory.makeNode(for: type)
        node.physicsBody = nil
        node.eulerAngles = SCNVector3(-0.35, 0.55, 0)
        scene.rootNode.addChildNode(node)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 0.85
        cameraNode.position = SCNVector3(0, 0, 4)
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 700
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 850
        sun.eulerAngles = SCNVector3(-0.9, -0.4, 0)
        scene.rootNode.addChildNode(sun)

        let renderer = SCNRenderer(device: nil, options: nil)
        renderer.scene = scene
        renderer.autoenablesDefaultLighting = false
        let image = renderer.snapshot(atTime: 0,
                                      with: CGSize(width: 128, height: 128),
                                      antialiasingMode: .multisampling4X)
        cache[type] = image
        return image
    }

    /// 레벨 시작 시 미리 렌더링해 첫 수집 때 끊김을 방지한다
    static func prewarm(types: [ItemType]) {
        for type in types { _ = image(for: type) }
    }
}
