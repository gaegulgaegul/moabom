# Hardcoded Values - Phase 7 설정

## 요약
- 총 항목 수: 4개
- P0 (즉시): 2개
- P1 (다음 스프린트): 2개
- P2 (백로그): 0개

## 항목 목록

### 1. 성공/에러 메시지 하드코딩
- **현재 상태**:
  - 컨트롤러에 한국어 메시지 직접 작성
  - `"프로필이 업데이트되었습니다."`, `"알림 설정이 업데이트되었습니다."`
- **개선 필요 사항**:
  - i18n 파일로 메시지 분리
  - 다국어 지원 대비
  - 메시지 일관성 유지
- **우선순위**: P0
- **관련 파일**:
  - `app/controllers/settings/profiles_controller.rb` (L12)
  - `app/controllers/settings/notifications_controller.rb` (L12)
  - 신규: `config/locales/settings.ko.yml`
  - 신규: `config/locales/settings.en.yml`

**개선 예시**:
```ruby
# Before
redirect_to settings_profile_path, notice: "프로필이 업데이트되었습니다."

# After
redirect_to settings_profile_path, notice: t('.update_success')
```

```yaml
# config/locales/settings.ko.yml
ko:
  settings:
    profiles:
      update:
        update_success: "프로필이 업데이트되었습니다."
```

### 2. 알림 설정 기본값 마이그레이션에 하드코딩
- **현재 상태**:
  - 마이그레이션에 `default: true` 직접 지정
  - 기본값 변경 시 마이그레이션 수정 필요
- **개선 필요 사항**:
  - `User` 모델에서 기본값 정의
  - `attribute` 메서드 활용
  - 환경별 기본값 설정 가능
- **우선순위**: P1
- **관련 파일**:
  - `db/migrate/20251214155114_add_notification_settings_to_users.rb` (L5-7)
  - `app/models/user.rb`

**개선 예시**:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  attribute :notify_on_new_photo, :boolean, default: -> { Rails.application.config.default_notifications[:new_photo] }
  attribute :notify_on_comment, :boolean, default: -> { Rails.application.config.default_notifications[:comment] }
  attribute :notify_on_reaction, :boolean, default: -> { Rails.application.config.default_notifications[:reaction] }
end

# config/application.rb
config.default_notifications = {
  new_photo: true,
  comment: true,
  reaction: true
}
```

### 3. 허용된 파라미터 하드코딩
- **현재 상태**:
  - `params.require(:user).permit(:nickname)` 컨트롤러에 직접 작성
  - 파라미터 추가 시 여러 곳 수정 필요
- **개선 필요 사항**:
  - Strong Parameters를 concern으로 분리
  - 파라미터 화이트리스트 중앙 관리
  - 재사용성 향상
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/settings/profiles_controller.rb` (L20-22)
  - `app/controllers/settings/notifications_controller.rb` (L20-22)
  - 신규: `app/controllers/concerns/user_params.rb`

**개선 예시**:
```ruby
# app/controllers/concerns/user_params.rb
module UserParams
  extend ActiveSupport::Concern

  PROFILE_PARAMS = %i[nickname avatar].freeze
  NOTIFICATION_PARAMS = %i[notify_on_new_photo notify_on_comment notify_on_reaction].freeze

  def profile_params
    params.require(:user).permit(*PROFILE_PARAMS)
  end

  def notification_params
    params.require(:user).permit(*NOTIFICATION_PARAMS)
  end
end
```

### 4. 뷰 레이블 텍스트 하드코딩
- **현재 상태**:
  - ERB 템플릿에 한국어 레이블 직접 작성
  - `"이메일"`, `"닉네임"`, `"새 사진 업로드 알림"` 등
- **개선 필요 사항**:
  - i18n helper 사용
  - `model.human_attribute_name` 활용
  - 일관된 용어 사용
- **우선순위**: P0
- **관련 파일**:
  - `app/views/settings/profiles/show.html.erb` (L13, L19)
  - `app/views/settings/notifications/show.html.erb` (L13, L18, L23)
  - `config/locales/models/user.ko.yml`

**개선 예시**:
```erb
<!-- Before -->
<%= form.label :email, "이메일" %>

<!-- After -->
<%= form.label :email %>
```

```yaml
# config/locales/models/user.ko.yml
ko:
  activerecord:
    attributes:
      user:
        email: "이메일"
        nickname: "닉네임"
        notify_on_new_photo: "새 사진 업로드 알림"
        notify_on_comment: "댓글 작성 알림"
        notify_on_reaction: "반응 추가 알림"
```
