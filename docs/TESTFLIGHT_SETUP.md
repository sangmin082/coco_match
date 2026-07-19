# 🚀 TestFlight 자동 배포 설정 가이드

GitHub Actions가 자동으로 빌드해서 TestFlight에 올려주도록 하기 위한 **1회성 준비 작업**입니다.
전부 완료하면: **코드 푸시 → 자동 빌드 → 10~20분 뒤 아이폰 TestFlight 앱에서 설치** 흐름이 됩니다.

---

## 준비물 체크리스트

- [ ] 1. Apple Developer Program 가입
- [ ] 2. App ID(번들 ID) 등록
- [ ] 3. App Store Connect에 앱 생성
- [ ] 4. App Store Connect API 키 발급
- [ ] 5. GitHub Secrets 4개 등록
- [ ] 6. 푸시해서 첫 빌드 확인
- [ ] 7. TestFlight 내부 테스터 등록 → 아이폰에서 설치

---

## 1. Apple Developer Program 가입

- https://developer.apple.com/programs/ → **Enroll** (연 $99 / 약 13만원)
- 개인 계정으로 가입하면 됩니다. 승인까지 최대 48시간.

## 2. App ID(번들 ID) 등록

1. https://developer.apple.com/account → **Certificates, Identifiers & Profiles** → **Identifiers** → **+**
2. **App IDs** → **App** 선택
3. Description: `Coco Match`
4. Bundle ID: **Explicit** 선택 후 `com.sangmin.CocoMatch` 입력
   - 다른 ID를 쓰고 싶으면 Xcode 프로젝트의 `PRODUCT_BUNDLE_IDENTIFIER`도 같이 변경하세요.
5. Capabilities는 기본값 그대로 → **Register**

## 3. App Store Connect에 앱 생성

1. https://appstoreconnect.apple.com → **나의 앱** → **+** → **신규 앱**
2. 플랫폼: **iOS** / 이름: `코코 매치` (이미 사용 중이면 `코코 매치 - 3D 퍼즐` 등으로)
3. 기본 언어: 한국어 / 번들 ID: 위에서 등록한 `com.sangmin.CocoMatch` 선택
4. SKU: `cocomatch001` (아무 값이나 가능)

> ⚠️ 이 단계를 건너뛰면 업로드 시 "No suitable application records were found" 오류가 납니다.

## 4. App Store Connect API 키 발급

1. App Store Connect → **사용자 및 액세스** → **통합(Integrations)** 탭 → **App Store Connect API** → 팀 키 **+**
2. 이름: `github-actions` / 액세스 권한: **Admin** (클라우드 서명에 필요)
3. 생성 후:
   - **Issuer ID** 복사 (페이지 상단, UUID 형태)
   - **Key ID** 복사 (10자리)
   - **API 키 다운로드** → `AuthKey_XXXXXXXXXX.p8` 파일
     (⚠️ **1번만 다운로드 가능**하니 잘 보관하세요)

## 5. GitHub Secrets 등록

GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

| Secret 이름 | 값 |
|---|---|
| `APPSTORE_ISSUER_ID` | 4단계의 Issuer ID |
| `APPSTORE_KEY_ID` | 4단계의 Key ID (10자리) |
| `APPSTORE_PRIVATE_KEY` | `.p8` 파일을 텍스트 편집기로 열어 **내용 전체** 붙여넣기 (`-----BEGIN PRIVATE KEY-----`부터 끝까지) |
| `APPLE_TEAM_ID` | 팀 ID 10자리 — developer.apple.com/account → Membership details에서 확인 |

## 6. 첫 빌드 실행

- `main` 또는 `claude/**` 브랜치에 푸시하면 자동 실행됩니다.
- 또는 GitHub → **Actions** 탭 → **TestFlight** → **Run workflow** (수동 실행)
- 빌드는 15~25분 정도 걸립니다. Actions 탭에서 진행 상황 확인.

## 7. 아이폰에서 설치

1. 업로드 후 App Store Connect에서 5~15분 처리 시간이 지나면 **TestFlight** 탭에 빌드가 나타납니다.
2. App Store Connect → 코코 매치 → **TestFlight** → **내부 테스팅** → **+** 로 그룹 생성 → 테스터에 본인(Apple ID 이메일) 추가
3. 아이폰에 **TestFlight 앱** 설치 (App Store에서 무료)
4. 초대 메일 수락 → TestFlight 앱에서 **코코 매치 설치** → 플레이! 🥥
5. 이후에는 푸시할 때마다 새 빌드가 자동으로 올라오고, TestFlight 앱에서 업데이트 알림을 받습니다.

---

## 문제 해결

**"No suitable application records were found"**
→ 3단계(App Store Connect 앱 생성)가 안 된 상태입니다.

**서명 오류 (Cloud signing permission / No signing certificate)**
→ API 키 권한이 Admin인지 확인하세요. 그래도 안 되면 수동 인증서 방식으로 전환:
1. 맥의 Xcode → Settings → Accounts → Manage Certificates → **Apple Distribution** 인증서 생성
2. 키체인 접근에서 해당 인증서를 `.p12`로 내보내기 (비밀번호 설정)
3. `base64 -i cert.p12 | pbcopy` 로 base64 복사
4. GitHub Secrets에 `BUILD_CERTIFICATE_BASE64`(base64 값), `P12_PASSWORD`(내보내기 비밀번호) 추가
→ 워크플로우가 자동으로 이 인증서를 사용합니다.

**macOS 러너 요금**
→ 프라이빗 저장소에서 macOS 러너는 분당 10배 차감됩니다 (무료 2,000분 = macOS 약 200분, 빌드당 15~25분).
빌드 횟수를 줄이려면 `.github/workflows/testflight.yml`의 `on.push`를 지우고 수동 실행(`workflow_dispatch`)만 남기세요.
저장소를 **Public**으로 바꾸면 무료입니다.

**버전 올리기**
→ 빌드 번호는 GitHub run number로 자동 증가합니다. 마케팅 버전(1.0)을 올리려면 프로젝트의 `MARKETING_VERSION`을 수정하세요.
