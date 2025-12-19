# Wave 5: Phase 2 - 네비게이션 UI 개선

> 선행 조건: Wave 4 완료
> 병렬 실행: Phase 1 ∥ Phase 2 ∥ Phase 3

---

## 문제 정의

대시보드 네비게이션 구조 개선

**현재 문제:**
1. 하단 탭바에 불필요한 버튼 존재 (홈, 앨범, 알림)
2. 하단 중앙 + 버튼 클릭 시 동작 없음
3. 상단 바에 설정 아이콘 누락

**목표:**
1. 하단 탭바 제거 (대시보드는 단일 화면)
2. 상단 바에 설정 아이콘 추가
3. 사진 업로드는 빠른 메뉴 또는 플로팅 버튼 활용

---

## TDD 작업 순서

### 5.2.1 하단 탭바 제거

#### RED: 테스트 작성

- [ ] **RED**: 대시보드에 탭바가 없는지 확인하는 테스트

```ruby
# test/system/dashboard_navigation_test.rb
require "application_system_test_case"

class DashboardNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  test "dashboard should not have bottom tab bar" do
    visit root_path

    # 탭바가 없어야 함
    assert_no_selector "nav.tabbar"
    assert_no_selector "[data-testid='bottom-navigation']"

    # 대신 상단 바만 있어야 함
    assert_selector "header"
  end

  test "dashboard should have clean single-page layout" do
    visit root_path

    # 전체 페이지가 하나의 스크롤 가능한 영역
    assert_selector "main.min-h-screen"

    # 하단 패딩이 탭바 높이가 아님 (pb-20 제거)
    main = find("main")
    assert_not main[:class].include?("pb-20")
  end
end
```

#### GREEN: 탭바 제거

- [ ] **GREEN**: 대시보드 레이아웃 수정

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <!-- ... -->
  </head>
  <body class="bg-cream-50 dark:bg-warm-gray-900">
    <%= render "shared/header" %>

    <main class="pt-14 min-h-screen">
      <%= yield %>
    </main>

    <%# 대시보드에서는 탭바 제거 %>
    <% unless controller_name == "home" && action_name == "index" %>
      <%= render "shared/bottom_tabbar" %>
    <% end %>
  </body>
</html>
```

또는 대시보드 전용 레이아웃 생성:

```erb
<%# app/views/layouts/dashboard.html.erb %>
<!DOCTYPE html>
<html>
  <head>
    <title>모아봄 - 우리 가족</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>
  <body class="bg-cream-50 dark:bg-warm-gray-900">
    <%= render "shared/header" %>

    <main class="pt-14 min-h-screen">
      <%= yield %>
    </main>

    <%# 탭바 없음 %>
  </body>
</html>

<%# app/controllers/home_controller.rb %>
class HomeController < ApplicationController
  layout "dashboard"

  def index
    @family = current_family
    @recent_photos = @family.photos.recent.limit(20)
  end
end
```

#### REFACTOR: 레이아웃 헬퍼 개선

- [ ] **REFACTOR**: 레이아웃 조건부 렌더링 개선

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def show_bottom_tabbar?
    # 특정 페이지에서만 탭바 표시
    return false if controller_name == "home" && action_name == "index"
    return false if controller_path.start_with?("onboarding/")
    return false if controller_name == "sessions"

    true
  end
end

# app/views/layouts/application.html.erb
<body class="bg-cream-50 dark:bg-warm-gray-900">
  <%= render "shared/header" %>

  <main class="<%= show_bottom_tabbar? ? 'pt-14 pb-20' : 'pt-14' %> min-h-screen">
    <%= yield %>
  </main>

  <%= render "shared/bottom_tabbar" if show_bottom_tabbar? %>
</body>
```

---

### 5.2.2 상단 바에 설정 아이콘 추가

#### RED: 테스트 작성

- [ ] **RED**: 상단 바 설정 아이콘 테스트

```ruby
# test/system/dashboard_navigation_test.rb
test "dashboard header should have settings icon" do
  visit root_path

  within "header" do
    # 로고
    assert_selector "a[href='/']", text: "모아봄"

    # 알림 아이콘
    assert_selector "a[href='/notifications']"

    # 설정 아이콘
    assert_selector "a[href='/settings']"
  end
end

test "clicking settings icon should navigate to settings" do
  visit root_path

  within "header" do
    click_on "설정"
  end

  assert_current_path settings_profile_path
  assert_text "설정"
end
```

#### GREEN: 설정 아이콘 추가

- [ ] **GREEN**: 헤더에 설정 아이콘 추가

```erb
<%# app/views/shared/_header.html.erb %>
<header class="fixed top-0 left-0 right-0 z-50
               bg-white/80 backdrop-blur-md
               border-b border-cream-200">
  <div class="flex items-center justify-between px-4 h-14">
    <!-- 로고 -->
    <%= link_to root_path, class: "flex items-center gap-2" do %>
      <span class="text-2xl">🌸</span>
      <span class="text-lg font-bold text-warm-gray-800">모아봄</span>
    <% end %>

    <!-- 오른쪽 액션 -->
    <div class="flex items-center gap-2">
      <!-- 알림 -->
      <%= link_to notifications_path,
                  class: "p-2 rounded-full hover:bg-cream-100
                          transition-colors duration-200",
                  aria_label: "알림" do %>
        <%= heroicon "bell", variant: :outline,
            options: { class: "w-6 h-6 text-warm-gray-600" } %>
        <% if current_user.unread_notifications_count > 0 %>
          <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
        <% end %>
      <% end %>

      <!-- 설정 -->
      <%= link_to settings_profile_path,
                  class: "p-2 rounded-full hover:bg-cream-100
                          transition-colors duration-200",
                  aria_label: "설정" do %>
        <%= heroicon "cog-6-tooth", variant: :outline,
            options: { class: "w-6 h-6 text-warm-gray-600" } %>
      <% end %>
    </div>
  </div>
</header>
```

#### REFACTOR: 헤더 컴포넌트 분리

- [ ] **REFACTOR**: 헤더 아이콘 버튼 컴포넌트화

```ruby
# app/helpers/navigation_helper.rb
module NavigationHelper
  def header_icon_button(icon:, path:, label:, badge: false)
    link_to path,
            class: "relative p-2 rounded-full hover:bg-cream-100
                    transition-colors duration-200",
            aria_label: label do
      concat heroicon(icon, variant: :outline,
                      options: { class: "w-6 h-6 text-warm-gray-600" })
      if badge
        concat content_tag(:span, "",
                          class: "absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full")
      end
    end
  end
end

# app/views/shared/_header.html.erb
<header class="fixed top-0 left-0 right-0 z-50
               bg-white/80 backdrop-blur-md
               border-b border-cream-200">
  <div class="flex items-center justify-between px-4 h-14">
    <%= link_to root_path, class: "flex items-center gap-2" do %>
      <span class="text-2xl">🌸</span>
      <span class="text-lg font-bold text-warm-gray-800">모아봄</span>
    <% end %>

    <div class="flex items-center gap-2">
      <%= header_icon_button(
        icon: "bell",
        path: notifications_path,
        label: "알림",
        badge: current_user.unread_notifications_count > 0
      ) %>

      <%= header_icon_button(
        icon: "cog-6-tooth",
        path: settings_profile_path,
        label: "설정"
      ) %>
    </div>
  </div>
</header>
```

---

### 5.2.3 플로팅 업로드 버튼 (선택 사항)

#### RED: 테스트 작성

- [ ] **RED**: 플로팅 업로드 버튼 테스트

```ruby
# test/system/dashboard_navigation_test.rb
test "dashboard should have floating upload button" do
  visit root_path

  # 플로팅 버튼 존재
  assert_selector "button[data-action='click->upload#open']",
                  class: /fixed.*bottom.*right/

  # 버튼 텍스트 또는 아이콘
  within "button[data-action='click->upload#open']" do
    assert_selector "svg" # heroicon
  end
end

test "clicking floating upload button should open upload modal" do
  visit root_path

  click_on "사진 업로드"

  # 모달 또는 업로드 페이지 표시
  assert_selector "[role='dialog']", text: "사진 업로드"
end
```

#### GREEN: 플로팅 버튼 추가

- [ ] **GREEN**: 플로팅 업로드 버튼 구현

```erb
<%# app/views/home/index.html.erb %>
<div class="px-4 py-6">
  <!-- 대시보드 콘텐츠 -->
  <%= render "quick_actions" %>
  <%= render "timeline" %>
</div>

<%# 플로팅 업로드 버튼 %>
<%= link_to new_family_photo_path(current_family),
            class: "fixed bottom-6 right-6 z-40
                    flex items-center justify-center
                    w-14 h-14
                    bg-primary-500 text-white rounded-full
                    shadow-lg shadow-primary-500/30
                    hover:bg-primary-600 active:bg-primary-700
                    transition-colors duration-200",
            aria_label: "사진 업로드" do %>
  <%= heroicon "plus", variant: :solid,
      options: { class: "w-7 h-7" } %>
<% end %>
```

#### REFACTOR: 조건부 플로팅 버튼

- [ ] **REFACTOR**: 스크롤 시 플로팅 버튼 숨김

```javascript
// app/javascript/controllers/floating_button_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.lastScrollY = window.scrollY
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    const currentScrollY = window.scrollY

    if (currentScrollY > this.lastScrollY && currentScrollY > 100) {
      // 아래로 스크롤 - 버튼 숨김
      this.buttonTarget.classList.add("translate-y-20", "opacity-0")
    } else {
      // 위로 스크롤 - 버튼 표시
      this.buttonTarget.classList.remove("translate-y-20", "opacity-0")
    }

    this.lastScrollY = currentScrollY
  }
}
```

```erb
<%# app/views/home/index.html.erb %>
<div data-controller="floating-button">
  <!-- 콘텐츠 -->

  <%= link_to new_family_photo_path(current_family),
              data: { floating_button_target: "button" },
              class: "fixed bottom-6 right-6 z-40
                      flex items-center justify-center
                      w-14 h-14
                      bg-primary-500 text-white rounded-full
                      shadow-lg shadow-primary-500/30
                      hover:bg-primary-600 active:bg-primary-700
                      transition-all duration-200",
              aria_label: "사진 업로드" do %>
    <%= heroicon "plus", variant: :solid, options: { class: "w-7 h-7" } %>
  <% end %>
</div>
```

---

## 테스트 실행

```bash
# 시스템 테스트
rails test:system test/system/dashboard_navigation_test.rb

# 전체 테스트
rails test
```

---

## 커밋 가이드

```bash
# RED 커밋
git add test/system/
git commit -m "test(navigation): 대시보드 네비게이션 개선 테스트 추가 (RED)"

# GREEN 커밋 (탭바 제거)
git add app/views/layouts app/controllers
git commit -m "feat(navigation): 대시보드 하단 탭바 제거 (GREEN)"

# GREEN 커밋 (설정 아이콘)
git add app/views/shared
git commit -m "feat(navigation): 헤더에 설정 아이콘 추가 (GREEN)"

# GREEN 커밋 (플로팅 버튼)
git add app/views/home app/javascript
git commit -m "feat(navigation): 플로팅 업로드 버튼 추가 (GREEN)"

# REFACTOR 커밋
git add app/helpers
git commit -m "refactor(navigation): 네비게이션 헬퍼 및 컴포넌트 정리"
```

---

## 최종 체크리스트

- [ ] 대시보드에 하단 탭바 없음
- [ ] 상단 바에 알림, 설정 아이콘 표시
- [ ] 플로팅 업로드 버튼 동작
- [ ] 모든 테스트 통과
- [ ] Rubocop 통과
- [ ] 반응형 레이아웃 확인 (모바일, 태블릿, 데스크톱)
- [ ] 접근성 확인 (aria-label, 키보드 네비게이션)
