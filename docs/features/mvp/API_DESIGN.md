# 모아봄 API 설계서

> 버전: 1.0 (MVP)
> 작성일: 2025-12-14
> 기준: Rails 8 + Hotwire + Turbo Native

---

## 1. API 개요

### 1.1 API 스타일

모아봄은 **Hotwire 기반 하이브리드** 방식을 사용합니다.

| 클라이언트 | 응답 형식 | 설명 |
|-----------|----------|------|
| 웹 브라우저 | HTML (Turbo Frame/Stream) | 서버 렌더링 |
| Turbo Native | HTML (WebView) | 웹과 동일 |
| Native 브릿지 | JSON | 카메라, 푸시 등 네이티브 기능 |

### 1.2 Base URL

```
Production: https://moabom.com
Staging:    https://staging.moabom.com
Development: http://localhost:3000
```

### 1.3 인증 방식

```
웹/Turbo Native: Session Cookie (Rails 기본)
Native 브릿지:   Bearer Token (JWT)
```

### 1.4 공통 헤더

```http
# 모든 요청
Accept: text/html, application/json
Content-Type: application/json (POST/PUT/PATCH)
X-CSRF-Token: {csrf_token}

# Turbo Native 식별
User-Agent: Turbo Native iOS/1.0 (또는 Android)

# Native 브릿지 (JSON API)
Authorization: Bearer {jwt_token}
Accept: application/json
```

---

## 2. 인증 API

### 2.1 소셜 로그인

#### OAuth 시작
```
GET /auth/{provider}
```

| Provider | 값 |
|----------|---|
| 카카오 | `kakao` |
| 애플 | `apple` |
| 구글 | `google` |

**예시:**
```
GET /auth/kakao
→ 302 Redirect to Kakao OAuth
```

#### OAuth 콜백
```
GET /auth/{provider}/callback
```

**성공 시:**
```
→ 302 Redirect to /
→ Set-Cookie: _moabom_session=xxx
```

**신규 사용자 시:**
```
→ 302 Redirect to /onboarding/profile
```

---

### 2.2 세션 관리

#### 현재 사용자 정보
```
GET /api/me
```

**Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "nickname": "엄마",
  "avatar_url": "https://...",
  "current_family_id": 1,
  "families": [
    {
      "id": 1,
      "name": "우리 가족",
      "role": "owner"
    }
  ]
}
```

#### 로그아웃
```
DELETE /logout
```

**Response:**
```
→ 302 Redirect to /login
→ Clear session cookie
```

---

### 2.3 기기 등록 (푸시 알림용)

#### 기기 등록/업데이트
```
POST /api/devices
```

**Request:**
```json
{
  "device": {
    "platform": "ios",
    "push_token": "abc123...",
    "device_name": "iPhone 15 Pro",
    "app_version": "1.0.0",
    "os_version": "17.0"
  }
}
```

**Response (201):**
```json
{
  "id": 1,
  "platform": "ios",
  "registered_at": "2025-01-01T00:00:00Z"
}
```

#### 기기 삭제 (로그아웃 시)
```
DELETE /api/devices/{id}
```

---

## 3. 온보딩 API

### 3.1 프로필 생성

#### 사용자 프로필 설정
```
POST /onboarding/profile
```

**Request (multipart/form-data):**
```
user[nickname]: "엄마"
user[avatar]: (file)
```

**Response:**
```
→ 302 Redirect to /onboarding/child
```

---

### 3.2 아이 프로필 생성

#### 첫 아이 등록
```
POST /onboarding/child
```

**Request (multipart/form-data):**
```
child[name]: "하늘이"
child[birthdate]: "2023-06-15"
child[gender]: "female"
child[relation]: "mom"
child[avatar]: (file)
```

**Response:**
```
→ 302 Redirect to /onboarding/invite
```

---

## 4. 가족 관리 API

### 4.1 가족 그룹

#### 현재 가족 정보
```
GET /families/{id}
```

**Response (HTML - Turbo Frame):**
```html
<turbo-frame id="family_info">
  <h1>우리 가족</h1>
  <div class="members">...</div>
</turbo-frame>
```

#### 가족 이름 수정
```
PATCH /families/{id}
```

**Request:**
```json
{
  "family": {
    "name": "하늘이네 가족"
  }
}
```

---

### 4.2 가족 구성원

#### 구성원 목록
```
GET /families/{family_id}/members
```

**Response (HTML):**
```html
<turbo-frame id="members">
  <div class="member" data-role="owner">
    <img src="..." />
    <span>엄마</span>
    <span class="role">관리자</span>
  </div>
  ...
</turbo-frame>
```

#### 구성원 역할 변경
```
PATCH /families/{family_id}/members/{id}
```

**Request:**
```json
{
  "membership": {
    "role": "admin"
  }
}
```

| role | 설명 |
|------|------|
| `owner` | 소유자 (1명만) |
| `admin` | 관리자 |
| `member` | 멤버 |
| `viewer` | 뷰어 |

#### 구성원 내보내기
```
DELETE /families/{family_id}/members/{id}
```

---

### 4.3 초대

#### 초대 링크 생성
```
POST /families/{family_id}/invitations
```

**Request:**
```json
{
  "invitation": {
    "role": "viewer"
  }
}
```

**Response (201):**
```json
{
  "id": 1,
  "token": "abc123xyz",
  "invite_url": "https://moabom.com/i/abc123xyz",
  "expires_at": "2025-01-08T00:00:00Z",
  "role": "viewer"
}
```

#### 초대 수락
```
GET /i/{token}
```

**로그인 상태:**
```
→ 302 Redirect to /families/{id} (가족 참여 완료)
```

**비로그인 상태:**
```
→ 302 Redirect to /login?invitation={token}
```

#### 초대 취소
```
DELETE /families/{family_id}/invitations/{id}
```

---

## 5. 아이 프로필 API

### 5.1 아이 목록

```
GET /families/{family_id}/children
```

**Response (HTML):**
```html
<turbo-frame id="children">
  <div class="child">
    <img src="..." />
    <span>하늘이</span>
    <span class="age">18개월</span>
  </div>
</turbo-frame>
```

### 5.2 아이 추가

```
POST /families/{family_id}/children
```

**Request (multipart/form-data):**
```
child[name]: "바다"
child[birthdate]: "2024-03-20"
child[gender]: "male"
child[avatar]: (file)
```

**Response (Turbo Stream):**
```html
<turbo-stream action="append" target="children">
  <template>
    <div class="child">...</div>
  </template>
</turbo-stream>
```

### 5.3 아이 수정

```
PATCH /families/{family_id}/children/{id}
```

### 5.4 아이 삭제

```
DELETE /families/{family_id}/children/{id}
```

---

## 6. 사진 API (MVP 핵심)

### 6.1 타임라인 조회

#### 사진 목록 (무한 스크롤)
```
GET /families/{family_id}/photos
```

**Query Parameters:**
| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|-------|------|
| `page` | integer | 1 | 페이지 번호 |
| `per` | integer | 50 | 페이지당 개수 |
| `year` | integer | - | 연도 필터 |
| `month` | integer | - | 월 필터 |
| `child_id` | integer | - | 아이별 필터 |

**Response (HTML - Turbo Frame):**
```html
<turbo-frame id="photos" data-page="1">
  <div class="photo-grid">
    <div class="photo" data-id="1">
      <img src="..." loading="lazy" />
    </div>
    ...
  </div>

  <!-- 다음 페이지 로딩 트리거 -->
  <turbo-frame id="photos_page_2" src="/families/1/photos?page=2" loading="lazy">
  </turbo-frame>
</turbo-frame>
```

#### 사진 상세
```
GET /families/{family_id}/photos/{id}
```

**Response (HTML):**
```html
<div class="photo-detail">
  <img src="..." />
  <div class="meta">
    <span class="date">2025년 1월 1일</span>
    <span class="uploader">엄마</span>
  </div>
  <div class="reactions">...</div>
  <div class="comments">...</div>
</div>
```

---

### 6.2 사진 업로드

#### Direct Upload URL 요청 (Active Storage)
```
POST /rails/active_storage/direct_uploads
```

**Request:**
```json
{
  "blob": {
    "filename": "IMG_1234.jpg",
    "content_type": "image/jpeg",
    "byte_size": 2048576,
    "checksum": "abc123..."
  }
}
```

**Response (201):**
```json
{
  "id": 1,
  "key": "abc123xyz",
  "filename": "IMG_1234.jpg",
  "content_type": "image/jpeg",
  "byte_size": 2048576,
  "checksum": "abc123...",
  "direct_upload": {
    "url": "https://s3.amazonaws.com/...",
    "headers": {
      "Content-Type": "image/jpeg",
      "Content-MD5": "abc123..."
    }
  },
  "signed_id": "eyJfcmFpbHMi..."
}
```

#### 사진 레코드 생성
```
POST /families/{family_id}/photos
```

**Request:**
```json
{
  "photo": {
    "image": "eyJfcmFpbHMi...",  // signed_id
    "taken_at": "2025-01-01T10:30:00Z",
    "caption": "첫 걸음!",
    "child_id": 1
  }
}
```

**Response (201 - Turbo Stream):**
```html
<turbo-stream action="prepend" target="photos">
  <template>
    <div class="photo" data-id="123">
      <img src="..." />
    </div>
  </template>
</turbo-stream>
```

#### 대량 업로드 (Batch)
```
POST /families/{family_id}/photos/batch
```

**Request:**
```json
{
  "photos": [
    {
      "image": "signed_id_1",
      "taken_at": "2025-01-01T10:30:00Z",
      "child_id": 1
    },
    {
      "image": "signed_id_2",
      "taken_at": "2025-01-01T10:31:00Z",
      "child_id": 1
    }
  ]
}
```

**Response (201):**
```json
{
  "created": 2,
  "failed": 0,
  "photo_ids": [123, 124]
}
```

---

### 6.3 사진 수정/삭제

#### 사진 수정
```
PATCH /families/{family_id}/photos/{id}
```

**Request:**
```json
{
  "photo": {
    "caption": "수정된 캡션",
    "child_id": 2
  }
}
```

#### 사진 삭제
```
DELETE /families/{family_id}/photos/{id}
```

**Response (Turbo Stream):**
```html
<turbo-stream action="remove" target="photo_123">
</turbo-stream>
```

---

## 7. 반응/댓글 API

### 7.1 반응

#### 반응 추가/변경
```
POST /photos/{photo_id}/reactions
```

**Request:**
```json
{
  "reaction": {
    "emoji": "❤️"
  }
}
```

| emoji | 의미 |
|-------|------|
| ❤️ | 좋아요 |
| 😍 | 너무 귀여워 |
| 😂 | 웃겨 |
| 🥺 | 감동 |
| 👏 | 대단해 |

**Response (Turbo Stream):**
```html
<turbo-stream action="replace" target="reactions_photo_123">
  <template>
    <div id="reactions_photo_123" class="reactions">
      <span>❤️ 3</span>
      <span>😍 2</span>
    </div>
  </template>
</turbo-stream>
```

#### 반응 취소
```
DELETE /photos/{photo_id}/reactions
```

---

### 7.2 댓글

#### 댓글 목록
```
GET /photos/{photo_id}/comments
```

#### 댓글 작성
```
POST /photos/{photo_id}/comments
```

**Request:**
```json
{
  "comment": {
    "body": "너무 귀엽다!"
  }
}
```

**Response (Turbo Stream):**
```html
<turbo-stream action="append" target="comments_photo_123">
  <template>
    <div class="comment" id="comment_456">
      <img src="..." class="avatar" />
      <span class="author">할머니</span>
      <p>너무 귀엽다!</p>
      <span class="time">방금 전</span>
    </div>
  </template>
</turbo-stream>
```

#### 댓글 삭제
```
DELETE /photos/{photo_id}/comments/{id}
```

---

## 8. Native 브릿지 API

Turbo Native에서 네이티브 기능 호출 시 사용하는 JSON API입니다.

### 8.1 사진 업로드 (Native)

Native 앱에서 카메라/갤러리로 사진 선택 후 업로드

```
POST /api/native/photos
```

**Request (multipart/form-data):**
```
photos[]: (file1)
photos[]: (file2)
family_id: 1
child_id: 1
```

**Response (201):**
```json
{
  "success": true,
  "created": 2,
  "photos": [
    {
      "id": 123,
      "thumbnail_url": "https://..."
    },
    {
      "id": 124,
      "thumbnail_url": "https://..."
    }
  ],
  "redirect_url": "/families/1/photos"
}
```

---

### 8.2 푸시 토큰 등록

```
POST /api/native/push_token
```

**Request:**
```json
{
  "token": "abc123...",
  "platform": "ios"
}
```

---

### 8.3 앱 상태 동기화

앱 시작 시 필요한 정보 일괄 조회

```
GET /api/native/sync
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "nickname": "엄마",
    "avatar_url": "..."
  },
  "current_family": {
    "id": 1,
    "name": "우리 가족",
    "role": "owner",
    "unread_count": 5
  },
  "children": [
    {
      "id": 1,
      "name": "하늘이",
      "age_months": 18,
      "avatar_url": "..."
    }
  ],
  "settings": {
    "notifications_enabled": true,
    "auto_upload": "wifi_only"
  }
}
```

---

## 9. 설정 API

### 9.1 알림 설정

```
PATCH /settings/notifications
```

**Request:**
```json
{
  "notifications": {
    "new_photo": true,
    "reactions": true,
    "comments": true,
    "memories": true,
    "marketing": false
  }
}
```

### 9.2 앱 설정

```
PATCH /settings/app
```

**Request:**
```json
{
  "app": {
    "theme": "system",
    "auto_upload": "wifi_only",
    "storage_quality": "original"
  }
}
```

| auto_upload | 설명 |
|-------------|------|
| `off` | 자동 업로드 끔 |
| `wifi_only` | WiFi에서만 |
| `always` | 항상 |

---

## 10. 에러 응답

### 10.1 에러 형식

```json
{
  "error": {
    "code": "unauthorized",
    "message": "로그인이 필요합니다.",
    "details": {}
  }
}
```

### 10.2 HTTP 상태 코드

| 코드 | 의미 | 사용 |
|-----|------|------|
| 200 | OK | 성공 |
| 201 | Created | 생성 성공 |
| 204 | No Content | 삭제 성공 |
| 400 | Bad Request | 잘못된 요청 |
| 401 | Unauthorized | 인증 필요 |
| 403 | Forbidden | 권한 없음 |
| 404 | Not Found | 리소스 없음 |
| 422 | Unprocessable | 유효성 검사 실패 |
| 500 | Server Error | 서버 오류 |

### 10.3 유효성 검사 에러

```json
{
  "error": {
    "code": "validation_failed",
    "message": "입력값을 확인해주세요.",
    "details": {
      "name": ["이름을 입력해주세요."],
      "birthdate": ["생년월일을 입력해주세요."]
    }
  }
}
```

---

## 11. 라우트 요약

### 11.1 HTML (Turbo) 라우트

```ruby
# config/routes.rb

# 인증
get  "/auth/:provider", to: "oauth#start"
get  "/auth/:provider/callback", to: "oauth#callback"
delete "/logout", to: "sessions#destroy"

# 온보딩
resources :onboarding, only: [] do
  collection do
    get :profile
    post :profile
    get :child
    post :child
    get :invite
  end
end

# 가족
resources :families do
  resources :members, only: [:index, :update, :destroy]
  resources :invitations, only: [:create, :destroy]
  resources :children
  resources :photos do
    collection do
      post :batch
    end
    resources :reactions, only: [:create, :destroy]
    resources :comments, only: [:index, :create, :destroy]
  end
end

# 초대 수락
get "/i/:token", to: "invitations#accept"

# 설정
namespace :settings do
  resource :notifications, only: [:show, :update]
  resource :app, only: [:show, :update]
  resource :profile, only: [:show, :update]
end
```

### 11.2 JSON API 라우트

```ruby
namespace :api do
  get :me, to: "users#me"
  resources :devices, only: [:create, :destroy]

  namespace :native do
    post :photos
    post :push_token
    get :sync
  end
end
```

---

## 12. 다음 단계

- [ ] 화면 설계서 작성
- [ ] Rails 프로젝트 생성
- [ ] 라우트 설정
- [ ] 컨트롤러 구현
