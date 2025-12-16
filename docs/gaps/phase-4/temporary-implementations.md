# 임시 구현 (Temporary Implementations)

> 나중에 개선이 필요한 코드

---

## 1. 초대 링크 매번 새로 생성 🔴 Critical

| 항목 | 내용 |
|-----|------|
| **파일** | `app/controllers/onboarding/invites_controller.rb:9` |
| **우선순위** | **P0** |

### 현재 코드

```ruby
# app/controllers/onboarding/invites_controller.rb
def show
  @family = current_user.families.first
  @invitation = @family.invitations.create!(  # 매번 새로 생성!
    inviter: current_user,
    role: :member
  )
  @invite_url = accept_invitation_url(@invitation.token)
end
```

### 문제점

1. 페이지 새로고침마다 새 초대 레코드 생성
2. invitations 테이블에 불필요한 데이터 누적
3. 기존 공유한 링크가 여전히 유효하여 관리 어려움

### 개선 방향

```ruby
def show
  @family = current_user.families.first
  @invitation = find_or_create_invitation
  @invite_url = accept_invitation_url(@invitation.token)
end

private

def find_or_create_invitation
  # 7일 이내 유효한 기존 초대 재사용
  existing = @family.invitations
    .where(inviter: current_user, role: :member)
    .active
    .first

  existing || @family.invitations.create!(
    inviter: current_user,
    role: :member
  )
end
```

---

## 2. 인가 로직 중복

| 항목 | 내용 |
|-----|------|
| **파일** | 3개 컨트롤러에서 반복 |
| **우선순위** | P1 |

### 현재 코드

```ruby
# app/controllers/families_controller.rb:27
def authorize_edit!
  membership = current_user.family_memberships.find_by(family: @family)
  return if membership&.role_owner? || membership&.role_admin?
  redirect_to @family, alert: "수정 권한이 없습니다."
end

# app/controllers/families/members_controller.rb:49
def authorize_manage!
  my_membership = current_user.family_memberships.find_by(family: @family)
  return if my_membership&.role_owner? || my_membership&.role_admin?
  redirect_to family_members_path(@family), alert: "권한이 없습니다."
end

# app/controllers/families/children_controller.rb:59
def authorize_manage!
  membership = current_user.family_memberships.find_by(family: @family)
  return if membership&.role_owner? || membership&.role_admin?
  redirect_to family_children_path(@family), alert: "권한이 없습니다."
end
```

### 문제점

1. DRY 원칙 위반 - 동일 로직 3회 반복
2. 권한 체크 로직 변경 시 3곳 수정 필요
3. 역할 추가 시 모든 곳 업데이트 필요

### 개선 방향 A: Concern 추출

```ruby
# app/controllers/concerns/family_authorizable.rb
module FamilyAuthorizable
  extend ActiveSupport::Concern

  private

  def current_membership
    @current_membership ||= current_user.family_memberships.find_by(family: @family)
  end

  def can_manage_family?
    current_membership&.role_owner? || current_membership&.role_admin?
  end

  def authorize_family_management!
    return if can_manage_family?
    redirect_back fallback_location: root_path, alert: "권한이 없습니다."
  end
end
```

### 개선 방향 B: Pundit 도입

```ruby
# app/policies/family_policy.rb
class FamilyPolicy < ApplicationPolicy
  def update?
    membership&.role_owner? || membership&.role_admin?
  end

  def manage_members?
    membership&.role_owner? || membership&.role_admin?
  end

  private

  def membership
    user.family_memberships.find_by(family: record)
  end
end

# 컨트롤러에서 사용
authorize @family, :update?
```

---

## 3. 테스트용 세션 컨트롤러

| 항목 | 내용 |
|-----|------|
| **파일** | `app/controllers/sessions_controller.rb` |
| **우선순위** | P1 (보안 검토) |

### 현재 코드

```ruby
# app/controllers/sessions_controller.rb
def create
  # For testing purposes - allows direct login
  user = User.find_by(id: params[:user_id])
  if user
    session[:user_id] = user.id
    redirect_to root_path, notice: "로그인되었습니다."
  else
    redirect_to root_path, alert: "사용자를 찾을 수 없습니다."
  end
end
```

### 문제점

1. 프로덕션에서 직접 로그인 가능 (보안 위험)
2. 라우트가 열려 있으면 임의 사용자로 로그인 가능

### 현재 상태 확인

```ruby
# config/routes.rb
post "test_login", to: "sessions#create" if Rails.env.test?
```

- ✅ `if Rails.env.test?` 조건으로 테스트 환경에서만 라우트 노출
- ⚠️ 하지만 컨트롤러 코드 자체는 환경 체크 없음

### 개선 방향

```ruby
def create
  # 테스트 환경에서만 직접 로그인 허용
  unless Rails.env.test?
    redirect_to root_path, alert: "잘못된 접근입니다."
    return
  end

  user = User.find_by(id: params[:user_id])
  # ...
end
```

---

## 요약

| 항목 | 우선순위 | 위험도 | 예상 공수 |
|-----|---------|-------|---------|
| 초대 링크 재사용 | P0 | High | 1시간 |
| 인가 로직 중복 제거 | P1 | Medium | 2시간 |
| 테스트용 세션 보안 | P1 | Medium | 30분 |
