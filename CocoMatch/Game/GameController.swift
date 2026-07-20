import SceneKit
import CoreMotion
import QuartzCore
import UIKit

/// SceneKit 씬(통 + 아이템 물리)과 CoreMotion(기울임/흔들기)을 담당하는 컨트롤러.
/// 게임 규칙(트레이/매치/타이머)은 GameState가 담당한다.
final class GameController: NSObject {

    let scnView = SCNView()

    private let scene = SCNScene()
    private let motion = CMMotionManager()
    private weak var gameState: GameState?
    private var itemNodes: [SCNNode] = []
    private var lastShake: CFTimeInterval = 0

    // 수조(탱크) 크기 — 정면에서 바라보는 세로형 컨테이너 (갈매기 게임식)
    // 폭 = 화면 좌우, 높이 = 화면 상하, 깊이 = 얕은 앞뒤 (아이템 2겹 정도)
    private let tankWidth: Float = 7
    private let tankHeight: Float = 13
    private let tankDepth: Float = 2.6

    init(gameState: GameState) {
        self.gameState = gameState
        super.init()

        scnView.scene = scene
        scnView.antialiasingMode = .multisampling4X
        scnView.isPlaying = true
        scnView.backgroundColor = .clear

        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)

        setupCameraAndLights()
        setupBin()
        spawnItems(for: gameState.level)
        ItemThumbnail.prewarm(types: gameState.level.itemTypes)
        startMotionUpdates()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tap)
    }

    deinit {
        motion.stopDeviceMotionUpdates()
    }

    func setPaused(_ paused: Bool) {
        scene.isPaused = paused
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
        scnView.isPlaying = false
    }

    // MARK: - Scene setup

    private func setupCameraAndLights() {
        scene.background.contents = UIColor(red: 0.55, green: 0.83, blue: 0.93, alpha: 1)

        // 정면(-Z 방향)을 수평으로 바라보는 카메라 — 수조를 어항처럼 마주본다
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 55
        cameraNode.camera?.zFar = 120
        cameraNode.position = SCNVector3(0, tankHeight * 0.5, 14)
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 650
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 900
        sun.light?.castsShadow = true
        sun.light?.shadowRadius = 6
        sun.light?.shadowColor = UIColor(white: 0, alpha: 0.35)
        sun.eulerAngles = SCNVector3(-0.5, -0.3, 0)
        scene.rootNode.addChildNode(sun)
    }

    private func setupBin() {
        let wallTall: Float = 22

        // 모래색 바닥 (화면 하단)
        let floorGeometry = SCNBox(width: CGFloat(tankWidth) + 1.6,
                                   height: 1,
                                   length: CGFloat(tankDepth) + 1.6,
                                   chamferRadius: 0.15)
        floorGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.95, green: 0.83, blue: 0.60, alpha: 1)
        let floor = SCNNode(geometry: floorGeometry)
        floor.position = SCNVector3(0, -0.5, 0)
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        floor.physicsBody?.friction = 0.6
        floor.physicsBody?.restitution = 0.4
        scene.rootNode.addChildNode(floor)

        // 노란 모래빛 뒷벽 — 화면 배경 역할
        let backGeometry = SCNBox(width: CGFloat(tankWidth) + 1.6,
                                  height: CGFloat(wallTall),
                                  length: 0.5,
                                  chamferRadius: 0)
        backGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.99, green: 0.90, blue: 0.70, alpha: 1)
        let back = SCNNode(geometry: backGeometry)
        back.position = SCNVector3(0, wallTall / 2 - 1, -tankDepth / 2 - 0.25)
        back.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        back.physicsBody?.restitution = 0.4
        back.castsShadow = false
        scene.rootNode.addChildNode(back)

        // 좌우 반투명 유리벽
        addWall(size: (0.5, wallTall, tankDepth + 1.6),
                position: SCNVector3(tankWidth / 2 + 0.25, wallTall / 2 - 1, 0))
        addWall(size: (0.5, wallTall, tankDepth + 1.6),
                position: SCNVector3(-tankWidth / 2 - 0.25, wallTall / 2 - 1, 0))

        // 보이지 않는 앞 유리 — 아이템이 카메라 쪽으로 쏟아지지 않게 막는다
        let frontGeometry = SCNBox(width: CGFloat(tankWidth) + 1.6,
                                   height: CGFloat(wallTall),
                                   length: 0.4,
                                   chamferRadius: 0)
        let front = SCNNode(geometry: frontGeometry)
        front.position = SCNVector3(0, wallTall / 2 - 1, tankDepth / 2 + 0.2)
        front.opacity = 0
        front.castsShadow = false
        front.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        front.physicsBody?.restitution = 0.4
        scene.rootNode.addChildNode(front)

        // 흔들었을 때 아이템이 위로 날아가지 않게 막는 투명 천장
        let ceilingGeometry = SCNBox(width: CGFloat(tankWidth) + 1.6,
                                     height: 0.5,
                                     length: CGFloat(tankDepth) + 1.6,
                                     chamferRadius: 0)
        let ceiling = SCNNode(geometry: ceilingGeometry)
        ceiling.position = SCNVector3(0, wallTall - 2, 0)
        ceiling.opacity = 0
        ceiling.castsShadow = false
        ceiling.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(ceiling)
    }

    private func addWall(size: (Float, Float, Float), position: SCNVector3) {
        let geometry = SCNBox(width: CGFloat(size.0),
                              height: CGFloat(size.1),
                              length: CGFloat(size.2),
                              chamferRadius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.transparency = 0.10
        material.isDoubleSided = true
        geometry.materials = [material]
        let wall = SCNNode(geometry: geometry)
        wall.position = position
        wall.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        wall.physicsBody?.restitution = 0.4
        wall.castsShadow = false
        scene.rootNode.addChildNode(wall)
    }

    // MARK: - Items

    private func spawnItems(for level: LevelData) {
        var bag: [ItemType] = []
        for type in level.itemTypes {
            bag.append(contentsOf: Array(repeating: type, count: level.triplesPerType * 3))
        }
        bag.shuffle()

        for (index, type) in bag.enumerated() {
            let node = ItemNodeFactory.makeNode(for: type)
            node.position = SCNVector3(
                Float.random(in: (-tankWidth / 2 + 0.8)...(tankWidth / 2 - 0.8)),
                5 + Float(index / 10) * 1.3,
                Float.random(in: (-tankDepth / 2 + 0.6)...(tankDepth / 2 - 0.6))
            )
            node.eulerAngles = SCNVector3(
                Float.random(in: 0...Float.pi),
                Float.random(in: 0...Float.pi),
                Float.random(in: 0...Float.pi)
            )
            itemNodes.append(node)
            scene.rootNode.addChildNode(node)
        }
    }

    // MARK: - Motion (기울임 = 중력, 흔들기 = 임펄스)

    private func startMotionUpdates() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }

            // 갈매기 게임식 정면 뷰 매핑: 화면 좌우 = 씬 X, 화면 상하 = 씬 Y.
            // 폰을 세워 든 상태에서 중력이 화면 아래(-Y)로 향하고,
            // 좌우로 기울이면 실제 지구 중력 방향 그대로 아이템이 쏠린다.
            // 앞뒤 기울임(gz)은 얕은 수조 깊이에 맞게 약하게 반영하고
            // 살짝 뒷벽 쪽으로 눌러 아이템이 앞유리에 붙지 않게 한다.
            let g = data.gravity
            let k = 9.8
            self.scene.physicsWorld.gravity = SCNVector3(
                Float(g.x * k * 1.5),
                Float(g.y * k),
                Float(g.z * k * 0.6 - 0.8)
            )

            let ua = data.userAcceleration
            let magnitude = sqrt(ua.x * ua.x + ua.y * ua.y + ua.z * ua.z)
            if magnitude > 0.75 {
                self.applyImpulseToAll(strength: Float(min(magnitude * 1.4, 4.5)))
            }
        }
    }

    private func applyImpulseToAll(strength: Float) {
        let now = CACurrentMediaTime()
        guard now - lastShake > 0.35 else { return }
        lastShake = now
        guard gameState?.phase == .playing else { return }

        for node in itemNodes {
            node.physicsBody?.applyForce(
                SCNVector3(
                    Float.random(in: -1...1) * strength * 2.5,
                    Float.random(in: 2.5...5.0) * strength,
                    Float.random(in: -1...1) * strength * 2.5
                ),
                asImpulse: true
            )
            node.physicsBody?.applyTorque(
                SCNVector4(Float.random(in: -1...1), Float.random(in: -1...1),
                           Float.random(in: -1...1), Float.random(in: 0.5...1.5) * strength),
                asImpulse: true
            )
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Tap collect

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let state = gameState,
              state.phase == .playing,
              state.tray.count < state.trayCapacity else { return }

        let point = gesture.location(in: scnView)
        // 바운딩 박스 기준 히트테스트 + 탭 지점 주변 샘플링으로 인식률을 높인다
        let options: [SCNHitTestOption: Any] = [
            .searchMode: SCNHitTestSearchMode.all.rawValue,
            .boundingBoxOnly: true,
            .ignoreHiddenNodes: true,
        ]
        let offsets: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 16, y: 0), CGPoint(x: -16, y: 0),
            CGPoint(x: 0, y: 16), CGPoint(x: 0, y: -16),
        ]
        for offset in offsets {
            let p = CGPoint(x: point.x + offset.x, y: point.y + offset.y)
            for hit in scnView.hitTest(p, options: options) {
                if let root = itemRoot(of: hit.node) {
                    collect(node: root)
                    return
                }
            }
        }
    }

    /// 부품(자식 노드)이 히트되어도 아이템 루트 노드를 찾아 반환한다
    private func itemRoot(of node: SCNNode) -> SCNNode? {
        var current: SCNNode? = node
        while let n = current {
            if itemNodes.contains(where: { $0 === n }) { return n }
            current = n.parent
        }
        return nil
    }

    private func collect(node: SCNNode) {
        guard let name = node.name, let type = ItemType(rawValue: name) else { return }
        itemNodes.removeAll { $0 === node }
        node.physicsBody = nil

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 화면 아래(트레이 방향)로 날아가며 사라지는 연출
        let fly = SCNAction.group([
            SCNAction.move(to: SCNVector3(0, 0, 10), duration: 0.28),
            SCNAction.scale(to: 0.15, duration: 0.28),
            SCNAction.fadeOut(duration: 0.28)
        ])
        fly.timingMode = .easeIn
        node.runAction(SCNAction.sequence([fly, SCNAction.removeFromParentNode()]))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.gameState?.collect(type)
        }
    }

    // MARK: - Boosters

    /// 🌪 셔플: 전체 아이템을 크게 튀어오르게 해 더미를 뒤섞는다.
    func useShuffle() {
        guard let state = gameState, state.phase == .playing, state.shuffleLeft > 0 else { return }
        state.shuffleLeft -= 1
        lastShake = 0
        applyImpulseToAll(strength: 3.0)
    }

    /// 🧲 자석: 트레이 상황에 맞는 최적의 트리플을 자동 완성한다.
    /// 트레이 오버플로우(패배)가 발생하지 않는 경우에만 발동.
    func useMagnet() {
        guard let state = gameState, state.phase == .playing, state.magnetLeft > 0 else { return }

        var trayCounts: [ItemType: Int] = [:]
        for item in state.tray { trayCounts[item, default: 0] += 1 }

        var boardCounts: [ItemType: Int] = [:]
        for node in itemNodes {
            if let name = node.name, let type = ItemType(rawValue: name) {
                boardCounts[type, default: 0] += 1
            }
        }

        var chosen: ItemType?
        if let pair = trayCounts.first(where: { $0.value == 2 && boardCounts[$0.key, default: 0] >= 1 }) {
            chosen = pair.key
        } else if let pair = trayCounts.first(where: { $0.value == 1 && boardCounts[$0.key, default: 0] >= 2 }) {
            chosen = pair.key
        } else if let pair = boardCounts.first(where: { $0.value >= 3 }) {
            chosen = pair.key
        }

        guard let type = chosen else { return }
        let need = 3 - (trayCounts[type] ?? 0)
        // 마지막 아이템이 매치를 완성하기 전까지 트레이가 가득 차면 안 된다
        guard state.tray.count + need - 1 < state.trayCapacity else { return }

        state.magnetLeft -= 1
        let targets = Array(itemNodes.filter { $0.name == type.rawValue }.prefix(need))
        for (index, node) in targets.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.18) { [weak self] in
                self?.collect(node: node)
            }
        }
    }
}
