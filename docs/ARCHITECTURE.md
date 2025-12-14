# 모아봄 (MoaBom) - 시스템 아키텍처

> 버전: 1.0
> 작성일: 2025-12-13
> 기술 스택: Rails 8 + Turbo Native

---

## 1. 시스템 개요

### 1.1 아키텍처 원칙

| 원칙 | 설명 |
|-----|------|
| **Convention over Configuration** | Rails 관례를 최대한 따름 |
| **Monolith First** | 마이크로서비스 없이 모놀리식으로 시작 |
| **Server-Side Rendering** | Hotwire로 서버 중심 렌더링 |
| **Progressive Enhancement** | 기본 HTML → Turbo → Native 순 향상 |
| **Simple Infrastructure** | Redis 없이 Solid Stack 활용 |

### 1.2 기술 스택 요약

```
┌─────────────────────────────────────────────────────────┐
│                      Client Layer                        │
├─────────────────┬─────────────────┬─────────────────────┤
│   iOS App       │   Android App   │      Web App        │
│ (Turbo Native)  │ (Turbo Native)  │    (Browser)        │
│    Swift        │     Kotlin      │   Hotwire           │
└────────┬────────┴────────┬────────┴──────────┬──────────┘
         │                 │                   │
         └─────────────────┼───────────────────┘
                           │ HTTPS
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Rails 8 Server                        │
├─────────────────────────────────────────────────────────┤
│  Hotwire (Turbo + Stimulus) │ Authentication │ API      │
├─────────────────────────────────────────────────────────┤
│  Active Storage │ Active Job │ Action Cable │ Solid *   │
└────────┬────────────────┬────────────────┬──────────────┘
         │                │                │
         ▼                ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐
│ PostgreSQL  │  │  S3/R2      │  │  SQLite (Solid)     │
│ (Primary)   │  │  (Storage)  │  │  Cache/Queue/Cable  │
└─────────────┘  └─────────────┘  └─────────────────────┘
```

---

## 2. 시스템 구조

### 2.1 전체 아키텍처 다이어그램

```
                                    ┌──────────────┐
                                    │   Cloudflare │
                                    │     CDN      │
                                    └──────┬───────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
              ┌─────▼─────┐          ┌─────▼─────┐          ┌─────▼─────┐
              │  iOS App  │          │  Android  │          │    Web    │
              │           │          │    App    │          │  Browser  │
              └─────┬─────┘          └─────┬─────┘          └─────┬─────┘
                    │                      │                      │
                    │    Turbo Native      │    Turbo Native      │
                    │    (WebView +        │    (WebView +        │
                    │     Native)          │     Native)          │
                    │                      │                      │
                    └──────────────────────┼──────────────────────┘
                                           │
                                           │ HTTPS (TLS 1.3)
                                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              Load Balancer                               │
│                           (Kamal / Traefik)                             │
└─────────────────────────────────────┬───────────────────────────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
        ▼                             ▼                             ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│  Rails App    │           │  Rails App    │           │  Rails App    │
│  Container 1  │           │  Container 2  │           │  Container N  │
│               │           │               │           │  (Scale)      │
│  ┌─────────┐  │           │  ┌─────────┐  │           │               │
│  │ Puma    │  │           │  │ Puma    │  │           │               │
│  │ Workers │  │           │  │ Workers │  │           │               │
│  └─────────┘  │           │  └─────────┘  │           │               │
└───────┬───────┘           └───────┬───────┘           └───────────────┘
        │                           │
        └─────────────┬─────────────┘
                      │
    ┌─────────────────┼─────────────────┬─────────────────┐
    │                 │                 │                 │
    ▼                 ▼                 ▼                 ▼
┌────────┐      ┌──────────┐     ┌───────────┐    ┌─────────────┐
│PostgreSQL     │ S3 / R2  │     │  SQLite   │    │ APNs / FCM  │
│        │      │ Storage  │     │(Solid Stack)   │Push Service │
│ Users  │      │          │     │           │    │             │
│ Photos │      │ Photos   │     │ - Cache   │    │             │
│ Groups │      │ Videos   │     │ - Queue   │    │             │
│  ...   │      │ Thumbs   │     │ - Cable   │    │             │
└────────┘      └──────────┘     └───────────┘    └─────────────┘
```

### 2.2 컴포넌트 설명

| 컴포넌트 | 역할 | 기술 |
|---------|------|------|
| **iOS/Android App** | 네이티브 쉘 + 웹뷰 | Turbo Native (Swift/Kotlin) |
| **Web Browser** | 반응형 웹 앱 | Hotwire (Turbo + Stimulus) |
| **CDN** | 정적 자산, 이미지 캐싱 | Cloudflare |
| **Load Balancer** | 트래픽 분산, SSL 종료 | Kamal (Traefik) |
| **Rails App** | 비즈니스 로직, 뷰 렌더링 | Rails 8, Puma |
| **PostgreSQL** | 주 데이터베이스 | PostgreSQL 16 |
| **Object Storage** | 사진/영상 저장 | S3 / Cloudflare R2 |
| **Solid Stack** | 캐시, 큐, 웹소켓 | SQLite 기반 |
| **Push Service** | 푸시 알림 | APNs (iOS), FCM (Android) |

---

## 3. Rails 애플리케이션 구조

### 3.1 디렉토리 구조

```
moabom/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── concerns/
│   │   │   ├── authentication.rb        # 인증 로직
│   │   │   ├── turbo_native.rb          # Turbo Native 감지
│   │   │   └── family_authorization.rb  # 가족 권한 체크
│   │   ├── sessions_controller.rb       # 로그인/로그아웃
│   │   ├── registrations_controller.rb  # 회원가입
│   │   ├── photos_controller.rb         # 사진 CRUD
│   │   ├── albums_controller.rb         # 앨범 관리
│   │   ├── families_controller.rb       # 가족 그룹
│   │   ├── children_controller.rb       # 아이 프로필
│   │   ├── invitations_controller.rb    # 초대 관리
│   │   ├── comments_controller.rb       # 댓글
│   │   ├── reactions_controller.rb      # 반응
│   │   ├── settings_controller.rb       # 설정
│   │   └── native/                      # Turbo Native 전용
│   │       ├── bridge_controller.rb     # 네이티브 브릿지
│   │       └── uploads_controller.rb    # 네이티브 업로드
│   │
│   ├── models/
│   │   ├── user.rb                      # 사용자
│   │   ├── child.rb                     # 아이
│   │   ├── family.rb                    # 가족 그룹
│   │   ├── family_membership.rb         # 가족 멤버십 (역할)
│   │   ├── invitation.rb                # 초대
│   │   ├── photo.rb                     # 사진
│   │   ├── album.rb                     # 앨범
│   │   ├── comment.rb                   # 댓글
│   │   ├── reaction.rb                  # 반응
│   │   ├── device.rb                    # 기기 (푸시용)
│   │   └── growth_record.rb             # 성장 기록
│   │
│   ├── views/
│   │   ├── layouts/
│   │   │   ├── application.html.erb     # 웹 레이아웃
│   │   │   └── turbo_native.html.erb    # 네이티브 레이아웃
│   │   ├── photos/
│   │   ├── albums/
│   │   ├── families/
│   │   └── ...
│   │
│   ├── javascript/
│   │   ├── application.js               # Stimulus 엔트리
│   │   └── controllers/                 # Stimulus 컨트롤러
│   │       ├── photo_upload_controller.js
│   │       ├── infinite_scroll_controller.js
│   │       ├── native_bridge_controller.js
│   │       └── ...
│   │
│   ├── jobs/                            # 백그라운드 작업
│   │   ├── application_job.rb
│   │   ├── photo_processing_job.rb      # 이미지 리사이징
│   │   ├── push_notification_job.rb     # 푸시 발송
│   │   └── memory_notification_job.rb   # N년 전 오늘 알림
│   │
│   ├── services/                        # 서비스 객체
│   │   ├── photos/
│   │   │   ├── uploader.rb              # 업로드 처리
│   │   │   └── processor.rb             # 이미지 처리
│   │   ├── auth/
│   │   │   ├── kakao_oauth.rb           # 카카오 인증
│   │   │   ├── apple_oauth.rb           # 애플 인증
│   │   │   └── google_oauth.rb          # 구글 인증
│   │   ├── push/
│   │   │   └── notifier.rb              # 푸시 발송
│   │   └── invitations/
│   │       └── generator.rb             # 초대 링크 생성
│   │
│   ├── channels/                        # Action Cable
│   │   ├── application_cable/
│   │   ├── family_channel.rb            # 가족 실시간 업데이트
│   │   └── notification_channel.rb      # 알림 채널
│   │
│   └── mailers/                         # 이메일
│       ├── application_mailer.rb
│       └── invitation_mailer.rb         # 초대 이메일
│
├── config/
│   ├── routes.rb                        # 라우팅
│   ├── database.yml                     # DB 설정
│   ├── storage.yml                      # Active Storage
│   ├── cable.yml                        # Action Cable (Solid Cable)
│   ├── queue.yml                        # Solid Queue
│   └── cache.yml                        # Solid Cache
│
├── db/
│   ├── migrate/                         # 마이그레이션
│   ├── schema.rb                        # 스키마
│   └── seeds.rb                         # 시드 데이터
│
└── storage/                             # 로컬 스토리지 (개발용)
```

### 3.2 레이어 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Controllers │  │    Views    │  │    Stimulus     │  │
│  │             │  │ (ERB+Turbo) │  │   Controllers   │  │
│  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘  │
└─────────┼────────────────┼──────────────────┼───────────┘
          │                │                  │
          ▼                ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                    Business Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │  Services   │  │    Jobs     │  │    Channels     │  │
│  │             │  │ (Background)│  │  (Real-time)    │  │
│  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘  │
└─────────┼────────────────┼──────────────────┼───────────┘
          │                │                  │
          ▼                ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   Models    │  │Active Storage│ │   Solid Stack   │  │
│  │(ActiveRecord)│ │  (Files)    │  │ (Cache/Queue)   │  │
│  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘  │
└─────────┼────────────────┼──────────────────┼───────────┘
          │                │                  │
          ▼                ▼                  ▼
┌─────────────┐      ┌───────────┐      ┌───────────┐
│ PostgreSQL  │      │  S3 / R2  │      │  SQLite   │
└─────────────┘      └───────────┘      └───────────┘
```

### 3.3 주요 Concern

```ruby
# app/controllers/concerns/turbo_native.rb
module TurboNative
  extend ActiveSupport::Concern

  included do
    helper_method :turbo_native_app?
  end

  def turbo_native_app?
    request.user_agent.to_s.match?(/Turbo Native/)
  end

  def native_ios?
    request.user_agent.to_s.match?(/Turbo Native iOS/)
  end

  def native_android?
    request.user_agent.to_s.match?(/Turbo Native Android/)
  end
end
```

```ruby
# app/controllers/concerns/family_authorization.rb
module FamilyAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_family_access!
    unless current_user.member_of?(current_family)
      redirect_to root_path, alert: "접근 권한이 없습니다."
    end
  end

  def authorize_admin!
    unless current_user.admin_of?(current_family)
      redirect_to family_path(current_family), alert: "관리자 권한이 필요합니다."
    end
  end

  def current_family
    @current_family ||= Family.find(params[:family_id] || params[:id])
  end
end
```

---

## 4. 데이터베이스 스키마

### 4.1 ERD (Entity Relationship Diagram)

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     users       │       │    families     │       │    children     │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id              │──┐    │ id              │──┐    │ id              │
│ email           │  │    │ name            │  │    │ name            │
│ nickname        │  │    │ created_at      │  │    │ birthdate       │
│ avatar_url      │  │    │ updated_at      │  │    │ gender          │
│ provider        │  │    └────────┬────────┘  │    │ family_id       │──┐
│ uid             │  │             │           │    │ created_at      │  │
│ created_at      │  │             │           │    └─────────────────┘  │
│ updated_at      │  │             │           │                         │
└────────┬────────┘  │             │           │                         │
         │           │             │           │                         │
         │           │    ┌────────▼────────┐  │                         │
         │           └───►│family_memberships│◄─┘                         │
         │                ├─────────────────┤                            │
         │                │ id              │                            │
         └───────────────►│ user_id         │                            │
                          │ family_id       │                            │
                          │ role            │ (owner/admin/member/viewer)│
                          │ relation        │ (mom/dad/grandma/etc)      │
                          │ created_at      │                            │
                          └─────────────────┘                            │
                                                                         │
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐  │
│     photos      │       │     albums      │       │  album_photos   │  │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤  │
│ id              │──┐    │ id              │──┐    │ id              │  │
│ family_id       │  │    │ family_id       │  │    │ album_id        │──┘
│ user_id         │  │    │ child_id        │  │    │ photo_id        │
│ child_id        │──┼───►│ name            │  │    └─────────────────┘
│ taken_at        │  │    │ cover_photo_id  │  │
│ caption         │  │    │ auto_generated  │  │
│ location        │  │    │ created_at      │  │
│ metadata        │  │    └─────────────────┘  │
│ created_at      │  │                         │
└────────┬────────┘  │                         │
         │           │                         │
         │           │    ┌─────────────────┐  │
         │           └───►│    comments     │  │
         │                ├─────────────────┤  │
         │                │ id              │  │
         └───────────────►│ photo_id        │  │
                          │ user_id         │  │
                          │ body            │  │
                          │ created_at      │  │
                          └─────────────────┘  │
                                               │
┌─────────────────┐       ┌─────────────────┐  │
│    reactions    │       │   invitations   │  │
├─────────────────┤       ├─────────────────┤  │
│ id              │       │ id              │  │
│ photo_id        │       │ family_id       │◄─┘
│ user_id         │       │ inviter_id      │
│ emoji           │       │ token           │
│ created_at      │       │ role            │
└─────────────────┘       │ expires_at      │
                          │ accepted_at     │
                          │ created_at      │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│     devices     │       │ growth_records  │
├─────────────────┤       ├─────────────────┤
│ id              │       │ id              │
│ user_id         │       │ child_id        │
│ platform        │       │ recorded_at     │
│ push_token      │       │ height_cm       │
│ device_name     │       │ weight_kg       │
│ last_used_at    │       │ memo            │
│ created_at      │       │ created_at      │
└─────────────────┘       └─────────────────┘
```

### 4.2 테이블 상세 정의

#### users (사용자)
```sql
CREATE TABLE users (
  id              BIGSERIAL PRIMARY KEY,
  email           VARCHAR(255) NOT NULL UNIQUE,
  nickname        VARCHAR(50) NOT NULL,
  avatar_url      VARCHAR(500),
  provider        VARCHAR(20) NOT NULL,  -- kakao, apple, google
  uid             VARCHAR(255) NOT NULL,
  phone           VARCHAR(20),
  settings        JSONB DEFAULT '{}',    -- 알림 설정 등
  deleted_at      TIMESTAMP,             -- Soft delete
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL,

  UNIQUE(provider, uid)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_provider_uid ON users(provider, uid);
```

#### families (가족 그룹)
```sql
CREATE TABLE families (
  id              BIGSERIAL PRIMARY KEY,
  name            VARCHAR(100) NOT NULL DEFAULT '우리 가족',
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);
```

#### family_memberships (가족 멤버십)
```sql
CREATE TABLE family_memberships (
  id              BIGSERIAL PRIMARY KEY,
  user_id         BIGINT NOT NULL REFERENCES users(id),
  family_id       BIGINT NOT NULL REFERENCES families(id),
  role            VARCHAR(20) NOT NULL DEFAULT 'member',  -- owner, admin, member, viewer
  relation        VARCHAR(20),  -- mom, dad, grandma, grandpa, etc
  joined_at       TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL,

  UNIQUE(user_id, family_id)
);

CREATE INDEX idx_memberships_family ON family_memberships(family_id);
CREATE INDEX idx_memberships_user ON family_memberships(user_id);
```

#### children (아이)
```sql
CREATE TABLE children (
  id              BIGSERIAL PRIMARY KEY,
  family_id       BIGINT NOT NULL REFERENCES families(id),
  name            VARCHAR(50) NOT NULL,
  birthdate       DATE NOT NULL,
  gender          VARCHAR(10),  -- male, female, null
  avatar_url      VARCHAR(500),
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_children_family ON children(family_id);
```

#### photos (사진)
```sql
CREATE TABLE photos (
  id              BIGSERIAL PRIMARY KEY,
  family_id       BIGINT NOT NULL REFERENCES families(id),
  user_id         BIGINT NOT NULL REFERENCES users(id),
  child_id        BIGINT REFERENCES children(id),
  taken_at        TIMESTAMP NOT NULL,
  caption         TEXT,
  location        VARCHAR(255),
  latitude        DECIMAL(10, 8),
  longitude       DECIMAL(11, 8),
  metadata        JSONB DEFAULT '{}',  -- EXIF 등
  width           INTEGER,
  height          INTEGER,
  file_size       INTEGER,
  content_type    VARCHAR(50),
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_photos_family ON photos(family_id);
CREATE INDEX idx_photos_taken_at ON photos(family_id, taken_at DESC);
CREATE INDEX idx_photos_child ON photos(child_id);
CREATE INDEX idx_photos_user ON photos(user_id);
```

#### albums (앨범)
```sql
CREATE TABLE albums (
  id              BIGSERIAL PRIMARY KEY,
  family_id       BIGINT NOT NULL REFERENCES families(id),
  child_id        BIGINT REFERENCES children(id),
  name            VARCHAR(100) NOT NULL,
  description     TEXT,
  cover_photo_id  BIGINT REFERENCES photos(id),
  auto_generated  BOOLEAN DEFAULT FALSE,  -- 자동 생성 앨범 (월별 등)
  album_type      VARCHAR(20) DEFAULT 'custom',  -- custom, monthly, yearly, milestone
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_albums_family ON albums(family_id);
```

#### album_photos (앨범-사진 연결)
```sql
CREATE TABLE album_photos (
  id              BIGSERIAL PRIMARY KEY,
  album_id        BIGINT NOT NULL REFERENCES albums(id),
  photo_id        BIGINT NOT NULL REFERENCES photos(id),
  position        INTEGER,
  created_at      TIMESTAMP NOT NULL,

  UNIQUE(album_id, photo_id)
);
```

#### comments (댓글)
```sql
CREATE TABLE comments (
  id              BIGSERIAL PRIMARY KEY,
  photo_id        BIGINT NOT NULL REFERENCES photos(id),
  user_id         BIGINT NOT NULL REFERENCES users(id),
  body            TEXT NOT NULL,
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_comments_photo ON comments(photo_id);
```

#### reactions (반응)
```sql
CREATE TABLE reactions (
  id              BIGSERIAL PRIMARY KEY,
  photo_id        BIGINT NOT NULL REFERENCES photos(id),
  user_id         BIGINT NOT NULL REFERENCES users(id),
  emoji           VARCHAR(10) NOT NULL,  -- ❤️, 😍, 😂, 🥺, 👏
  created_at      TIMESTAMP NOT NULL,

  UNIQUE(photo_id, user_id)  -- 1인 1반응
);

CREATE INDEX idx_reactions_photo ON reactions(photo_id);
```

#### invitations (초대)
```sql
CREATE TABLE invitations (
  id              BIGSERIAL PRIMARY KEY,
  family_id       BIGINT NOT NULL REFERENCES families(id),
  inviter_id      BIGINT NOT NULL REFERENCES users(id),
  token           VARCHAR(100) NOT NULL UNIQUE,
  role            VARCHAR(20) NOT NULL DEFAULT 'viewer',
  expires_at      TIMESTAMP NOT NULL,
  accepted_at     TIMESTAMP,
  accepted_by_id  BIGINT REFERENCES users(id),
  created_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_invitations_token ON invitations(token);
CREATE INDEX idx_invitations_family ON invitations(family_id);
```

#### devices (기기 - 푸시용)
```sql
CREATE TABLE devices (
  id              BIGSERIAL PRIMARY KEY,
  user_id         BIGINT NOT NULL REFERENCES users(id),
  platform        VARCHAR(20) NOT NULL,  -- ios, android, web
  push_token      VARCHAR(500),
  device_name     VARCHAR(100),
  app_version     VARCHAR(20),
  os_version      VARCHAR(20),
  last_used_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_devices_user ON devices(user_id);
CREATE INDEX idx_devices_push_token ON devices(push_token);
```

#### growth_records (성장 기록)
```sql
CREATE TABLE growth_records (
  id              BIGSERIAL PRIMARY KEY,
  child_id        BIGINT NOT NULL REFERENCES children(id),
  recorded_at     DATE NOT NULL,
  height_cm       DECIMAL(5, 2),
  weight_kg       DECIMAL(5, 2),
  memo            TEXT,
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_growth_child ON growth_records(child_id, recorded_at);
```

---

## 5. Turbo Native 통신 설계

### 5.1 통신 방식 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                      Turbo Native App                            │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                       WebView                                │ │
│  │    (Rails에서 렌더링한 HTML을 그대로 표시)                      │ │
│  │                                                               │ │
│  │    - 일반 페이지 이동: Turbo가 처리                            │ │
│  │    - 폼 제출: Turbo Stream으로 처리                           │ │
│  │    - 실시간 업데이트: Action Cable                            │ │
│  │                                                               │ │
│  └──────────────────────────┬──────────────────────────────────┘ │
│                             │                                     │
│                    JavaScript Bridge                              │
│                             │                                     │
│  ┌──────────────────────────▼──────────────────────────────────┐ │
│  │                   Native Components                          │ │
│  │                                                               │ │
│  │    - 카메라/갤러리 접근                                        │ │
│  │    - 푸시 알림 처리                                           │ │
│  │    - 생체 인증                                                │ │
│  │    - 공유 시트                                                │ │
│  │    - 딥링크 처리                                              │ │
│  │                                                               │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Path Configuration (경로 설정)

```json
// iOS: path-configuration.json
{
  "settings": {
    "screenshots_enabled": true
  },
  "rules": [
    {
      "patterns": ["/new$", "/edit$"],
      "properties": {
        "presentation": "modal"
      }
    },
    {
      "patterns": ["/photos/\\d+$"],
      "properties": {
        "presentation": "detail"
      }
    },
    {
      "patterns": ["/native/camera"],
      "properties": {
        "presentation": "native",
        "native_controller": "CameraViewController"
      }
    },
    {
      "patterns": ["/native/photo_picker"],
      "properties": {
        "presentation": "native",
        "native_controller": "PhotoPickerViewController"
      }
    },
    {
      "patterns": ["/native/share"],
      "properties": {
        "presentation": "native",
        "native_controller": "ShareViewController"
      }
    }
  ]
}
```

### 5.3 JavaScript Bridge 메시지

```javascript
// app/javascript/controllers/native_bridge_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 네이티브 → 웹
  static values = {
    action: String
  }

  // 카메라로 사진 촬영 요청
  openCamera() {
    this.sendToNative("openCamera", {
      maxPhotos: 10,
      allowsEditing: false
    })
  }

  // 갤러리에서 사진 선택 요청
  openPhotoPicker() {
    this.sendToNative("openPhotoPicker", {
      maxPhotos: 50,
      mediaTypes: ["image", "video"]
    })
  }

  // 공유 시트 열기
  share(event) {
    const { url, text } = event.params
    this.sendToNative("share", { url, text })
  }

  // 네이티브로 메시지 전송
  sendToNative(action, data = {}) {
    const message = { action, data, timestamp: Date.now() }

    // iOS
    if (window.webkit?.messageHandlers?.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage(message)
    }
    // Android
    else if (window.NativeApp) {
      window.NativeApp.postMessage(JSON.stringify(message))
    }
  }

  // 네이티브에서 호출되는 콜백
  receiveFromNative(action, data) {
    switch(action) {
      case "photosSelected":
        this.handlePhotosSelected(data.photos)
        break
      case "pushTokenReceived":
        this.registerPushToken(data.token)
        break
      case "biometricResult":
        this.handleBiometricResult(data.success)
        break
    }
  }

  handlePhotosSelected(photos) {
    // 선택된 사진을 서버에 업로드
    const form = document.getElementById("photo-upload-form")
    // ... 업로드 로직
  }
}
```

### 5.4 네이티브 응답 처리 (Rails)

```ruby
# app/controllers/concerns/turbo_native.rb
module TurboNative
  extend ActiveSupport::Concern

  included do
    helper_method :turbo_native_app?, :native_ios?, :native_android?
  end

  def turbo_native_app?
    request.user_agent.to_s.include?("Turbo Native")
  end

  def native_ios?
    request.user_agent.to_s.include?("Turbo Native iOS")
  end

  def native_android?
    request.user_agent.to_s.include?("Turbo Native Android")
  end

  # 네이티브 앱일 때 다른 레이아웃 사용
  def set_native_layout
    if turbo_native_app?
      "turbo_native"
    else
      "application"
    end
  end
end
```

```ruby
# app/controllers/native/uploads_controller.rb
class Native::UploadsController < ApplicationController
  # POST /native/photos
  # 네이티브 앱에서 사진 업로드 시 사용
  def create
    @photo = current_family.photos.build(photo_params)
    @photo.user = current_user

    if @photo.save
      PhotoProcessingJob.perform_later(@photo.id)

      render json: {
        success: true,
        photo_id: @photo.id,
        redirect_url: family_photo_path(current_family, @photo)
      }
    else
      render json: {
        success: false,
        errors: @photo.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:image, :caption, :taken_at, :child_id)
  end
end
```

---

## 6. 주요 데이터 흐름

### 6.1 사진 업로드 흐름

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  User   │     │ Turbo Native│     │   Rails     │     │  Storage    │
│         │     │    App      │     │   Server    │     │  (S3/R2)    │
└────┬────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
     │                 │                   │                   │
     │ 1. 사진 촬영 버튼 │                   │                   │
     │────────────────►│                   │                   │
     │                 │                   │                   │
     │                 │ 2. Native 카메라   │                   │
     │                 │    또는 갤러리     │                   │
     │◄────────────────│                   │                   │
     │                 │                   │                   │
     │ 3. 사진 선택     │                   │                   │
     │────────────────►│                   │                   │
     │                 │                   │                   │
     │                 │ 4. POST /native/photos               │
     │                 │   (multipart)     │                   │
     │                 │──────────────────►│                   │
     │                 │                   │                   │
     │                 │                   │ 5. Active Storage │
     │                 │                   │    Direct Upload  │
     │                 │                   │──────────────────►│
     │                 │                   │                   │
     │                 │                   │ 6. Upload 완료    │
     │                 │                   │◄──────────────────│
     │                 │                   │                   │
     │                 │                   │ 7. PhotoProcessingJob
     │                 │                   │    (Background)   │
     │                 │                   │    - 썸네일 생성   │
     │                 │                   │    - EXIF 추출    │
     │                 │                   │                   │
     │                 │ 8. Turbo Stream   │                   │
     │                 │    (새 사진 추가)  │                   │
     │                 │◄──────────────────│                   │
     │                 │                   │                   │
     │ 9. UI 업데이트   │                   │                   │
     │◄────────────────│                   │                   │
     │                 │                   │                   │
     │                 │ 10. 가족에게 푸시  │                   │
     │                 │◄──────────────────│                   │
```

### 6.2 가족 초대 흐름

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Inviter │     │  Rails  │     │ Invitee │     │   App   │
│ (엄마)  │     │ Server  │     │ (할머니) │     │  Store  │
└────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
     │               │               │               │
     │ 1. 초대하기    │               │               │
     │──────────────►│               │               │
     │               │               │               │
     │ 2. 초대 링크   │               │               │
     │   생성        │               │               │
     │◄──────────────│               │               │
     │               │               │               │
     │ 3. 카카오톡 공유│               │               │
     │──────────────────────────────►│               │
     │               │               │               │
     │               │ 4. 링크 클릭   │               │
     │               │◄──────────────│               │
     │               │               │               │
     │               │ 5. 앱 미설치시 │               │
     │               │──────────────────────────────►│
     │               │               │               │
     │               │               │ 6. 앱 설치    │
     │               │               │◄──────────────│
     │               │               │               │
     │               │ 7. 딥링크로    │               │
     │               │    앱 실행    │               │
     │               │◄──────────────│               │
     │               │               │               │
     │               │ 8. 소셜 로그인 │               │
     │               │◄──────────────│               │
     │               │               │               │
     │               │ 9. 가족 참여   │               │
     │               │    완료       │               │
     │               │──────────────►│               │
     │               │               │               │
     │ 10. 알림      │               │               │
     │◄──────────────│               │               │
```

### 6.3 실시간 알림 흐름 (Action Cable)

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  User A │     │   Rails     │     │ Action Cable│     │   User B    │
│  (아빠) │     │   Server    │     │ (Solid Cable)│    │   (엄마)    │
└────┬────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
     │                 │                   │                   │
     │                 │                   │ 1. Subscribe      │
     │                 │                   │   family_channel  │
     │                 │                   │◄──────────────────│
     │                 │                   │                   │
     │ 2. 사진 업로드   │                   │                   │
     │────────────────►│                   │                   │
     │                 │                   │                   │
     │                 │ 3. Broadcast      │                   │
     │                 │──────────────────►│                   │
     │                 │                   │                   │
     │                 │                   │ 4. Turbo Stream   │
     │                 │                   │   (새 사진)       │
     │                 │                   │──────────────────►│
     │                 │                   │                   │
     │                 │                   │ 5. UI 실시간 반영  │
     │                 │                   │                   │
```

---

## 7. 인프라 구성

### 7.1 배포 전략: 단계별 성장

> **원칙**: 가족 사용부터 시작 → 검증 후 확장

```
Phase 1 (가족)     Phase 2 (친구들)    Phase 3 (퍼블릭)
─────────────────────────────────────────────────────
Railway 무료/Pro   Railway Pro         VPS or K8s
$0~5/월           $20~50/월           $100+/월
```

### 7.2 Phase 1: Railway (현재 목표)

```
┌─────────────────────────────────────────────────────┐
│                    Railway                           │
│                                                      │
│  ┌─────────────────────────────────────────────┐    │
│  │              Rails App                       │    │
│  │                                              │    │
│  │  - Puma (Web Server)                        │    │
│  │  - Solid Queue (Background Jobs)            │    │
│  │  - Solid Cable (WebSocket)                  │    │
│  │                                              │    │
│  └──────────────────┬──────────────────────────┘    │
│                     │                                │
│           ┌─────────┴─────────┐                     │
│           │                   │                     │
│  ┌────────▼────────┐ ┌───────▼────────┐            │
│  │   PostgreSQL    │ │   Volume       │            │
│  │   (Add-on)      │ │   (Storage)    │            │
│  │   무료 500MB    │ │   또는 S3      │            │
│  └─────────────────┘ └────────────────┘            │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 7.3 Railway 설정

```toml
# railway.toml
[build]
builder = "dockerfile"

[deploy]
startCommand = "bundle exec puma -C config/puma.rb"
healthcheckPath = "/up"
healthcheckTimeout = 100
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 3
```

```yaml
# Procfile (대안)
web: bundle exec puma -C config/puma.rb
worker: bundle exec rake solid_queue:start
```

### 7.4 Railway 환경 변수

```bash
# Railway Dashboard에서 설정
RAILS_ENV=production
RAILS_MASTER_KEY=xxxxx
DATABASE_URL=postgresql://...  # Railway가 자동 주입
SECRET_KEY_BASE=xxxxx

# 스토리지 (Phase 1: 로컬 볼륨)
ACTIVE_STORAGE_SERVICE=local

# 스토리지 (Phase 2: S3 호환)
# AWS_ACCESS_KEY_ID=xxxxx
# AWS_SECRET_ACCESS_KEY=xxxxx
# AWS_BUCKET=moabom-photos
# AWS_REGION=ap-northeast-2
```

### 7.5 스토리지 전략

| Phase | 방식 | 용량 | 비용 |
|-------|------|------|------|
| **1. 가족** | Railway Volume | 1GB | 무료 |
| **2. 확장** | Cloudflare R2 | 10GB | ~$0.50/월 |
| **3. 성장** | S3 + CloudFront | 무제한 | 사용량 기반 |

### 7.6 단계별 스케일링

```
┌─────────────────────────────────────────────────────────────────┐
│                     성장 단계별 인프라                           │
├──────────┬──────────────┬─────────────┬────────────────────────┤
│  단계    │  사용자      │  인프라      │  예상 비용             │
├──────────┼──────────────┼─────────────┼────────────────────────┤
│ Phase 1  │ ~10명        │ Railway     │ $0~5/월               │
│ 가족     │ (우리 가족)   │ (무료 티어)  │ Hobby Plan            │
├──────────┼──────────────┼─────────────┼────────────────────────┤
│ Phase 2  │ ~100명       │ Railway Pro │ $20~50/월             │
│ 친구들   │              │ + R2        │                        │
├──────────┼──────────────┼─────────────┼────────────────────────┤
│ Phase 3  │ ~1,000명     │ Railway Pro │ $50~100/월            │
│ 초기 유저│              │ + S3 + CDN  │                        │
├──────────┼──────────────┼─────────────┼────────────────────────┤
│ Phase 4  │ 10,000+명    │ VPS/K8s     │ $200+/월              │
│ 스케일   │              │ 마이그레이션 │ (이 시점에 수익화)     │
└──────────┴──────────────┴─────────────┴────────────────────────┘
```

### 7.7 Railway 장점 (MVP에 적합)

| 장점 | 설명 |
|-----|------|
| **간편한 배포** | `git push`만으로 자동 배포 |
| **무료 시작** | 월 $5 크레딧 (Hobby), 충분함 |
| **PostgreSQL 내장** | 별도 설정 불필요 |
| **자동 SSL** | HTTPS 자동 설정 |
| **쉬운 환경변수** | Dashboard에서 클릭으로 설정 |
| **로그/모니터링** | 기본 제공 |

### 7.8 마이그레이션 전략

Railway에서 시작 → 사용자 증가 시 VPS로 마이그레이션

```bash
# Phase 4 마이그레이션 시 (10,000+ 사용자)
# 1. Hetzner VPS 또는 DigitalOcean으로 이전
# 2. Kamal 2로 Docker 배포
# 3. Managed PostgreSQL 사용
# 4. Cloudflare CDN 추가
```

**지금은 Railway로 충분합니다!**

---

## 8. 보안 아키텍처

### 8.1 인증 흐름

```
┌─────────────────────────────────────────────────────────────────┐
│                       Authentication Flow                        │
└─────────────────────────────────────────────────────────────────┘

1. 소셜 로그인 (OAuth 2.0)
   ┌──────┐     ┌─────────┐     ┌──────────┐     ┌─────────────┐
   │ User │────►│  App    │────►│  Rails   │────►│ OAuth       │
   │      │     │         │     │  Server  │     │ Provider    │
   │      │     │         │     │          │     │(Kakao/Apple)│
   └──────┘     └─────────┘     └──────────┘     └─────────────┘
       │                             │                   │
       │                             │ 1. Redirect       │
       │                             │──────────────────►│
       │                             │                   │
       │             2. 사용자 인증   │                   │
       │◄────────────────────────────────────────────────│
       │                             │                   │
       │ 3. 인증 완료                 │                   │
       │────────────────────────────►│                   │
       │                             │                   │
       │                             │ 4. Token Exchange │
       │                             │◄──────────────────│
       │                             │                   │
       │                             │ 5. 사용자 정보 조회│
       │                             │──────────────────►│
       │                             │                   │
       │                             │ 6. User 생성/조회  │
       │                             │                   │
       │ 7. Session 생성             │                   │
       │◄────────────────────────────│                   │

2. 세션 관리
   - Rails Session (encrypted cookie)
   - 30일 유효기간
   - Remember me 옵션
```

### 8.2 권한 매트릭스

```ruby
# app/models/family_membership.rb
class FamilyMembership < ApplicationRecord
  ROLES = {
    owner: {
      can_upload: true,
      can_delete_any: true,
      can_invite: true,
      can_manage_members: true,
      can_delete_family: true
    },
    admin: {
      can_upload: true,
      can_delete_any: true,
      can_invite: true,
      can_manage_members: true,
      can_delete_family: false
    },
    member: {
      can_upload: true,
      can_delete_own: true,
      can_invite: false,
      can_manage_members: false,
      can_delete_family: false
    },
    viewer: {
      can_upload: false,
      can_delete_own: false,
      can_invite: false,
      can_manage_members: false,
      can_delete_family: false
    }
  }.freeze
end
```

### 8.3 데이터 보안

| 항목 | 방식 | 구현 |
|-----|------|------|
| **전송 암호화** | TLS 1.3 | Cloudflare + Let's Encrypt |
| **저장 암호화** | AES-256 | S3 Server-Side Encryption |
| **세션 암호화** | Rails Encrypted Cookie | Rails 기본 |
| **비밀 관리** | Rails Credentials | `credentials.yml.enc` |
| **API 인증** | Session (WebView) | 쿠키 기반 |

### 8.4 보안 헤더

```ruby
# config/initializers/secure_headers.rb
Rails.application.config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff',
  'X-Download-Options' => 'noopen',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

---

## 9. 모니터링 및 로깅

### 9.1 모니터링 스택

```
┌─────────────────────────────────────────────────────────────────┐
│                      Monitoring Stack                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Sentry    │  │  Rails      │  │     Cloudflare          │  │
│  │             │  │  Logs       │  │     Analytics           │  │
│  │ - Errors    │  │             │  │                         │  │
│  │ - Perf      │  │ - Request   │  │ - Traffic               │  │
│  │ - Traces    │  │ - SQL       │  │ - Cache hit rate        │  │
│  │             │  │ - Jobs      │  │ - Security events       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 핵심 메트릭

| 카테고리 | 메트릭 | 임계값 |
|---------|-------|-------|
| **성능** | 응답시간 (p95) | < 500ms |
| **성능** | Apdex Score | > 0.9 |
| **에러** | Error Rate | < 0.1% |
| **가용성** | Uptime | > 99.9% |
| **인프라** | CPU 사용률 | < 70% |
| **인프라** | 메모리 사용률 | < 80% |
| **비즈니스** | 일일 업로드 수 | 모니터링 |

---

## 10. 확장성 고려사항

### 10.1 현재 설계의 확장 포인트

| 영역 | 현재 | 확장 시 |
|-----|------|--------|
| **웹 서버** | Puma (단일) | Puma (다중 인스턴스) + LB |
| **데이터베이스** | PostgreSQL (단일) | Read Replica 추가 |
| **캐시** | Solid Cache | Redis Cluster |
| **큐** | Solid Queue | Sidekiq + Redis |
| **스토리지** | S3/R2 | 이미 확장 가능 |
| **CDN** | Cloudflare | 이미 확장 가능 |

### 10.2 성능 최적화 전략

```ruby
# 1. 데이터베이스 쿼리 최적화
class Photo < ApplicationRecord
  # N+1 방지
  scope :with_associations, -> { includes(:user, :comments, :reactions) }

  # 페이지네이션
  scope :paginated, ->(page, per = 20) { offset((page - 1) * per).limit(per) }
end

# 2. 캐시 전략
class Family < ApplicationRecord
  def cached_photo_count
    Rails.cache.fetch("family:#{id}:photo_count", expires_in: 1.hour) do
      photos.count
    end
  end
end

# 3. 이미지 최적화
class Photo < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :medium, resize_to_limit: [800, 800]
    attachable.variant :large, resize_to_limit: [1600, 1600]
  end
end
```

---

## 11. 개발 가이드라인

### 11.1 코드 구조 규칙

```
1. Controller: 얇게 유지, 비즈니스 로직은 Service로
2. Model: 데이터 검증과 관계만, 복잡한 로직은 Service로
3. Service: 비즈니스 로직 캡슐화
4. Job: 비동기 작업 처리
5. View: Hotwire 활용, 최소한의 JS
```

### 11.2 네이밍 규칙

```ruby
# Controller
PhotosController          # 복수형
Native::UploadsController # 네임스페이스

# Model
Photo                     # 단수형
FamilyMembership          # 조인 테이블

# Service
Photos::Uploader          # 네임스페이스::동사
Auth::KakaoOauth

# Job
PhotoProcessingJob        # 동사+Job
PushNotificationJob
```

### 11.3 테스트 전략

```
tests/
├── models/           # 단위 테스트
├── controllers/      # 요청 테스트
├── system/           # E2E 테스트 (Capybara)
├── services/         # 서비스 테스트
└── jobs/             # Job 테스트
```

---

## 12. 다음 단계

1. [ ] Rails 프로젝트 생성 (`rails new moabom`)
2. [ ] 데이터베이스 마이그레이션 작성
3. [ ] 기본 모델 및 관계 설정
4. [ ] 인증 시스템 구현 (OmniAuth)
5. [ ] Turbo Native iOS/Android 프로젝트 생성
