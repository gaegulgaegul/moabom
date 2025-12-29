# 모아봄 기능 현황

> 마지막 업데이트: 2025-12-29
>
> 이 문서는 모아봄 프로젝트의 현재 구현 상태를 한눈에 파악할 수 있도록 정리한 문서입니다.

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택](#2-기술-스택)
3. [기능 현황 요약](#3-기능-현황-요약)
4. [상세 기능 설명](#4-상세-기능-설명)
5. [데이터 모델](#5-데이터-모델)
6. [UI/디자인 시스템](#6-ui디자인-시스템)
7. [파일 구조](#7-파일-구조)
8. [향후 계획](#8-향후-계획)

---

## 1. 프로젝트 개요

**모아봄 (MoaBom)**은 가족이 함께 아기 사진을 공유하고 추억을 기록하는 가족 전용 사진첩 앱입니다.

### 핵심 가치

- 가족만의 프라이빗 공간
- 아이 중심의 사진 정리
- 실시간 가족 소통 (반응, 댓글)
- 모바일 최적화 (Turbo Native 지원)

### 주요 특징

- OAuth 소셜 로그인 (카카오)
- 가족 그룹 기반 멤버십
- 사진 타임라인 (날짜별 그룹)
- 반응 및 댓글 시스템
- 실시간 알림
- Frame0 Sketch 디자인 시스템 (손그림 느낌)

---

## 2. 기술 스택

### 백엔드

| 항목 | 기술 | 버전 |
|------|------|------|
| **프레임워크** | Ruby on Rails | 8.1.1 |
| **언어** | Ruby | 3.x |
| **데이터베이스** | SQLite | 2.1+ |
| **캐시/큐/케이블** | Solid Cache, Solid Queue, Solid Cable | - |
| **파일 저장소** | Active Storage + Cloudflare R2 | - |
| **이미지 처리** | image_processing (ImageMagick/libvips) | 1.2 |
| **OAuth** | OmniAuth (Kakao) | - |

### 프론트엔드

| 항목 | 기술 | 버전 |
|------|------|------|
| **Hotwire** | Turbo + Stimulus | - |
| **CSS** | TailwindCSS | v4 |
| **컴포넌트** | ViewComponent | - |
| **아이콘** | Lucide Icons | - |
| **디자인 라이브러리** | Rough.js (Frame0 Sketch) | - |

### 인프라

| 항목 | 기술 |
|------|------|
| **배포** | Railway (예정) |
| **스토리지** | Cloudflare R2 (예정) |
| **컨테이너** | Kamal (예정) |

---

## 3. 기능 현황 요약

### 범례

- ✅ **구현 완료**: 프로덕션 사용 가능
- 🚧 **진행 중**: 개발 중이거나 부분 구현
- 📋 **계획됨**: 설계 완료, 미구현
- ⏸️ **보류**: 향후 고려

### 핵심 기능

| 기능 영역 | 상태 | 구현 내용 |
|----------|------|----------|
| **1. 인증 및 사용자 관리** | ✅ | OAuth (카카오), 세션 관리, 프로필 설정 |
| **2. 가족 및 멤버십** | ✅ | 가족 그룹, 역할 시스템, 초대 기능 |
| **3. 사진 관리** | ✅ | 업로드, 타임라인, 자녀 필터, 반응/댓글 |
| **4. 온보딩** | ✅ | 3단계 온보딩 (프로필 → 아이 → 초대) |
| **5. 알림 시스템** | ✅ | 인앱 알림 (반응, 댓글) |
| **6. 디자인 시스템** | ✅ | Frame0 Sketch (14+ 컴포넌트) |
| **7. 설정 및 대시보드** | ✅ | 홈 대시보드, 프로필, 알림 설정 |
| **8. Turbo Native API** | ✅ | 푸시 토큰, 동기화 API |
| **9. Hotwire Native (모바일)** | 🚧 | 기반 구현 (60%), 네이티브 연동 미완 |

### 미구현 기능 (Phase 2)

| 기능 | 상태 | 비고 |
|------|------|------|
| **Apple/Google 로그인** | 📋 | OAuth 인프라 준비 완료 |
| **푸시 알림 (FCM/APNs)** | 📋 | 인프라만 구현, 실제 발송 미구현 |
| **앨범 기능** | 📋 | 데이터 모델 미설계 |
| **얼굴 인식 자동 태깅** | 📋 | 수동 태깅으로 대체 |
| **베스트샷 자동 선별** | ⏸️ | AI 기능 필요 |
| **댓글 대댓글** | ⏸️ | 단일 레벨 댓글만 지원 |

---

## 4. 상세 기능 설명

### 4.1 인증 및 사용자 관리

#### ✅ 구현 완료

**OAuth 소셜 로그인**
- **카카오 로그인**: 완전 구현
- provider/uid 기반 사용자 식별
- 자동 계정 생성

**사용자 프로필**
- 닉네임 (2-20자, 한글/영문/숫자/언더스코어)
- 아바타 이미지 (Active Storage, 최대 5MB)
- 금지 닉네임 필터링 (관리자, admin 등)

**디바이스 관리**
- FCM/APNs 토큰 저장
- 디바이스별 푸시 알림 관리

**알림 설정**
- 새 사진 알림 on/off
- 댓글 알림 on/off
- 반응 알림 on/off

#### 📋 계획된 기능

- Apple 로그인
- Google 로그인
- 이메일/비밀번호 로그인 (백업)

---

### 4.2 가족 및 멤버십

#### ✅ 구현 완료

**Family 모델 (Aggregate Root)**
- 가족 그룹 생성
- 가족 이름
- 소유자(Owner) 자동 할당

**FamilyMembership (역할 시스템)**

| 역할 | 권한 |
|------|------|
| **viewer** (0) | 사진 보기만 가능 |
| **member** (1) | 사진 업로드 가능 |
| **admin** (2) | 멤버 관리, 사진 삭제 |
| **owner** (3) | 모든 권한 + 가족 삭제 |

**권한 체계**
- `can_upload?`: member 이상
- `can_delete_photo?(photo)`: 본인 업로드 또는 admin/owner
- `admin_or_owner?`: 관리자 확인

**초대 시스템**
- SecureRandom 토큰 기반 (32자 hex)
- 만료 시간: 7일 (기본값)
- 짧은 URL: `/i/:token`
- 역할 지정 가능 (viewer, member, admin)

**Child (아이 프로필)**
- 이름, 생년월일, 성별
- 프로필 사진 (Active Storage)
- 나이 자동 계산 (개월, 년/개월, 태어난 일수)
- 예: `age_string` → "1년 3개월"

---

### 4.3 사진 기능

#### ✅ 구현 완료

**사진 업로드**
- 단건 업로드
- **배치 업로드**: 최대 100장 동시 처리
- Active Storage + Cloudflare R2
- Direct Upload 지원 (서버 부하 최소화)

**지원 파일 형식**
- JPEG, PNG, HEIC, WebP
- 최대 파일 크기: 50MB/장

**이미지 Variants**
- `thumbnail`: 300x300
- `medium`: 800x800
- `large`: 1600x1600

**타임라인 뷰**
- 날짜별 그룹화 (`Photo.group_by_date`)
- 최신순 정렬
- 페이지네이션 (50장/페이지)
- N+1 쿼리 방지 (includes)

**자녀 필터링**
- 사진에 아이 태그 연결 (`belongs_to :child`)
- 특정 아이 사진만 필터 가능

**반응 시스템**
- 8개 이모지 지원: ❤️ 👍 😊 😍 😂 🎉 👏 🔥
- 사용자당 사진 1개 반응 제한
- 반응 생성 시 자동 알림 발송

**댓글 시스템**
- 최대 1000자
- 댓글 작성 시 자동 알림 발송
- 본인 댓글은 알림 안 감

**Turbo Stream 실시간 업데이트**
- 새 사진 업로드 → 타임라인 자동 추가
- 새 반응/댓글 → 실시간 업데이트

#### 📋 계획된 기능

- 동영상 업로드 (현재 이미지만)
- 앨범 기능
- 사진 편집 (크롭, 필터)
- 얼굴 인식 자동 태깅

---

### 4.4 온보딩 흐름

#### ✅ 구현 완료

**3단계 온보딩**

```
1단계: 프로필 등록
  └─ 닉네임 입력 (필수)

2단계: 첫 아이 등록
  └─ 이름, 생년월일, 성별 입력

3단계: 가족 초대
  └─ 초대 링크 생성 (선택)
  └─ 완료 버튼으로 스킵 가능
```

**자동 완료 조건**
- Owner가 첫 아이를 등록하면 `onboarding_completed_at` 자동 설정
- 재방문 시 온보딩 화면 안 보임

**초대받은 사람**
- 온보딩 불필요 (바로 가족 멤버로 추가)

---

### 4.5 알림 시스템

#### ✅ 구현 완료

**인앱 알림**
- `reaction_created`: "OOO님이 사진에 반응했어요"
- `comment_created`: "OOO님이 댓글을 남겼어요"

**NotificationService**
- 중복 알림 방지 (reaction 한 번만)
- 본인 액션은 알림 안 감
- 다형성 연관 (`notifiable: Reaction, Comment`)

**알림 읽음 처리**
- `read_at` 필드로 읽음/안 읽음 관리
- `mark_as_read!` 메서드

**알림 설정**
- 사용자별 알림 on/off
- 설정 페이지: `/settings/notifications`

#### 📋 계획된 기능

- 푸시 알림 (FCM/APNs) - 인프라만 구현
- 이메일 알림
- 알림 배치 처리 (5분마다 묶어서 발송)

---

### 4.6 디자인 시스템

#### ✅ 구현 완료

**Frame0 Sketch 스타일**
- Rough.js 기반 손그림 느낌
- 따뜻하고 친근한 UI
- 파스텔 톤 컬러

**14+ ViewComponents**

| 컴포넌트 | 설명 |
|----------|------|
| `Sketch::ButtonComponent` | 손그림 스타일 버튼 |
| `Sketch::CardComponent` | 카드 레이아웃 |
| `Sketch::InputComponent` | 입력 필드 |
| `Sketch::ModalComponent` | 모달 다이얼로그 |
| `Sketch::NavComponent` | 네비게이션 |
| `Sketch::AlertComponent` | 알림 배너 |
| `Sketch::AvatarComponent` | 아바타 (원형 이미지) |
| `Sketch::BadgeComponent` | 뱃지 (숫자, 라벨) |
| `Sketch::ContainerComponent` | 컨테이너 |
| `Sketch::DividerComponent` | 구분선 |
| `Sketch::EmptyStateComponent` | 빈 상태 |
| `Sketch::ListItemComponent` | 리스트 아이템 |
| `Sketch::GalleryCardComponent` | 사진 카드 |
| `Sketch::StoryAvatarComponent` | 스토리 스타일 아바타 |

**7+ Stimulus 컨트롤러**
- `sketch_border_controller`: 손그림 테두리
- `sketch_button_controller`: 버튼 애니메이션
- `sketch_card_controller`: 카드 효과
- `sketch_input_controller`: 입력 필드 스타일
- `sketch_modal_controller`: 모달 제어
- `sketch_nav_controller`: 네비게이션
- `sketch_alert_controller`: 알림 제어

**TailwindCSS v4 통합**
- 커스텀 색상 팔레트
- 모바일 우선 반응형
- 다크 모드 준비 (미활성화)

---

### 4.7 설정 및 대시보드

#### ✅ 구현 완료

**홈 대시보드 (home2)**
- 최근 사진 타임라인
- 가족 정보
- 빠른 액션 (사진 업로드, 초대)

**프로필 설정 (`/settings/profile`)**
- 닉네임 변경
- 아바타 업로드
- 회원 정보 수정

**알림 설정 (`/settings/notifications`)**
- 새 사진 알림 on/off
- 댓글 알림 on/off
- 반응 알림 on/off

---

### 4.8 Turbo Native API

#### ✅ 구현 완료

**API 엔드포인트**

| 엔드포인트 | 메서드 | 용도 |
|-----------|--------|------|
| `/api/native/sync` | GET | 초기 데이터 동기화 |
| `/api/native/push_tokens` | POST | FCM/APNs 토큰 등록 |
| `/api/native/push_tokens/:id` | DELETE | 토큰 삭제 |

**동기화 데이터**
- 현재 사용자 정보
- 가족 목록
- 최근 사진 (50장)
- 읽지 않은 알림

---

### 4.9 Hotwire Native (모바일 앱 배포)

#### 📊 배포 준비도: **60%**

**백엔드 인프라는 준비되어 있으나, 네이티브 앱 연동을 위한 프론트엔드 설정이 부족합니다.**

#### ✅ 구현 완료

**Turbo Rails 통합**
- `turbo-rails` gem 설치 및 설정
- Turbo Drive, Turbo Frames, Turbo Streams 동작
- HTML 응답 + JSON API 병행 가능

**Native Bridge API**
- `/api/native/sync`: 초기 데이터 동기화
- `/api/native/push_tokens`: FCM/APNs 토큰 등록
- Device 모델: 플랫폼(ios/android), 토큰, 앱 버전 저장

**Stimulus 컨트롤러**
- 17개 Stimulus 컨트롤러 구현
- 대부분 웹/네이티브 공용 사용 가능

#### 🚧 미구현 (P0 - 필수)

| 항목 | 설명 | 필요 작업 |
|------|------|----------|
| **path_configuration.json** | 네이티브 앱 경로 설정 | `/public/turbo-native/path_configuration.json` 생성 |
| **turbo_native_app? 헬퍼** | 네이티브 앱 감지 | ApplicationController에 추가 |
| **네이티브 전용 레이아웃** | 탭바/헤더 제거 | `layouts/turbo_native.html.erb` 생성 |
| **푸시 알림 발송** | FCM/APNs 실제 발송 | PushNotificationService 완성 |
| **네이티브 브릿지 JS** | 네이티브 ↔ 웹 통신 | `native_bridge_controller.js` 생성 |

#### 📋 미구현 (P1 - 권장)

| 항목 | 설명 |
|------|------|
| **네이티브 전용 에러 페이지** | 오프라인/에러 시 네이티브 UI |
| **네이티브 인증 흐름** | OAuth 네이티브 처리 (카카오 SDK) |
| **딥링크 처리** | `moabom://` 스킴 라우팅 |
| **네이티브 공유** | 시스템 공유 시트 연동 |

#### ⏸️ 미구현 (P2 - 선택)

| 항목 | 설명 |
|------|------|
| **네이티브 위젯** | iOS 위젯, Android 위젯 |
| **오프라인 모드** | 로컬 캐시 + 동기화 |
| **네이티브 카메라** | 네이티브 카메라 앱 연동 |

#### 필수 파일 구조 (생성 필요)

```
moabom/
├── public/
│   └── turbo-native/
│       └── path_configuration.json    # 📋 생성 필요
├── app/
│   ├── controllers/
│   │   └── application_controller.rb  # turbo_native_app? 추가
│   ├── views/
│   │   └── layouts/
│   │       └── turbo_native.html.erb  # 📋 생성 필요
│   └── javascript/
│       └── controllers/
│           └── native_bridge_controller.js  # 📋 생성 필요
└── config/
    └── routes.rb                      # 네이티브 전용 라우트 (선택)
```

#### path_configuration.json 예시

```json
{
  "settings": {
    "screenshots_enabled": true,
    "pull_to_refresh_enabled": true
  },
  "rules": [
    {
      "patterns": ["/auth/*"],
      "properties": {
        "presentation": "modal"
      }
    },
    {
      "patterns": ["/photos/new", "/families/*/photos/new"],
      "properties": {
        "presentation": "modal"
      }
    },
    {
      "patterns": ["/*"],
      "properties": {
        "presentation": "default",
        "navigation": "default"
      }
    }
  ]
}
```

#### 배포 전 체크리스트

- [ ] `path_configuration.json` 생성
- [ ] `turbo_native_app?` 헬퍼 구현
- [ ] 네이티브 전용 레이아웃 생성
- [ ] FCM/APNs 키 설정 및 PushNotificationService 완성
- [ ] 네이티브 브릿지 Stimulus 컨트롤러 생성
- [ ] iOS/Android Turbo Native 앱 프로젝트 생성
- [ ] 테스트 빌드 및 검증

---

## 5. 데이터 모델

### 핵심 모델 관계

```
User
  ├─ has_many :family_memberships
  ├─ has_many :families (through: family_memberships)
  ├─ has_many :devices
  ├─ has_many :notifications (recipient)
  └─ has_one_attached :avatar

Family (Aggregate Root)
  ├─ has_many :family_memberships
  ├─ has_many :users (through: family_memberships)
  ├─ has_many :children
  ├─ has_many :photos
  └─ has_many :invitations

Photo
  ├─ belongs_to :family
  ├─ belongs_to :uploader (User)
  ├─ belongs_to :child (optional)
  ├─ has_many :reactions
  ├─ has_many :comments
  └─ has_one_attached :image

Reaction
  ├─ belongs_to :photo
  ├─ belongs_to :user
  └─ has_many :notifications (polymorphic)

Comment
  ├─ belongs_to :photo
  ├─ belongs_to :user
  └─ has_many :notifications (polymorphic)

Notification
  ├─ belongs_to :recipient (User)
  ├─ belongs_to :actor (User)
  └─ belongs_to :notifiable (polymorphic: Reaction, Comment)
```

### 테이블 개수

총 **11개 테이블** (+ Active Storage 3개)

1. `users`
2. `families`
3. `family_memberships`
4. `children`
5. `photos`
6. `reactions`
7. `comments`
8. `invitations`
9. `notifications`
10. `devices`
11. `solid_queue_*` (백그라운드 잡)

---

## 6. UI/디자인 시스템

### 디자인 철학

- **따뜻함**: 파스텔 톤, 부드러운 곡선
- **친근함**: 손그림 느낌, 귀여운 아이콘
- **단순함**: 최소한의 UI, 사진이 주인공
- **접근성**: 터치 타겟 48px+, 명확한 대비

### 색상 팔레트

| 색상 | 용도 | HEX |
|------|------|-----|
| Primary | 주요 액션 | `#FF8B66` (살구색) |
| Secondary | 보조 액션 | `#4ECDC4` (민트) |
| Accent | 강조 | `#FF6B9D` (핑크) |
| Background | 배경 | `#FFFDFB` (크림) |
| Text | 본문 | `#44403C` (웜 그레이) |

### 타이포그래피

- 기본 본문: 16px
- 제목: 24-36px
- 보조 텍스트: 14px
- 폰트: 시스템 폰트 스택 (-apple-system, Roboto)

### 간격 시스템

- 기본 단위: 4px
- 페이지 패딩: 16px (px-4)
- 카드 간격: 16px (gap-4)
- 버튼 패딩: 12x24px (py-3 px-6)

---

## 7. 파일 구조

```
moabom/
├── app/
│   ├── controllers/           # 21개 컨트롤러
│   │   ├── api/native/        # Native API
│   │   ├── families/          # 가족 관련 (members, children, photos)
│   │   ├── photos/            # 반응, 댓글
│   │   ├── onboarding/        # 온보딩 3단계
│   │   └── settings/          # 설정
│   ├── models/                # 11개 모델
│   │   ├── concerns/          # Onboardable
│   │   ├── user.rb
│   │   ├── family.rb
│   │   ├── photo.rb
│   │   └── ...
│   ├── views/
│   │   ├── layouts/
│   │   ├── shared/
│   │   └── [controllers]/
│   ├── components/            # 14+ Sketch 컴포넌트
│   │   └── sketch/
│   ├── services/              # 3개 서비스
│   │   ├── notification_service.rb
│   │   ├── timeline_service.rb
│   │   └── push_notification_service.rb
│   ├── javascript/
│   │   └── controllers/       # 16개 Stimulus 컨트롤러
│   └── helpers/
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── storage.yml
├── db/
│   ├── migrate/               # 14개 마이그레이션
│   └── seeds.rb
├── docs/                      # 프로젝트 문서
│   ├── guides/
│   ├── features/mvp/
│   ├── gaps/
│   └── plan/
└── test/                      # 테스트 (진행 중)
```

---

## 8. 향후 계획

### Phase 2 (Q1 2025)

#### 🚧 Hotwire Native 완성 (P0)
- [ ] `path_configuration.json` 생성
- [ ] `turbo_native_app?` 헬퍼 구현
- [ ] 네이티브 전용 레이아웃 (`turbo_native.html.erb`)
- [ ] 네이티브 브릿지 Stimulus 컨트롤러
- [ ] iOS Turbo Native 앱 프로젝트 생성
- [ ] Android Turbo Native 앱 프로젝트 생성

#### 📋 인증 확장
- [ ] Apple 로그인
- [ ] Google 로그인
- [ ] 이메일/비밀번호 로그인 (백업)

#### 📋 푸시 알림
- [ ] FCM 통합 (Android)
- [ ] APNs 통합 (iOS)
- [ ] 푸시 알림 발송 서비스
- [ ] 알림 배치 처리

#### 📋 앨범 기능
- [ ] 앨범 모델 설계
- [ ] 앨범 CRUD
- [ ] 사진 앨범 연결
- [ ] 앨범 공유

#### 📋 사진 기능 강화
- [ ] 동영상 업로드
- [ ] 대량 업로드 UI 개선 (진행률)
- [ ] 사진 편집 (크롭, 필터)

### Phase 3 (Q2 2025)

#### ⏸️ AI 기능
- [ ] 얼굴 인식 자동 태깅 (face-api.js)
- [ ] 베스트샷 자동 선별
- [ ] 흐린 사진 자동 분류

#### ⏸️ 소셜 기능
- [ ] 댓글 대댓글
- [ ] 멘션 기능
- [ ] 가족 활동 피드

### 기술 부채

- [ ] 테스트 커버리지 향상 (현재 미흡)
- [ ] API 문서화 (OpenAPI/Swagger)
- [ ] 성능 모니터링 (APM)
- [ ] 에러 트래킹 (Sentry)
- [ ] CI/CD 파이프라인
- [ ] 프로덕션 배포 (Railway)
- [ ] Cloudflare R2 스토리지 전환

---

## 참고 문서

- [프로젝트 아키텍처](/docs/features/mvp/ARCHITECTURE.md)
- [API 설계](/docs/features/mvp/API_DESIGN.md)
- [PRD (제품 요구사항)](/docs/features/mvp/PRD.md)
- [코딩 가이드](/docs/guides/CODING_GUIDE.md)
- [커밋 가이드](/docs/guides/COMMIT_GUIDE.md)
- [컨벤션](/docs/guides/CONVENTIONS.md)
- [디자인 시스템](/.claude/rules/design-system.md)

---

## 라이선스 및 기여

- **라이선스**: MIT (가정)
- **기여**: 프라이빗 프로젝트

---

**이 문서는 자동으로 생성되지 않습니다. 주요 기능 구현 시 수동 업데이트가 필요합니다.**
