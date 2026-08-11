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
    // 나머지는 대기열에 뒀다가 아이템을 수집할 때마다 새로 생성한다.
    private let maxOnScreen = 55
    private var pendingQueue: [ItemType] = []
    private var itemScale: CGFloat = 1.0
    private var rescueTimer: Timer?
    /// 탭 후 트레이로 날아가는 중인 아이템 (총량 검증 시 집계에 포함)
    private var inFlight: [ItemType] = []

    // 강제 정지: 입력(기울임 변화·흔들기·수집)이 잠잠해지면 미세 떨림을 0으로 클램프
    private var calmTimer: Timer?
    private var lastActivity: CFTimeInterval = CACurrentMediaTime()
    private var lastTiltX: Double = 0

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

        // 이어하기 등으로 트레이에서 빠진 아이템은 삭제하지 않고 보드로 되돌린다
        gameState.onItemReturnedToBoard = { [weak self] type in
            self?.spawnItem(type, hiddenInPile: true)
        }

        scnView.scene = scene
        scnView.antialiasingMode = .multisampling4X
        scnView.isPlaying = true
        scnView.backgroundColor = .clear

        // 기본 중력은 끄고(약한 뒷벽 밀착만 유지) 화면 중앙의 방사형 중력장이 아이템을 끌어모은다
        scene.physicsWorld.gravity = SCNVector3(0, 0, -2.2)
        // 100개 더미가 떨리지 않도록 물리 시뮬레이션을 더 촘촘하게 계산
        scene.physicsWorld.timeStep = 1.0 / 120.0

        setupCameraAndLights()
        setupBin()
        setupCenterGravityField()
        spawnItems(for: gameState.level)
        ItemThumbnail.prewarm(types: gameState.level.itemTypes)
        startMotionUpdates()
        startRescueTimer()
        startCalmTimer()

        // 누르는 동안 노란 하이라이트로 어떤 아이템이 골라졌는지 보여주고, 떼는 순간 수집
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        press.minimumPressDuration = 0
        scnView.addGestureRecognizer(press)
    }

    deinit {
        motion.stopDeviceMotionUpdates()
        rescueTimer?.invalidate()
        calmTimer?.invalidate()
    }

    func setPaused(_ paused: Bool) {
        scene.isPaused = paused
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
        rescueTimer?.invalidate()
        calmTimer?.invalidate()
        scnView.isPlaying = false
    }

    // MARK: - 강제 정지 (미세 떨림 제거)

    private func markActivity() {
        lastActivity = CACurrentMediaTime()
    }

    /// 플레이 중 상시로 느리게 꿈틀대는 아이템을 강제로 완전 정지시킨다.
    /// 흔들기 직후 0.8초와 기울임 조작 중에만 잠깐 풀어줘서 시원한 반동은 살린다.
    /// 임계 속도(0.55)는 중력장 가속(4.5)이 한 틱(0.15초) 안에 다시 넘어설 수 있는 크기라
    /// 낙하·재정렬 중인 아이템은 계속 움직이고, 더미에 낀 아이템만 얼어붙는다.
    private func startCalmTimer() {
        calmTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            self?.clampMicroMotion()
        }
    }

    private func clampMicroMotion() {
        guard !scene.isPaused else { return }
        let now = CACurrentMediaTime()
        guard now - lastShake > 1.2, now - lastActivity > 0.6 else { return }
        for node in itemNodes {
            guard let body = node.physicsBody else { continue }
            let v = body.velocity
            let speedSquared = v.x * v.x + v.y * v.y + v.z * v.z
            if speedSquared < 0.3 {
                body.velocity = SCNVector3Zero
                body.angularVelocity = SCNVector4Zero
            }
        }
    }

    /// 강한 임펄스로 벽을 뚫고 탈출한 아이템을 주기적으로 박스 안으로 되돌린다.
    /// (탈출한 아이템은 탭할 수 없어 레벨 클리어가 불가능해지므로 반드시 회수)
    private func startRescueTimer() {
        rescueTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.rescueEscapedItems()
        }
    }

    private func rescueEscapedItems() {
        guard !scene.isPaused else { return }
        for node in itemNodes {
            let p = node.presentation.position
            let escaped = abs(p.x) > tankWidth / 2 + 1.2
                || p.y < boxBottom - 1.5 || p.y > boxTop + 1.5
                || abs(p.z) > tankDepth / 2 + 1.2
            if escaped {
                node.physicsBody?.velocity = SCNVector3Zero
                node.physicsBody?.angularVelocity = SCNVector4Zero
                node.position = SCNVector3(
                    Float.random(in: -1.0...1.0),
                    boxCenterY,
                    Float.random(in: -0.5...0.5)
                )
                node.physicsBody?.resetTransform()
            }
        }
        reconcileItemEconomy()
    }

    /// 총량 자가치유: 어떤 이유로든 아이템이 사라져 잔량이 어긋나면 보충한다.
    /// (아이템이 모자라면 매치를 다 채울 수 없어 레벨이 영원히 안 끝나기 때문)
    private func reconcileItemEconomy() {
        guard let state = gameState, state.phase == .playing else { return }

        var counts: [ItemType: Int] = [:]
        for node in itemNodes {
            if let name = node.name, let type = ItemType(rawValue: name) {
                counts[type, default: 0] += 1
            }
        }
        for type in pendingQueue { counts[type, default: 0] += 1 }
        for type in state.tray { counts[type, default: 0] += 1 }
        for type in state.buffer { counts[type, default: 0] += 1 }
        for type in inFlight { counts[type, default: 0] += 1 }

        // ① 종별 잔량은 3의 배수여야 전부 매치로 소진할 수 있다 — 모자란 만큼 보충
        for type in state.level.itemTypes {
            let rem = counts[type, default: 0] % 3
            guard rem != 0 else { continue }
            for _ in 0..<(3 - rem) {
                addReplacement(type)
                counts[type, default: 0] += 1
            }
        }

        // ② 트리플이 통째로 사라진 경우: 전체 총량 부족분을 3개 단위로 보충
        let expected = state.level.totalItems - state.matchedCount
            - state.tray.count - state.buffer.count
        var actual = itemNodes.count + pendingQueue.count + inFlight.count
        var typeIndex = 0
        while actual < expected {
            let type = state.level.itemTypes[typeIndex % state.level.itemTypes.count]
            for _ in 0..<3 { addReplacement(type) }
            actual += 3
            typeIndex += 1
        }
    }

    /// 보드에 자리가 있으면 바로 스폰, 가득 차 있으면 대기열로
    private func addReplacement(_ type: ItemType) {
        if itemNodes.count >= maxOnScreen {
            pendingQueue.append(type)
        } else {
            spawnItem(type, hiddenInPile: true)
        }
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

    /// 중앙 "바닥"(플레이어가 보는 노란 뒷벽)에 달린 약한 자석 같은 방사형 중력장.
    /// 아이템들이 바닥 중앙에 덩어리로 모이고, 기울이면 덩어리째 쏠린다 (갈매기 게임식).
    private let fieldStrength: CGFloat = 4.5
    private var centerFieldNode: SCNNode?

    private func setupCenterGravityField() {
        let field = SCNPhysicsField.radialGravity()
        field.strength = fieldStrength
        field.falloffExponent = 0      // 거리와 무관하게 일정한 힘
        field.minimumDistance = 1.2    // 중심 근처 떨림 방지
        let fieldNode = SCNNode()
        fieldNode.physicsField = field
        fieldNode.position = SCNVector3(0, boxCenterY, -tankDepth / 2 + 0.3)
        scene.rootNode.addChildNode(fieldNode)
        centerFieldNode = fieldNode
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
            node.physicsBody?.restitution = 0.5
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

    /// 아이템 1개 생성. 초기 웨이브는 박스 상단에서 떨어지고,
    /// 대기열 보충(hiddenInPile)은 아이템 더미 맨 아래층(노란 바닥 쪽)
    /// 한가운데서 생성돼 기존 더미에 가려진다 — 플레이어가 스폰을 눈치채지 못하게.
    private func spawnItem(_ type: ItemType, hiddenInPile: Bool = false) {
        let node = ItemNodeFactory.makeNode(for: type, scale: itemScale)
        if hiddenInPile {
            // 더미 중앙, 바닥(뒷벽)에 최대한 붙여 생성 → 위에 쌓인 아이템들에 가려짐
            node.position = SCNVector3(
                Float.random(in: -1.4...1.4),
                boxCenterY + Float.random(in: -1.2...1.2),
                -tankDepth / 2 + 0.7
            )
        } else {
            node.position = SCNVector3(
                Float.random(in: (-tankWidth / 2 + 0.8)...(tankWidth / 2 - 0.8)),
                Float.random(in: (boxTop - 1.8)...(boxTop - 0.9)),
                Float.random(in: (-tankDepth / 2 + 0.6)...(tankDepth / 2 - 0.6))
            )
        }
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
            // 기울임 반응을 크게 — 살짝만 기울여도 더미가 시원하게 쏠린다
            self.scene.physicsWorld.gravity = SCNVector3(
                Float(g.x * k * 2.0),
                0,
                -2.2
            )

            // 기울임이 의미 있게 바뀌면 활동으로 간주 (강제 정지 해제)
            if abs(g.x - self.lastTiltX) > 0.06 {
                self.lastTiltX = g.x
                self.markActivity()
            }

            let ua = data.userAcceleration
            let magnitude = sqrt(ua.x * ua.x + ua.y * ua.y + ua.z * ua.z)
            if magnitude > 0.7 {
                // 흔들수록 확 튀게 — 임펄스를 세게
                self.applyImpulseToAll(strength: Float(min(magnitude * 2.8, 9.0)))
            }
        }
    }

    private func applyImpulseToAll(strength: Float) {
        let now = CACurrentMediaTime()
        guard now - lastShake > 0.35 else { return }
        lastShake = now
        guard gameState?.phase == .playing else { return }
        markActivity()

        // 폭발 동안 중앙 자석을 잠깐 꺼서 꽉 찬 더미도 시원하게 흩어지게 한다
        centerFieldNode?.physicsField?.strength = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self else { return }
            self.centerFieldNode?.physicsField?.strength = self.fieldStrength
        }

        let centerZ = -tankDepth / 2 + 0.3
        for node in itemNodes {
            guard let body = node.physicsBody else { continue }
            // 중심에서 바깥으로 터지는 방향 (빽빽한 더미에서도 상쇄되지 않는 코히어런트 폭발)
            let p = node.presentation.position
            var dx = p.x, dy = p.y - boxCenterY, dz = p.z - centerZ
            let length = sqrt(dx * dx + dy * dy + dz * dz)
            if length < 0.3 {
                dx = Float.random(in: -1...1); dy = Float.random(in: -1...1); dz = Float.random(in: 0...1)
            } else {
                dx /= length; dy /= length; dz /= length
            }
            // 폭발이 화끈하도록 감쇠도 잠깐 풀어준다 (아래에서 복원)
            body.damping = 0.05
            body.angularDamping = 0.3
            body.applyForce(
                SCNVector3(
                    dx * strength * 2.4 + Float.random(in: -1...1) * strength * 1.4,
                    dy * strength * 2.4 + Float.random(in: -1...1) * strength * 1.4,
                    dz * strength * 0.9 + Float.random(in: -1...1) * strength * 0.5
                ),
                asImpulse: true
            )
            body.applyTorque(
                SCNVector4(Float.random(in: -1...1), Float.random(in: -1...1),
                           Float.random(in: -1...1), Float.random(in: 0.8...1.8) * strength),
                asImpulse: true
            )
        }
        // 폭발이 끝나면 감쇠 복원 (연속 흔들기 중이면 다음 폭발의 복원에 맡긴다)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self, CACurrentMediaTime() - self.lastShake >= 0.85 else { return }
            for node in self.itemNodes {
                node.physicsBody?.damping = 0.32
                node.physicsBody?.angularDamping = 0.85
            }
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    // MARK: - Press & collect (누르면 하이라이트, 떼면 수집)

    private var highlightedNode: SCNNode?
    private var highlightedMaterials: [SCNMaterial] = []

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        guard let state = gameState,
              state.phase == .playing,
              state.tray.count < state.trayCapacity else {
            unhighlight()
            return
        }

        switch gesture.state {
        case .began, .changed:
            // 손가락 아래 아이템을 노란 음영으로 표시 (드래그하면 선택도 따라 움직임)
            let node = itemNode(at: gesture.location(in: scnView))
            if node !== highlightedNode {
                unhighlight()
                if let node { highlight(node) }
            }
        case .ended:
            if let node = highlightedNode {
                unhighlight()
                collect(node: node)
            }
        default:
            unhighlight()
        }
    }

    /// 탭 지점의 아이템 루트 노드를 2단계로 찾는다.
    /// ① 정밀 판정: 실제 지오메트리 기준 — 손가락 아래에 "보이는" 아이템을 정확히 집는다.
    ///    (바운딩 박스만 쓰면 큰 이웃의 투명 모서리가 작은 아이템을 가로채는 문제 방지)
    /// ② 광역 판정: 바운딩 박스 + 반경 14/26/36px 나선 샘플링 — 빗나간 탭도 근처 아이템을 잡는다.
    private func itemNode(at point: CGPoint) -> SCNNode? {
        // ① 정밀 (지오메트리 그대로, 중심 + 반경 8px 4방향)
        let precise: [SCNHitTestOption: Any] = [
            .searchMode: SCNHitTestSearchMode.all.rawValue,
            .ignoreHiddenNodes: true,
        ]
        let preciseOffsets: [CGPoint] = [
            .zero,
            CGPoint(x: 8, y: 0), CGPoint(x: -8, y: 0),
            CGPoint(x: 0, y: 8), CGPoint(x: 0, y: -8),
        ]
        for offset in preciseOffsets {
            let p = CGPoint(x: point.x + offset.x, y: point.y + offset.y)
            for hit in scnView.hitTest(p, options: precise) {
                if let root = itemRoot(of: hit.node) { return root }
            }
        }

        // ② 광역 (바운딩 박스, 넓은 나선 샘플링)
        let broad: [SCNHitTestOption: Any] = [
            .searchMode: SCNHitTestSearchMode.all.rawValue,
            .boundingBoxOnly: true,
            .ignoreHiddenNodes: true,
        ]
        var offsets: [CGPoint] = [.zero]
        for radius in [14.0, 26.0, 36.0] {
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                offsets.append(CGPoint(x: cos(angle) * radius, y: sin(angle) * radius))
            }
        }
        for offset in offsets {
            let p = CGPoint(x: point.x + offset.x, y: point.y + offset.y)
            for hit in scnView.hitTest(p, options: broad) {
                if let root = itemRoot(of: hit.node) { return root }
            }
        }
        return nil
    }

    /// 노란 발광(emission)으로 선택 중인 아이템을 강조한다
    private func highlight(_ node: SCNNode) {
        highlightedNode = node
        node.enumerateHierarchy { child, _ in
            for material in child.geometry?.materials ?? [] {
                material.emission.contents = UIColor(red: 1.0, green: 0.82, blue: 0.15, alpha: 1)
                material.emission.intensity = 0.55
                highlightedMaterials.append(material)
            }
        }
    }

    private func unhighlight() {
        for material in highlightedMaterials {
            material.emission.contents = UIColor.black
            material.emission.intensity = 1
        }
        highlightedMaterials = []
        highlightedNode = nil
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
        // 자석/하이라이트 경로가 겹쳐 같은 노드를 두 번 수집하는 것 방지
        guard itemNodes.contains(where: { $0 === node }) else { return }
        itemNodes.removeAll { $0 === node }
        inFlight.append(type)
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
            guard let self else { return }
            if let index = self.inFlight.firstIndex(of: type) {
                self.inFlight.remove(at: index)
            }
            if self.gameState?.collect(type) != true {
                // 날아가는 사이 시간초과/일시정지가 됐다면 아이템을 보드로 되돌린다 (증발 방지)
                self.spawnItem(type, hiddenInPile: true)
            }
        }

        // 대기열 보충: 하나 수집할 때마다 새 아이템이 더미 밑에서 조용히 생겨난다 (총량 유지)
        if !pendingQueue.isEmpty {
            let next = pendingQueue.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.spawnItem(next, hiddenInPile: true)
            }
        }
    }

    // MARK: - Boosters

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
