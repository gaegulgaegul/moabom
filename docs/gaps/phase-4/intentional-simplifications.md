# 의도적 단순화 (Intentional Simplifications)

> MVP 범위로 축소한 기능 목록

---

## 1. OAuth 제공자

| 항목 | 내용 |
|-----|------|
| **현재 상태** | 카카오 로그인만 구현 |
| **PRD 요구사항** | 카카오, Apple, Google 로그인 |
| **개선 필요** | `omniauth-apple`, `omniauth-google-oauth2` 전략 추가 |
| **우선순위** | P2 |
| **관련 파일** | `config/initializers/omniauth.rb`, `lib/omniauth/strategies/kakao.rb` |

### 구현 시 고려사항
- Apple 로그인은 iOS 앱 출시 시 필수 (App Store 정책)
- Google 로그인은 Android 사용자 편의를 위해 권장

---

## 2. 초대 공유 방법

| 항목 | 내용 |
|-----|------|
| **현재 상태** | URL 복사 버튼만 제공 |
| **PRD 요구사항** | 카카오톡 공유, QR 코드, URL 복사 |
| **개선 필요** | Kakao SDK 연동, `rqrcode` gem 추가 |
| **우선순위** | P2 |
| **관련 파일** | `app/views/onboarding/invites/show.html.erb` |

### 구현 시 고려사항
```ruby
# Gemfile
gem 'rqrcode'  # QR 코드 생성

# Kakao SDK (JavaScript)
# app/javascript/controllers/kakao_share_controller.js
```

---

## 3. 알림 시스템

| 항목 | 내용 |
|-----|------|
| **현재 상태** | 미구현 (모델, 컨트롤러 없음) |
| **PRD 요구사항** | 푸시 알림, 인앱 알림 |
| **개선 필요** | Notification 모델, FCM/APNs 연동 |
| **우선순위** | P1 |
| **관련 파일** | 신규 생성 필요 |

### 구현 시 고려사항
- Device 모델은 이미 존재 (push_token 저장용)
- Solid Queue로 알림 발송 Job 처리

---

## 4. 검색 기능

| 항목 | 내용 |
|-----|------|
| **현재 상태** | 미구현 |
| **PRD 요구사항** | 사진 검색, 아이별 필터링 |
| **개선 필요** | 검색 UI, Photo 스코프 추가 |
| **우선순위** | P2 |
| **관련 파일** | `app/models/photo.rb` |

### 구현 시 고려사항
- 기본: `Photo.where("caption LIKE ?", "%#{query}%")`
- 고급: pg_search 또는 Elasticsearch (사용자 증가 시)

---

## 5. 앨범 기능

| 항목 | 내용 |
|-----|------|
| **현재 상태** | Album 모델 미구현 (PRD에만 언급) |
| **PRD 요구사항** | 앨범 생성, 사진 그룹핑 |
| **개선 필요** | Album 모델, AlbumsController |
| **우선순위** | P2 |
| **관련 파일** | 신규 생성 필요 |

### 구현 시 고려사항
- 월별 자동 앨범 vs 수동 앨범 생성
- Photo와 다대다 관계 (AlbumPhoto 조인 테이블)

---

## 6. 이용약관 동의

| 항목 | 내용 |
|-----|------|
| **현재 상태** | 미구현 |
| **PRD 요구사항** | 회원가입 시 이용약관, 개인정보처리방침 동의 |
| **개선 필요** | User에 `terms_agreed_at` 필드, 동의 페이지 |
| **우선순위** | P1 (법적 요구사항) |
| **관련 파일** | `app/models/user.rb`, 신규 뷰 |

### 구현 시 고려사항
```ruby
# 마이그레이션
add_column :users, :terms_agreed_at, :datetime
add_column :users, :privacy_agreed_at, :datetime
```

---

## 7. 프로필 아바타

| 항목 | 내용 |
|-----|------|
| **현재 상태** | `avatar_url` 필드만 존재 (OAuth에서 받은 URL 저장) |
| **PRD 요구사항** | 사용자 직접 아바타 업로드 |
| **개선 필요** | Active Storage 연동, 업로드 UI |
| **우선순위** | P1 |
| **관련 파일** | `app/models/user.rb` |

### 구현 시 고려사항
```ruby
# app/models/user.rb
has_one_attached :avatar

def avatar_display_url
  avatar.attached? ? avatar.url : avatar_url
end
```

---

## 요약

| 항목 | 우선순위 | MVP 필수 | 출시 후 |
|-----|---------|---------|--------|
| OAuth 제공자 확장 | P2 | | ✅ |
| 초대 공유 방법 확장 | P2 | | ✅ |
| 알림 시스템 | P1 | ✅ | |
| 검색 기능 | P2 | | ✅ |
| 앨범 기능 | P2 | | ✅ |
| 이용약관 동의 | P1 | ✅ | |
| 프로필 아바타 | P1 | ✅ | |
