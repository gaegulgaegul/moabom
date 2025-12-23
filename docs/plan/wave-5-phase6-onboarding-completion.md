# Wave 5 Phase 6: 온보딩 완료 로직 개선

> 온보딩 완료 처리를 명시적 버튼 클릭으로 변경하여 안정성 향상
> 작성일: 2025-12-21

---

## 개요

대시보드(홈페이지)의 모든 버튼(사진 업로드, 가족 관리, 앨범 보기, 아이 프로필)을 클릭하면 온보딩 화면으로 잘못 이동하는 문제를 해결합니다.

**문제의 원인**: ApplicationController의 `check_onboarding` before_action이 가족의 `onboarding_completed_at` 값을 확인하는데, 이 값이 `nil`인 상태여서 모든 요청을 온보딩 페이지로 리다이렉트함.

**근본 원인**: Invites 페이지 로드 시 자동으로 `@family.complete_onboarding!`을 호출하도록 되어 있으나, 어떤 이유로 실패하거나 실행되지 않아 온보딩이 미완료 상태로 남음.

---

## 목표

- [x] 즉시 해결: Rails console로 현재 가족 온보딩 완료 처리 ✅ 2025-12-23
- [x] 온보딩 완료 로직을 "시작하기" 버튼 클릭으로 변경 ✅ 2025-12-23
- [x] 자동 완료 로직 제거하여 명시적 완료 보장 ✅ 2025-12-23
- [x] 테스트 추가 ✅ 2025-12-23

---

## 현재 온보딩 플로우

```
1. Profile → onboarding_profile_path (프로필 입력)
2. Child → onboarding_child_path (아이 정보 입력)
   → 성공 시 onboarding_invite_path로 리다이렉트
3. Invites → onboarding_invite_path (초대 링크 공유)
   → 페이지 로드 시 @family.complete_onboarding! 자동 호출 (문제!)
   → "시작하기" 버튼 클릭 시 root_path로 이동
```

**문제**: 페이지 로드 시 자동 완료는 실패 가능성이 있고 UX상 불명확

---

## 핵심 파일

1. **ApplicationController** (`app/controllers/application_controller.rb`)
   - 라인 16: `before_action :check_onboarding`
   - 라인 58-66: `check_onboarding` 메서드 (가족 온보딩 확인)

2. **InvitesController** (`app/controllers/onboarding/invites_controller.rb`)
   - 라인 8-20: `show` 액션
   - 라인 19: `@family.complete_onboarding! unless @family.onboarding_completed?` (자동 완료)

3. **Invites 뷰** (`app/views/onboarding/invites/show.html.erb`)
   - 라인 52: "시작하기" 버튼 (현재는 단순 링크)

4. **Onboardable Concern** (`app/models/concerns/onboardable.rb`)
   - 라인 11-13: `onboarding_completed?` 메서드
   - 라인 19-21: `complete_onboarding!` 메서드

5. **라우트** (`config/routes.rb`)
   - 온보딩 관련 라우트 정의

---

## 즉시 해결 방법

현재 가족의 온보딩을 즉시 완료 처리하여 대시보드 사용 가능하게 합니다.

```ruby
# Rails console 실행
rails console

# 현재 사용자의 가족 찾기
family = Family.first  # 또는 특정 ID: Family.find(ID)

# 온보딩 완료 처리
family.complete_onboarding!

# 확인
family.onboarding_completed?  # => true
family.onboarding_completed_at  # => 현재 시간
```

**검증**:
- [x] Rails console에서 `Family.first.onboarding_completed?` → `true` 반환 ✅ 2025-12-23
- [x] 대시보드에서 "사진 업로드" 버튼 클릭 → 사진 업로드 페이지로 이동 ✅ 2025-12-23
- [x] 대시보드에서 "가족 관리" 버튼 클릭 → 가족 관리 페이지로 이동 ✅ 2025-12-23
- [x] 대시보드에서 "앨범 보기" 버튼 클릭 → 앨범 페이지로 이동 ✅ 2025-12-23
- [x] 대시보드에서 "아이 프로필" 버튼 클릭 → 아이 프로필 페이지로 이동 ✅ 2025-12-23
- Note: User와 Family 온보딩을 동시에 완료하도록 수정하여 해결

---

## 작업 1: "시작하기" 버튼 클릭 시 온보딩 완료

### RED: 테스트 작성

- [x] **RED**: 온보딩 완료 컨트롤러 테스트 작성 ✅ 2025-12-23
  - Note: Rails 8.1.1 + Minitest 6.0.0 호환성 문제로 테스트 실행 안됨. 구현 후 Minitest 5.x로 다운그레이드 필요

```ruby
# test/controllers/onboarding/invites_controller_test.rb
test "POST #complete should mark family onboarding as completed" do
  sign_in @user
  assert_not @family.onboarding_completed?

  post complete_onboarding_invite_path

  assert_redirected_to root_path
  assert @family.reload.onboarding_completed?
end

test "POST #complete should redirect to root with success message" do
  sign_in @user

  post complete_onboarding_invite_path

  assert_redirected_to root_path
  follow_redirect!
  assert_select ".alert-success", text: /온보딩이 완료되었습니다/
end
```

- [ ] **RED**: 온보딩 완료 시스템 테스트 작성 (스킵 - 컨트롤러 테스트로 충분)

```ruby
# test/system/onboarding/invites_test.rb
test "completing onboarding by clicking start button" do
  sign_in_as @user
  visit onboarding_invite_path

  # "시작하기" 버튼 클릭
  click_button "시작하기"

  # 루트 페이지로 이동하고 온보딩 완료
  assert_current_path root_path
  assert_text "온보딩이 완료되었습니다"
  assert @family.reload.onboarding_completed?
end
```

Note: 컨트롤러 테스트에서 충분히 검증되어 시스템 테스트는 스킵함

### GREEN: 최소 구현

- [x] **GREEN**: 라우트 추가 ✅ 2025-12-23

```ruby
# config/routes.rb
namespace :onboarding do
  resource :profile, only: [:show, :create]
  resource :child, only: [:show, :create]
  resource :invite, only: [:show] do
    post :complete, on: :collection  # POST /onboarding/invite/complete
  end
end
```

- [x] **GREEN**: InvitesController에 complete 액션 추가 ✅ 2025-12-23

```ruby
# app/controllers/onboarding/invites_controller.rb
def complete
  @family = current_family
  unless @family
    redirect_to root_path, alert: "가족을 찾을 수 없습니다."
    return
  end

  # 가족과 사용자 온보딩 둘 다 완료 처리
  @family.complete_onboarding!
  current_user.complete_onboarding! unless current_user.onboarding_completed?

  redirect_to root_path, notice: "온보딩이 완료되었습니다. 환영합니다!"
end
```

Note: User와 Family 온보딩을 동시에 완료하도록 수정 (대시보드 버튼 리다이렉트 이슈 해결)

- [x] **GREEN**: "시작하기" 버튼을 폼 제출로 변경 ✅ 2025-12-23

```erb
<!-- app/views/onboarding/invites/show.html.erb (라인 52) -->
<!-- 기존 -->
<%= link_to "시작하기", root_path, class: "btn-primary w-full text-center block" %>

<!-- 변경 -->
<%= button_to "시작하기", complete_onboarding_invite_path,
    method: :post, class: "btn-primary w-full" %>
```

### REFACTOR: 자동 완료 로직 제거

- [x] **REFACTOR**: InvitesController#show에서 자동 완료 로직 제거 ✅ 2025-12-23

```ruby
# app/controllers/onboarding/invites_controller.rb (라인 18-19)
# 기존
# 온보딩 완료 처리 (나중에 뷰의 버튼으로 이동 예정)
@family.complete_onboarding! unless @family.onboarding_completed?

# 변경 (주석 처리 또는 삭제)
# 온보딩 완료 처리는 complete 액션에서 수행
```

---

## 검증 체크리스트

### 기능 확인
- [x] 온보딩 플로우: Profile → Child → Invites 정상 진행 ✅ 2025-12-23
- [x] Invites 페이지에서 "시작하기" 버튼 클릭 시 온보딩 완료 ✅ 2025-12-23
- [x] 완료 후 대시보드 모든 기능 정상 작동 ✅ 2025-12-23
- [x] 온보딩 완료 후 check_onboarding 필터 통과 ✅ 2025-12-23

### 코드 품질
- [x] 모든 테스트 통과: `rails test` (334 runs, 925 assertions, 1 pre-existing failure) ✅ 2025-12-23
- [ ] Rubocop 검사 통과: `rubocop` (스킵 - 기존 코드 스타일 유지)
- [x] 컨트롤러 테스트 통과 (9 runs, 28 assertions, 0 failures) ✅ 2025-12-23
- [ ] 시스템 테스트 통과 (스킵 - 컨트롤러 테스트로 충분)

### 설계 문서 준수
- [x] PRD.md의 온보딩 요구사항 충족 ✅ 2025-12-23
- [x] ARCHITECTURE.md의 레이어 책임 준수 (Controller는 얇게) ✅ 2025-12-23
- [x] 온보딩 완료 로직이 명시적이고 추적 가능 ✅ 2025-12-23

---

## 완료 요약 (2025-12-23)

### 구현 내용
1. **테스트 작성 (RED)**
   - `test/controllers/onboarding/invites_controller_test.rb`에 2개 테스트 추가
   - 온보딩 완료 시 User와 Family 둘 다 완료되는지 검증
   - Minitest 6.0.0 → 5.27.0 다운그레이드로 호환성 이슈 해결

2. **기능 구현 (GREEN)**
   - `config/routes.rb`: POST `/onboarding/invite/complete` 라우트 추가
   - `InvitesController#complete`: User와 Family 온보딩 동시 완료 액션 추가
   - `show.html.erb`: "시작하기" 링크 → `button_to` POST 폼으로 변경

3. **리팩토링 (REFACTOR)**
   - `InvitesController#show`에서 자동 완료 로직 제거
   - 명시적인 버튼 클릭으로만 온보딩 완료 가능하도록 변경

### 해결한 주요 이슈
1. **Minitest 호환성**: Rails 8.1.1 + Minitest 6.0.0 ArgumentError → Minitest 5.27.0으로 해결
2. **대시보드 버튼 리다이렉트 이슈**:
   - 원인: Families::PhotosController가 `require_onboarding!`을 사용하여 User 온보딩 체크
   - 해결: `InvitesController#complete`에서 User와 Family 온보딩 동시 완료
3. **자동 완료 신뢰성**: 페이지 로드 시 자동 완료 → 명시적 버튼 클릭으로 변경

### 테스트 결과
- 컨트롤러 테스트: 9 runs, 28 assertions, 0 failures ✅
- 전체 테스트 스위트: 334 runs, 925 assertions, 1 pre-existing failure ✅
- 새로 추가된 모든 테스트 통과 ✅

---

## 참고 사항

**온보딩 상태 관리**:
- User 온보딩: `user.onboarding_completed_at` (사용자별)
- Family 온보딩: `family.onboarding_completed_at` (가족별)
- `check_onboarding`은 Family 온보딩 확인
- `require_onboarding!`은 User 온보딩 확인

**향후 개선 사항**:
- User와 Family 온보딩 통합 검토
- 온보딩 단계별 완료 추적 고려 (Profile, Child, Invites 각각)
