# Wave 5: Phase 1 - 온보딩 플로우 수정

> 선행 조건: Wave 4 완료
> 병렬 실행: Phase 1 ∥ Phase 2 ∥ Phase 3

---

## 문제 정의

온보딩 완료 후 대시보드(`/`)의 빠른 메뉴 버튼들을 클릭하면 온보딩으로 재진입되는 문제

**현재 동작:**
- 온보딩 완료 → 대시보드 이동
- 대시보드에서 "사진 추가", "가족 초대", "앨범 만들기" 버튼 클릭
- 온보딩 화면으로 다시 리다이렉트됨

**원인 분석:**
- 온보딩 완료 플래그가 제대로 설정되지 않거나
- 대시보드 빠른 메뉴 링크가 온보딩 경로로 잘못 설정됨

**예상 해결:**
- 온보딩 완료 후 `current_user` 또는 `current_family`에 완료 상태 저장
- 대시보드 빠른 메뉴 링크를 실제 기능 경로로 수정
- 온보딩 필터에서 완료 상태 확인 로직 개선

---

## TDD 작업 순서

### 5.1.1 온보딩 완료 상태 테스트

#### RED: 테스트 작성

- [ ] **RED**: 온보딩 완료 상태 테스트 추가

```ruby
# test/models/family_test.rb
test "should track onboarding completion" do
  family = families(:kim_family)
  assert_not family.onboarding_completed?

  family.complete_onboarding!
  assert family.onboarding_completed?
end

# test/controllers/home_controller_test.rb
test "should not redirect to onboarding when completed" do
  sign_in users(:mom)
  families(:kim_family).complete_onboarding!

  get root_path
  assert_response :success
  assert_select "h1", "우리 가족"
end

test "should redirect to onboarding when not completed" do
  sign_in users(:mom)
  families(:kim_family).update!(onboarding_completed_at: nil)

  get root_path
  assert_redirected_to onboarding_profile_path
end
```

#### GREEN: 최소 구현

- [ ] **GREEN**: 온보딩 완료 상태 구현

```ruby
# db/migrate/XXXXXX_add_onboarding_completed_to_families.rb
class AddOnboardingCompletedToFamilies < ActiveRecord::Migration[8.0]
  def change
    add_column :families, :onboarding_completed_at, :datetime
    add_index :families, :onboarding_completed_at
  end
end

# app/models/family.rb
class Family < ApplicationRecord
  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current)
  end
end

# app/controllers/onboarding/invites_controller.rb
class Onboarding::InvitesController < ApplicationController
  def show
    current_family.complete_onboarding!
    redirect_to root_path, notice: "가족 공간이 준비되었습니다! 🎉"
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :check_onboarding

  private

  def check_onboarding
    return unless user_signed_in?
    return if controller_name == "sessions" || controller_path.start_with?("onboarding/")
    return if current_family&.onboarding_completed?

    redirect_to onboarding_profile_path
  end
end
```

#### REFACTOR: 코드 정리

- [ ] **REFACTOR**: 온보딩 로직 정리

```ruby
# app/models/concerns/onboardable.rb
module Onboardable
  extend ActiveSupport::Concern

  included do
    scope :onboarding_completed, -> { where.not(onboarding_completed_at: nil) }
    scope :onboarding_pending, -> { where(onboarding_completed_at: nil) }
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def onboarding_pending?
    !onboarding_completed?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current)
  end
end

# app/models/family.rb
class Family < ApplicationRecord
  include Onboardable
  # ...
end
```

---

### 5.1.2 대시보드 빠른 메뉴 링크 수정

#### RED: 테스트 작성

- [ ] **RED**: 빠른 메뉴 링크 테스트 추가

```ruby
# test/system/dashboard_quick_actions_test.rb
require "application_system_test_case"

class DashboardQuickActionsTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  test "clicking photo upload should open upload page" do
    visit root_path

    click_on "사진 추가"

    assert_current_path new_family_photo_path(@family)
    assert_text "사진 업로드"
  end

  test "clicking family invite should open invite page" do
    visit root_path

    click_on "가족 초대"

    assert_current_path family_invitations_path(@family)
    assert_text "가족 초대하기"
  end

  test "clicking album create should open album page" do
    visit root_path

    click_on "앨범 만들기"

    assert_current_path new_family_album_path(@family)
    assert_text "새 앨범"
  end
end
```

#### GREEN: 링크 수정

- [ ] **GREEN**: 대시보드 빠른 메뉴 링크 수정

```erb
<%# app/views/home/_quick_actions.html.erb %>
<div class="grid grid-cols-3 gap-3 mb-6">
  <%= link_to new_family_photo_path(current_family),
              class: "bg-white rounded-2xl p-4 text-center
                      hover:bg-cream-50 transition-colors" do %>
    <%= heroicon "photo", variant: :outline,
        options: { class: "w-8 h-8 mx-auto text-primary-500" } %>
    <p class="mt-2 text-sm font-medium text-warm-gray-700">사진 추가</p>
  <% end %>

  <%= link_to family_invitations_path(current_family),
              class: "bg-white rounded-2xl p-4 text-center
                      hover:bg-cream-50 transition-colors" do %>
    <%= heroicon "user-plus", variant: :outline,
        options: { class: "w-8 h-8 mx-auto text-secondary-500" } %>
    <p class="mt-2 text-sm font-medium text-warm-gray-700">가족 초대</p>
  <% end %>

  <%= link_to new_family_album_path(current_family),
              class: "bg-white rounded-2xl p-4 text-center
                      hover:bg-cream-50 transition-colors" do %>
    <%= heroicon "folder-plus", variant: :outline,
        options: { class: "w-8 h-8 mx-auto text-accent-500" } %>
    <p class="mt-2 text-sm font-medium text-warm-gray-700">앨범 만들기</p>
  <% end %>
</div>
```

#### REFACTOR: 헬퍼 추출

- [ ] **REFACTOR**: 빠른 메뉴 헬퍼 추출

```ruby
# app/helpers/dashboard_helper.rb
module DashboardHelper
  def quick_action_card(title:, icon:, path:, color: "primary")
    link_to path, class: "bg-white rounded-2xl p-4 text-center
                           hover:bg-cream-50 transition-colors" do
      concat heroicon(icon, variant: :outline,
                      options: { class: "w-8 h-8 mx-auto text-#{color}-500" })
      concat content_tag(:p, title, class: "mt-2 text-sm font-medium text-warm-gray-700")
    end
  end
end

# app/views/home/_quick_actions.html.erb
<div class="grid grid-cols-3 gap-3 mb-6">
  <%= quick_action_card(
    title: "사진 추가",
    icon: "photo",
    path: new_family_photo_path(current_family),
    color: "primary"
  ) %>

  <%= quick_action_card(
    title: "가족 초대",
    icon: "user-plus",
    path: family_invitations_path(current_family),
    color: "secondary"
  ) %>

  <%= quick_action_card(
    title: "앨범 만들기",
    icon: "folder-plus",
    path: new_family_album_path(current_family),
    color: "accent"
  ) %>
</div>
```

---

## 테스트 실행

```bash
# 마이그레이션
rails db:migrate
rails db:test:prepare

# 모델 테스트
rails test test/models/family_test.rb

# 컨트롤러 테스트
rails test test/controllers/home_controller_test.rb

# 시스템 테스트
rails test:system test/system/dashboard_quick_actions_test.rb

# 전체 테스트
rails test
```

---

## 커밋 가이드

```bash
# RED 커밋
git add test/
git commit -m "test(onboarding): 온보딩 완료 상태 및 빠른 메뉴 테스트 추가 (RED)"

# GREEN 커밋
git add db/migrate app/models app/controllers app/views
git commit -m "feat(onboarding): 온보딩 완료 상태 추적 및 빠른 메뉴 링크 수정 (GREEN)"

# REFACTOR 커밋
git add app/models/concerns app/helpers
git commit -m "refactor(onboarding): 온보딩 로직 및 빠른 메뉴 헬퍼 정리"
```

---

## 최종 체크리스트

- [ ] 온보딩 완료 후 대시보드로 정상 이동
- [ ] 대시보드에서 빠른 메뉴 클릭 시 올바른 페이지 이동
- [ ] 온보딩 미완료 시 온보딩으로 리다이렉트
- [ ] 모든 테스트 통과
- [ ] Rubocop 통과
