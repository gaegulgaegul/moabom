# 미구현 항목 (Not Implemented)

> 건너뛴 기능이나 테스트

---

## 1. 컨트롤러

### 1.1 Families::PhotosController ❌

| 항목 | 내용 |
|-----|------|
| **상태** | 미구현 |
| **Phase** | Phase 5 |
| **우선순위** | **P0** (MVP 핵심) |

#### 필요한 액션
- `index` - 가족 사진 타임라인
- `show` - 사진 상세
- `new` / `create` - 사진 업로드
- `edit` / `update` - 캡션/아이 태그 수정
- `destroy` - 사진 삭제
- `batch` - 대량 업로드 (collection route)

#### 관련 파일 (생성 필요)
```
app/controllers/families/photos_controller.rb
app/views/families/photos/index.html.erb
app/views/families/photos/show.html.erb
app/views/families/photos/new.html.erb
app/views/families/photos/_form.html.erb
app/views/families/photos/_photo.html.erb
test/controllers/families/photos_controller_test.rb
```

---

### 1.2 Photos::ReactionsController ❌

| 항목 | 내용 |
|-----|------|
| **상태** | 미구현 |
| **Phase** | Phase 6 |
| **우선순위** | P1 |

#### 필요한 액션
- `create` - 반응 추가/변경
- `destroy` - 반응 삭제

#### Turbo Stream 응답 필요
```erb
<%# app/views/photos/reactions/create.turbo_stream.erb %>
<%= turbo_stream.replace "photo_#{@photo.id}_reactions" do %>
  <%= render "photos/reactions", photo: @photo %>
<% end %>
```

---

### 1.3 Photos::CommentsController ❌

| 항목 | 내용 |
|-----|------|
| **상태** | 미구현 |
| **Phase** | Phase 6 |
| **우선순위** | P1 |

#### 필요한 액션
- `index` - 댓글 목록 (Ajax/Turbo)
- `create` - 댓글 작성
- `destroy` - 댓글 삭제 (작성자만)

---

### 1.4 Settings::ProfilesController ❌

| 항목 | 내용 |
|-----|------|
| **상태** | 미구현 |
| **Phase** | Phase 7 |
| **우선순위** | P1 |

#### 필요한 액션
- `show` - 프로필 조회
- `update` - 프로필 수정 (닉네임, 아바타)

---

### 1.5 Settings::NotificationsController ❌

| 항목 | 내용 |
|-----|------|
| **상태** | 미구현 |
| **Phase** | Phase 7 |
| **우선순위** | P2 |

#### 필요한 액션
- `show` - 알림 설정 조회
- `update` - 알림 설정 변경

---

### 1.6 Api::Native::* ❌

| 항목 | 내용 |
|-----|------|
| **상태** | 미구현 |
| **Phase** | Phase 8 |
| **우선순위** | P2 |

#### 필요한 컨트롤러
- `SyncController` - 앱 시작 시 데이터 동기화
- `PushTokensController` - 푸시 토큰 등록/업데이트
- `PhotosController` - Native 사진 업로드 API

---

## 2. 모델 메서드 / 스코프

### 2.1 Photo 모델

| 항목 | 상태 | 우선순위 |
|-----|------|---------|
| `for_child(child)` 스코프 | ❌ 미구현 | P1 |
| `thumbnail_url` 메서드 | ❌ 미구현 | P1 |
| `medium_url` 메서드 | ❌ 미구현 | P2 |

#### 구현 예시
```ruby
# app/models/photo.rb
scope :for_child, ->(child) { where(child: child) }

def thumbnail_url
  return nil unless image.attached?
  Rails.application.routes.url_helpers.rails_blob_url(
    image.variant(resize_to_limit: [300, 300]).processed,
    only_path: true
  )
end
```

---

### 2.2 FamilyMembership 모델

| 항목 | 상태 | 우선순위 |
|-----|------|---------|
| `can_manage?` 메서드 | ❌ 미구현 | P1 |
| `can_upload?` 메서드 | ❌ 미구현 | P1 |
| `relation` enum | ❌ 미구현 | P2 |

#### 구현 예시
```ruby
# app/models/family_membership.rb
enum :relation, { parent: 0, grandparent: 1, uncle_aunt: 2, other: 3 }

def can_manage?
  role_owner? || role_admin?
end

def can_upload?
  role_owner? || role_admin? || role_member?
end
```

---

## 3. 뷰 파일

### 3.1 사진 관련 뷰 ❌

| 파일 | 상태 | 우선순위 |
|-----|------|---------|
| `photos/index.html.erb` | ❌ 미구현 | P0 |
| `photos/show.html.erb` | ❌ 미구현 | P0 |
| `photos/new.html.erb` | ❌ 미구현 | P1 |
| `photos/_form.html.erb` | ❌ 미구현 | P1 |
| `photos/_photo.html.erb` | ❌ 미구현 | P1 |

---

### 3.2 에러 페이지 ❌

| 파일 | 상태 | 우선순위 |
|-----|------|---------|
| `errors/404.html.erb` | ❌ 미구현 | P1 |
| `errors/500.html.erb` | ❌ 미구현 | P1 |
| `errors/403.html.erb` | ❌ 미구현 | P1 |

#### 구현 예시
```erb
<%# app/views/errors/404.html.erb %>
<div class="error-page">
  <h1>페이지를 찾을 수 없습니다</h1>
  <p>요청하신 페이지가 존재하지 않습니다.</p>
  <%= link_to "홈으로 돌아가기", root_path, class: "btn btn-primary" %>
</div>
```

---

### 3.3 레이아웃 컴포넌트 ❌

| 컴포넌트 | 상태 | 우선순위 |
|---------|------|---------|
| 하단 탭바 | ❌ 미구현 | P1 |
| 헤더 내비게이션 | 부분 구현 | P1 |
| 빈 상태 화면 | ❌ 미구현 | P2 |

---

## 4. 테스트

### 4.1 System Tests (E2E) ❌

| 테스트 | 상태 | 우선순위 |
|-------|------|---------|
| 로그인 → 온보딩 플로우 | ❌ 미구현 | P1 |
| 사진 업로드 플로우 | ❌ 미구현 | P1 |
| 초대 수락 플로우 | ❌ 미구현 | P1 |

#### 구현 예시
```ruby
# test/system/onboarding_flow_test.rb
class OnboardingFlowTest < ApplicationSystemTestCase
  test "새 사용자가 온보딩을 완료하고 대시보드에 도달한다" do
    visit root_path
    click_on "카카오로 시작하기"

    # 프로필 설정
    fill_in "닉네임", with: "테스트맘"
    click_on "다음"

    # 아이 등록
    fill_in "이름", with: "아기"
    fill_in "생년월일", with: "2024-01-01"
    click_on "등록"

    # 대시보드 확인
    assert_text "테스트맘의 가족"
  end
end
```

---

### 4.2 Controller Tests 누락

| 컨트롤러 | 상태 | 이유 |
|---------|------|-----|
| PhotosController | ❌ 미구현 | 컨트롤러 없음 |
| ReactionsController | ❌ 미구현 | 컨트롤러 없음 |
| CommentsController | ❌ 미구현 | 컨트롤러 없음 |

---

### 4.3 Model Tests 엣지 케이스

| 모델 | 누락된 테스트 | 우선순위 |
|-----|-------------|---------|
| Comment | 매우 긴 body 테스트 | P2 |
| Reaction | 잘못된 emoji 포맷 테스트 | P2 |
| Photo | 대용량 파일 테스트 | P1 |
| Invitation | 동시 수락 경합 테스트 | P2 |

---

## 요약

### 미구현 컨트롤러

| Phase | 컨트롤러 | 액션 수 | 우선순위 |
|-------|---------|--------|---------|
| 5 | PhotosController | 7 | P0 |
| 6 | ReactionsController | 2 | P1 |
| 6 | CommentsController | 3 | P1 |
| 7 | ProfilesController | 2 | P1 |
| 7 | NotificationsController | 2 | P2 |
| 8 | Api::Native::* | 5+ | P2 |

### 미구현 뷰

| 카테고리 | 파일 수 | 우선순위 |
|---------|--------|---------|
| 사진 관련 | 5+ | P0 |
| 에러 페이지 | 3 | P1 |
| 레이아웃 | 3 | P1 |

### 미구현 테스트

| 유형 | 예상 수 | 우선순위 |
|-----|--------|---------|
| System Tests | 10+ | P1 |
| Controller Tests (Photo) | 15+ | P0 |
| Edge Case Tests | 10+ | P2 |
