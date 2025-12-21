# Wave 5 Phase 5: 설정 화면 탭바 제거

> 설정 화면에서 하단 탭바 제거
> 작성일: 2025-12-21

---

## 개요

Wave 5 Phase 2에서 대시보드의 탭바를 제거했으나, 설정 화면에서는 여전히 탭바가 표시되고 있습니다. 설정 화면은 전체 화면을 활용하는 페이지로 탭바가 불필요하므로 제거합니다.

---

## 목표

- [ ] 설정 화면에서 하단 탭바 미표시
- [ ] 설정 화면 레이아웃 패딩 조정 (탭바 공간 제거)
- [ ] 탭바 표시 로직 테스트 추가

---

## 작업: 설정 화면 탭바 제거

### RED: 테스트 작성

- [ ] **RED**: 설정 화면 탭바 미표시 시스템 테스트 작성

```ruby
# test/system/settings_tabbar_test.rb
require "application_system_test_case"

class SettingsTabbarTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    sign_in_as @user
  end

  test "should not show bottom tabbar in settings pages" do
    # 프로필 설정 페이지
    visit settings_profile_path

    # 탭바가 표시되지 않아야 함
    assert_no_selector "nav.fixed.bottom-0"

    # 메인 콘텐츠가 탭바 공간 없이 패딩 적용
    assert_selector "main.pt-14:not(.pb-20)"
  end

  test "should not show bottom tabbar in notification settings" do
    # 알림 설정 페이지
    visit settings_notifications_path

    # 탭바가 표시되지 않아야 함
    assert_no_selector "nav.fixed.bottom-0"
  end

  test "should show back navigation in header" do
    visit settings_profile_path

    # 헤더에 뒤로가기 버튼이 있어야 함 (탭바 대신)
    assert_selector "a[aria-label='뒤로 가기'], button[aria-label='뒤로 가기']"
  end
end
```

- [ ] **RED**: 헬퍼 메서드 단위 테스트 작성

```ruby
# test/helpers/application_helper_test.rb
require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "show_bottom_tabbar returns false for settings pages" do
    # Settings::ProfileController 시뮬레이션
    @controller = Settings::ProfileController.new
    @controller.action_name = "show"

    assert_not show_bottom_tabbar?
  end

  test "show_bottom_tabbar returns false for settings notifications" do
    # Settings::NotificationsController 시뮬레이션
    @controller = Settings::NotificationsController.new
    @controller.action_name = "show"

    assert_not show_bottom_tabbar?
  end

  test "show_bottom_tabbar returns true for dashboard" do
    # DashboardController 시뮬레이션
    @controller = DashboardController.new
    @controller.action_name = "index"

    # 로그인된 상태 시뮬레이션
    def logged_in?
      true
    end

    assert show_bottom_tabbar?
  end
end
```

### GREEN: 최소 구현

- [ ] **GREEN**: `show_bottom_tabbar?` 헬퍼 메서드 수정

```ruby
# app/helpers/application_helper.rb
def show_bottom_tabbar?
  # 로그인하지 않은 경우 탭바 미표시
  return false unless logged_in?

  # 대시보드(홈)에서는 탭바 제거 (Wave 5 Phase 2)
  return false if controller_name == "home" && action_name == "index"

  # 온보딩 페이지에서는 탭바 미표시
  return false if controller_path.start_with?("onboarding/")

  # 설정 페이지에서는 탭바 미표시 (Wave 5 Phase 5)
  return false if controller_path.start_with?("settings/")

  # 세션 페이지에서는 탭바 미표시
  return false if controller_name == "sessions"

  true
end
```

### REFACTOR: 리팩토링

- [ ] **REFACTOR**: 헬퍼 메서드 주석 개선 및 그룹화

```ruby
# app/helpers/application_helper.rb
def show_bottom_tabbar?
  # 로그인하지 않은 경우 탭바 미표시
  return false unless logged_in?

  # 탭바를 표시하지 않는 페이지들
  excluded_paths = [
    "home",           # 대시보드 (Wave 5 Phase 2)
    "onboarding/",    # 온보딩 플로우
    "settings/",      # 설정 페이지 (Wave 5 Phase 5)
    "sessions"        # 로그인/로그아웃
  ]

  # 현재 컨트롤러 경로 체크
  return false if controller_name == "home" && action_name == "index"
  return false if excluded_paths.any? { |path| controller_path.start_with?(path) }
  return false if controller_name == "sessions"

  true
end
```

---

## 검증 체크리스트

### 기능 테스트
- [ ] 설정 프로필 페이지에서 탭바 미표시
- [ ] 설정 알림 페이지에서 탭바 미표시
- [ ] 대시보드에서는 여전히 탭바 미표시 (기존 동작 유지)
- [ ] 알림 목록 페이지에서는 탭바 표시 (일반 페이지)
- [ ] 메인 콘텐츠 패딩이 탭바 유무에 따라 올바르게 적용

### 레이아웃 확인
- [ ] 설정 페이지: `<main class="pt-14 min-h-screen">` (pb-20 없음)
- [ ] 일반 페이지: `<main class="pt-14 pb-20 min-h-screen">` (pb-20 있음)
- [ ] Safe Area 대응 정상 동작

### 코드 품질
- [ ] `rails test` - 모든 테스트 통과
- [ ] `rubocop` - Lint 에러 없음
- [ ] 디버그 코드 제거 (puts, binding.pry)
- [ ] 주석 처리된 코드 제거

### 설계 문서 확인
- [ ] PRD.md의 설정 화면 요구사항 충족
- [ ] DESIGN_GUIDE.md의 레이아웃 패턴 준수
- [ ] ARCHITECTURE.md의 레이어 책임 준수

---

## UI/UX 개선 고려사항

### 뒤로가기 네비게이션
설정 화면에서 탭바가 제거되므로, 사용자가 이전 화면으로 돌아갈 수 있는 명확한 방법을 제공해야 합니다.

#### 옵션 1: 헤더에 뒤로가기 버튼 추가 (권장)

```erb
# app/views/shared/_header.html.erb
<header class="fixed top-0 left-0 right-0 z-50
               bg-white/80 backdrop-blur-md
               border-b border-cream-200
               safe-area-inset-top">
  <div class="flex items-center justify-between px-4 h-14">
    <!-- 좌측: 뒤로가기 또는 로고 -->
    <% if show_back_button? %>
      <%= link_to :back, class: "p-2 -ml-2 rounded-full hover:bg-cream-100" do %>
        <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700", "aria-label": "뒤로 가기" } %>
      <% end %>
    <% else %>
      <%= link_to root_path, class: "flex items-center gap-2" do %>
        <span class="text-2xl">🌸</span>
        <span class="text-lg font-bold text-warm-gray-800">모아봄</span>
      <% end %>
    <% end %>

    <!-- 우측 액션은 기존 유지 -->
    <div class="flex items-center gap-2">
      <!-- ... -->
    </div>
  </div>
</header>
```

```ruby
# app/helpers/application_helper.rb
def show_back_button?
  # 설정 페이지에서 뒤로가기 버튼 표시
  controller_path.start_with?("settings/")
end
```

#### 옵션 2: 페이지 내 뒤로가기 링크

```erb
# app/views/settings/profile/show.html.erb
<div class="px-4 py-6">
  <%= link_to dashboard_path, class: "inline-flex items-center gap-2 text-primary-600 hover:text-primary-700 mb-6" do %>
    <%= heroicon "arrow-left", variant: :outline, options: { class: "w-5 h-5" } %>
    <span class="text-sm font-medium">대시보드로 돌아가기</span>
  <% end %>

  <h1 class="text-2xl font-bold text-warm-gray-800 mb-6">설정</h1>
  <!-- ... -->
</div>
```

---

## 참고사항

- Wave 5 Phase 2에서 대시보드 탭바를 제거한 것과 일관성을 유지
- 설정 화면은 전체 화면을 활용하는 독립적인 영역으로 간주
- 탭바 없이도 명확한 네비게이션 제공 (헤더 뒤로가기 버튼 또는 페이지 내 링크)

---

## 관련 이슈

- Wave 5 Phase 2: 대시보드 탭바 제거
- Wave 5 Phase 4: 대시보드 네비게이션 수정 (병렬 진행 가능)

---

## 커밋 전략

1. **기본 구현 커밋**: `feat(settings): 설정 화면에서 하단 탭바 제거`
2. **뒤로가기 추가 커밋** (선택): `feat(settings): 설정 화면 헤더에 뒤로가기 버튼 추가`
