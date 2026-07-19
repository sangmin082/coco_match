# 🥥 코코 매치 (Coco Match)

**폰을 기울이고 흔들면 아이템이 진짜처럼 굴러다니는 3D 매치 트리플 퍼즐** (iOS)

- 🎮 **레벨 방식**: Match Factory 스타일 — 통 속 3D 아이템을 탭해서 7칸 트레이에 수집, 같은 아이템 3개를 모으면 소멸. 통을 다 비우면 클리어!
- 📱 **모션 물리**: 갈매기 게임 스타일 — 아이폰을 기울이면 중력이 바뀌어 아이템이 쏠리고, 흔들면 튀어오르며 뒤섞임 (CoreMotion)
- 🏝 코코 아일랜드(열대 해변) 테마 · 50레벨 · 부스터 3종 (셔플/자석/+30초)

자세한 기획은 [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md) 참고.

## 📲 TestFlight 자동 배포

`main` 또는 `claude/**` 브랜치에 푸시하면 GitHub Actions가 자동으로 빌드해서 TestFlight에 업로드합니다
(`.github/workflows/testflight.yml`). 최초 1회 Apple 계정 설정이 필요합니다 →
**[docs/TESTFLIGHT_SETUP.md](docs/TESTFLIGHT_SETUP.md) 가이드 참고**

## 실행 방법

1. **Xcode 16 이상**에서 `CocoMatch.xcodeproj` 열기
2. Signing & Capabilities에서 본인 개발 팀 선택
3. **실제 iPhone에 빌드** (⌘R) — 모션 센서를 쓰므로 실기기 권장
   - 시뮬레이터에서도 실행 가능 (기울임 없이 탭 플레이만 동작)

요구사항: iOS 17+, iPhone 세로 모드. 외부 의존성 없음 (SwiftUI + SceneKit + CoreMotion만 사용).

## 조작

| 입력 | 동작 |
|---|---|
| 탭 | 아이템 수집 → 트레이로 |
| 기기 기울이기 | 아이템이 기울인 방향으로 와르르 |
| 기기 흔들기 | 아이템이 튀어오르며 섞임 |

## 폴더 구조

```
CocoMatch/
├── CocoMatchApp.swift        # 앱 진입점
├── Models/
│   ├── ItemType.swift        # 아이템 12종 (이모지/색상)
│   ├── LevelData.swift       # 50레벨 난이도 공식
│   └── GameState.swift       # 트레이·매치·타이머·부스터 규칙
├── Game/
│   ├── GameController.swift  # SceneKit 물리 + CoreMotion 중력/흔들기
│   └── EmojiTexture.swift    # 이모지 → 3D 블록 텍스처
└── Views/
    ├── ContentView.swift     # 메뉴 + 레벨 선택
    ├── GameView.swift        # 게임 화면 (HUD/부스터)
    └── OverlayViews.swift    # 트레이/팝업 UI
```
