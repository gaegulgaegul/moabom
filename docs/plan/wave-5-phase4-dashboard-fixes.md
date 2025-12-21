# Wave 5 Phase 4: 대시보드 네비게이션 수정

> 대시보드 업로드 버튼 및 알림 버튼 동작 수정
> 작성일: 2025-12-21

---

## 개요

대시보드 화면에서 발견된 네비게이션 문제를 수정합니다:
1. 업로드 버튼(FAB) 클릭 시 사진 업로드 화면으로 이동
2. 알림 버튼 클릭 시 알림 목록 화면으로 이동

---

## 목표

- [x] 업로드 버튼을 사진 업로드 화면으로 연결
- [ ] 알림 목록 컨트롤러 및 뷰 구현
- [ ] 헤더/탭바 알림 버튼을 알림 목록으로 연결

---

## 작업 1: 업로드 버튼 수정

### RED: 테스트 작성

- [ ] **RED**: 탭바 업로드 버튼 클릭 시 사진 업로드 화면 이동 시스템 테스트 작성

```ruby
# test/system/dashboard_navigation_test.rb
test "should navigate to photo upload when clicking upload button" do
  sign_in_as @user
  visit dashboard_path

  # 탭바의 업로드 버튼 클릭
  find('a[aria-label="사진 업로드"]').click

  # 사진 업로드 화면으로 이동 확인
  assert_current_path new_family_photo_path(@family)
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: 탭바 partial에서 업로드 버튼 링크 수정

```erb
# app/views/shared/_tabbar.html.erb
<!-- 업로드 (FAB) -->
<%= link_to new_family_photo_path(current_family),
            class: "flex items-center justify-center -mt-4 tap-highlight-none",
            "aria-label": "사진 업로드" do %>
  <div class="w-14 h-14 bg-primary-500 rounded-full flex items-center justify-center
              shadow-lg shadow-primary-500/30
              hover:bg-primary-600 active:bg-primary-700
              transition-colors duration-200">
    <%= heroicon "plus", variant: :solid, options: { class: "w-7 h-7 text-white" } %>
  </div>
<% end %>
```

- [ ] **GREEN**: 라우트 확인 (이미 존재함)
  - `POST /families/:family_id/photos` 경로 사용

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: current_family 헬퍼 사용 검증
  - nil 체크 추가 필요 시 구현

---

## 작업 2: 알림 목록 기능 구현

### RED: 테스트 작성

- [ ] **RED**: 알림 목록 컨트롤러 테스트 작성

```ruby
# test/controllers/notifications_controller_test.rb
require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    sign_in_as @user
  end

  test "should get index" do
    get notifications_path
    assert_response :success
  end
end
```

- [ ] **RED**: 알림 목록 네비게이션 시스템 테스트 작성

```ruby
# test/system/dashboard_navigation_test.rb
test "should navigate to notifications from header bell icon" do
  sign_in_as @user
  visit dashboard_path

  # 헤더의 알림 버튼 클릭
  find('button[aria-label="알림"]').click

  # 알림 목록 화면으로 이동 확인
  assert_current_path notifications_path
end

test "should navigate to notifications from tabbar" do
  sign_in_as @user
  visit dashboard_path

  # 탭바의 알림 탭 클릭
  within('nav') do
    click_link "알림"
  end

  # 알림 목록 화면으로 이동 확인
  assert_current_path notifications_path
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: 알림 목록 라우트 추가

```ruby
# config/routes.rb
resources :notifications, only: [ :index ]
```

- [ ] **GREEN**: 알림 컨트롤러 생성

```ruby
# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_onboarding!

  def index
    # Phase 6에서 실제 알림 데이터 구현 예정
    # 현재는 빈 목록 표시
    @notifications = []
  end
end
```

- [ ] **GREEN**: 알림 목록 뷰 생성

```erb
# app/views/notifications/index.html.erb
<div class="px-4 py-6">
  <h1 class="text-2xl font-bold text-warm-gray-800 mb-6">알림</h1>

  <% if @notifications.empty? %>
    <!-- 빈 상태 -->
    <div class="flex flex-col items-center justify-center py-16 text-center">
      <%= heroicon "bell", variant: :outline, options: { class: "w-16 h-16 text-warm-gray-300" } %>
      <h3 class="mt-4 text-lg font-medium text-warm-gray-800">알림이 없습니다</h3>
      <p class="mt-2 text-sm text-warm-gray-500">새로운 소식이 있으면 알려드릴게요.</p>
    </div>
  <% else %>
    <!-- 알림 목록 (Phase 6에서 구현) -->
  <% end %>
</div>
```

- [ ] **GREEN**: 헤더 알림 버튼을 링크로 변경

```erb
# app/views/shared/_header.html.erb
<!-- 알림 -->
<%= link_to notifications_path,
            class: "relative p-2 rounded-full hover:bg-cream-100 tap-highlight-none",
            aria_label: "알림" do %>
  <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
  <span class="absolute top-1 right-1 w-2 h-2 bg-accent-500 rounded-full" aria-label="새 알림"></span>
<% end %>
```

- [ ] **GREEN**: 탭바 알림 탭을 링크로 변경

```erb
# app/views/shared/_tabbar.html.erb
<!-- 알림 -->
<%= link_to notifications_path,
            class: "tab-item #{current_page?(notifications_path) ? 'tab-item-active' : ''}" do %>
  <%= heroicon "bell",
      variant: current_page?(notifications_path) ? :solid : :outline,
      options: { class: "w-6 h-6" } %>
  <span class="text-xs mt-1">알림</span>
<% end %>
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: 헬퍼 메서드 업데이트

```ruby
# app/helpers/application_helper.rb
def current_page_tab?(tab_name)
  case tab_name
  when :home
    current_page?(root_path) || controller_path == "dashboard"
  when :albums
    false # 앨범 기능은 Phase 5에서 구현
  when :upload
    false # 업로드 기능은 Phase 4에서 구현
  when :notifications
    controller_name == "notifications" # 수정됨
  when :settings
    controller.class.module_parent_name == "Settings"
  else
    false
  end ? "text-pink-500" : "text-gray-600"
end
```

---

## 검증 체크리스트

### 기능 테스트
- [ ] 탭바 업로드 버튼 클릭 시 사진 업로드 화면으로 이동
- [ ] 헤더 알림 버튼 클릭 시 알림 목록 화면으로 이동
- [ ] 탭바 알림 탭 클릭 시 알림 목록 화면으로 이동
- [ ] 알림 목록 화면에서 빈 상태 UI 표시
- [ ] 현재 페이지에 따라 탭바 활성 상태 표시

### 코드 품질
- [ ] `rails test` - 모든 테스트 통과
- [ ] `rubocop` - Lint 에러 없음
- [ ] 디버그 코드 제거 (puts, binding.pry)
- [ ] 주석 처리된 코드 제거

### 설계 문서 확인
- [ ] PRD.md의 네비게이션 요구사항 충족
- [ ] API_DESIGN.md의 엔드포인트 규격 준수
- [ ] ARCHITECTURE.md의 레이어 책임 준수
- [ ] DESIGN_GUIDE.md의 컴포넌트 스타일 준수

---

## 참고사항

- Phase 6에서 실제 알림 데이터(Notification 모델, 실시간 알림 등) 구현 예정
- 현재는 UI 네비게이션 연결에 집중
- 알림 배지(새 알림 표시)는 하드코딩된 상태로 유지 (Phase 6에서 동적 처리)

---

## 커밋 전략

1. **작업 1 커밋**: `feat(dashboard): 탭바 업로드 버튼 사진 업로드 화면 연결`
2. **작업 2 커밋**: `feat(notifications): 알림 목록 기본 화면 구현 및 네비게이션 연결`
