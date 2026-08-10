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

    // 갈매기 게임식 총량 유지: 화면에는 최대 maxOnScreen개만 렌더링하고
    // 나머지는 대기열에 뒀다가 아이템을 수집할 때마다 위에서 새로 떨어진다.
    private let maxOnScreen = 54
    private var pendingQueue: [ItemType] = []
    private var itemScale: CGFloat = 1.0

    // 플레이 박스 — 정면에서 바라보는 세로형 컨테이너 (갈매기 게임식).
    // 상단 HUD와 하단 트레이/부스터 UI에 겹치지 않도록 화면 중앙 영역만 사용한다.
    // 카메라 기준 화면 세로 가시 범위는 대략 y -0.8 ~ 13.8.
    private let tankWidth: Float = 6.6
    private let tankDepth: Float = 4.2
    private let boxBottom: Float = 2.4   // 박스 바닥 높이 (트레이/부스터 위)
    private let boxTop: Float = 10.6     // 박스 천장 높이 (HUD 아래)
    private var boxCenterY: Float { (boxBottom + boxTop) / 2 }

    init(gameState: GameState) {
        self.gameState = gameState
        super.init()

        scnView.scene = scene
        scnView.antialiasingMode = .multisampling4X
        scnView.isPlaying = true
        scnView.backgroundColor = .clear

        // 기본 중력은 끄고(약한 뒷벽 밀착만 유지) 화면 중앙의 방사형 중력장이 아이템을 끌어모은다
        scene.physicsWorld.gravity = SCNVector3(0, 0, -2.2)

        setupCameraAndLights()
        setupBin()
        setupCenterGravityField()
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
        cameraNode.position = SCNVector3(0, 6.5, 14)
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 750
        ambient.light?.color = UIColor(red: 1.0, green: 0.97, blue: 0.92, alpha: 1)
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

    /// 화면(박스) 정중앙으로 아이템을 끌어당기는 방사형 중력장.
    /// 아이템들이 중앙에 덩어리로 뭉치고, 기울이면 덩어리째 쏠린다 (갈매기 게임식).
    private func setupCenterGravityField() {
        let field = SCNPhysicsField.radialGravity()
        field.strength = 5.5
        field.falloffExponent = 0      // 거리와 무관하게 일정한 힘
        field.minimumDistance = 0.5    // 중심 근처 떨림 방지
        let fieldNode = SCNNode()
        fieldNode.physicsField = field
        fieldNode.position = SCNVector3(0, boxCenterY, 0)
        scene.rootNode.addChildNode(fieldNode)
    }

    private func setupBin() {
        let innerHeight = boxTop - boxBottom
        let sand = UIColor(red: 0.95, green: 0.83, blue: 0.60, alpha: 1)
        let backYellow = UIColor(red: 0.99, green: 0.90, blue: 0.70, alpha: 1)
        let wood = UIColor(red: 0.62, green: 0.42, blue: 0.24, alpha: 1)

        // 박스 바닥 (모래색 선반) / 천장 (나무 프레임)
        staticBox(width: tankWidth + 1.4, height: 0.6, length: tankDepth + 1.4,
                  position: SCNVector3(0, boxBottom - 0.3, 0), color: sand)
        staticBox(width: tankWidth + 1.4, height: 0.6, length: tankDepth + 1.4,
                  position: SCNVector3(0, boxTop + 0.3, 0), color: wood)

        // 노란 모래빛 뒷벽 (박스 배경)
        staticBox(width: tankWidth + 1.4, height: innerHeight, length: 0.5,
                  position: SCNVector3(0, boxCenterY, -tankDepth / 2 - 0.25), color: backYellow)

        // 좌우 반투명 유리벽
        staticBox(width: 0.5, height: innerHeight, length: tankDepth + 1.4,
                  position: SCNVector3(tankWidth / 2 + 0.25, boxCenterY, 0),
                  color: .white, transparency: 0.12)
        staticBox(width: 0.5, height: innerHeight, length: tankDepth + 1.4,
                  position: SCNVector3(-tankWidth / 2 - 0.25, boxCenterY, 0),
                  color: .white, transparency: 0.12)

        // 보이지 않는 앞 유리 — 아이템이 카메라 쪽으로 쏟아지지 않게 막는다
        staticBox(width: tankWidth + 1.4, height: innerHeight, length: 0.4,
                  position: SCNVector3(0, boxCenterY, tankDepth / 2 + 0.2),
                  color: .white, transparency: 0)

        // 박스 앞면 테두리 프레임 (나무 막대) — 플레이 영역을 또렷하게 보여준다
        let zFront = tankDepth / 2 + 0.4
        staticBox(width: tankWidth + 1.4, height: 0.22, length: 0.22,
                  position: SCNVector3(0, boxBottom, zFront), color: wood, hasPhysics: false)
        staticBox(width: tankWidth + 1.4, height: 0.22, length: 0.22,
                  position: SCNVector3(0, boxTop, zFront), color: wood, hasPhysics: false)
        staticBox(width: 0.22, height: innerHeight + 0.22, length: 0.22,
                  position: SCNVector3(tankWidth / 2 + 0.6, boxCenterY, zFront), color: wood, hasPhysics: false)
        staticBox(width: 0.22, height: innerHeight + 0.22, length: 0.22,
                  position: SCNVector3(-tankWidth / 2 - 0.6, boxCenterY, zFront), color: wood, hasPhysics: false)
    }

    @discardableResult
    private func staticBox(width: Float, height: Float, length: Float,
                           position: SCNVector3, color: UIColor,
                           transparency: CGFloat = 1,
                           hasPhysics: Bool = true) -> SCNNode {
        let geometry = SCNBox(width: CGFloat(width), height: CGFloat(height),
                              length: CGFloat(length), chamferRadius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.transparency = transparency
        material.isDoubleSided = true
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        node.position = position
        if hasPhysics {
            node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            node.physicsBody?.restitution = 0.4
            node.physicsBody?.friction = 0.6
        }
        if transparency < 0.99 { node.castsShadow = false }
        scene.rootNode.addChildNode(node)
        return node
    }

    // MARK: - Items

    private func spawnItems(for level: LevelData) {
        itemScale = level.itemScale
        var bag: [ItemType] = []
        for type in level.itemTypes {
            bag.append(contentsOf: Array(repeating: type, count: level.triplesPerType * 3))
        }
        bag.shuffle()

        // 화면 정원(maxOnScreen)까지만 먼저 붓고 나머지는 대기열로
        let initial = Array(bag.prefix(maxOnScreen))
        pendingQueue = Array(bag.dropFirst(maxOnScreen))

        // 닫힌 박스 안에서 겹침 폭발이 없도록, 박스 상단에서 웨이브로 나눠 떨어뜨린다
        let waveSize = 12
        for start in stride(from: 0, to: initial.count, by: waveSize) {
            let wave = Array(initial[start..<min(start + waveSize, initial.count)])
            let delay = Double(start / waveSize) * 0.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                for type in wave {
                    self.spawnItem(type)
                }
            }
        }
    }

    /// 박스 상단에서 아이템 1개를 떨어뜨린다 (초기 웨이브·대기열 보충 공용)
    private func spawnItem(_ type: ItemType) {
        let node = ItemNodeFactory.makeNode(for: type, scale: itemScale)
        node.position = SCNVector3(
            Float.random(in: (-tankWidth / 2 + 0.8)...(tankWidth / 2 - 0.8)),
            Float.random(in: (boxTop - 1.8)...(boxTop - 0.9)),
            Float.random(in: (-tankDepth / 2 + 0.6)...(tankDepth / 2 - 0.6))
        )
        node.eulerAngles = SCNVector3(
            Float.random(in: -0.45...0.45),
            Float.random(in: -0.45...0.45),
            Float.random(in: -0.45...0.45)
        )
        itemNodes.append(node)
        scene.rootNode.addChildNode(node)
    }

    // MARK: - Motion (기울임 = 중력, 흔들기 = 임펄스)

    private func startMotionUpdates() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }

            // 아이템은 방사형 중력장이 화면 중앙으로 끌어모으고,
            // 기기 기울임은 균일 중력으로 더해져 덩어리째 그 방향으로 쏠리게 한다.
            // (좌우 기울임 = X, 위아래 기울임은 세워 든 자세 기준의 변화량만 Y에 반영)
            // z축은 상수 힘으로 뒷벽에 살짝 붙여 얕은 수조에서 안정시킨다.
            let g = data.gravity
            let k = 9.8
            self.scene.physicsWorld.gravity = SCNVector3(
                Float(g.x * k * 0.9),
                0,
                -2.2
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
            // 중앙 덩어리가 사방으로 흩어졌다가 다시 모이도록 전방향 대칭 임펄스
            node.physicsBody?.applyForce(
                SCNVector3(
                    Float.random(in: -1...1) * strength * 3.0,
                    Float.random(in: -1...1) * strength * 3.0,
                    Float.random(in: -1...1) * strength * 1.2
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

        // 대기열 보충: 하나 수집할 때마다 새 아이템이 위에서 튀어나온다 (총량 유지)
        if !pendingQueue.isEmpty {
            let next = pendingQueue.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.spawnItem(next)
            }
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
