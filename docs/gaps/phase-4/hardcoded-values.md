# 하드코딩 (Hardcoded Values)

> 설정값이나 상수로 분리해야 할 부분

---

## 1. 초대 만료 기간

| 항목 | 내용 |
|-----|------|
| **파일** | `app/models/invitation.rb:25` |
| **현재 값** | `7.days.from_now` |
| **우선순위** | P2 |

### 현재 코드

```ruby
def set_default_expires_at
  self.expires_at ||= 7.days.from_now
end
```

### 개선 방향

```ruby
# config/application.rb
config.invitation_expiry_days = 7

# app/models/invitation.rb
def set_default_expires_at
  self.expires_at ||= Rails.configuration.invitation_expiry_days.days.from_now
end
```

또는 상수로:

```ruby
# app/models/invitation.rb
EXPIRY_DAYS = 7

def set_default_expires_at
  self.expires_at ||= EXPIRY_DAYS.days.from_now
end
```

---

## 2. 가족 이름 기본값

| 항목 | 내용 |
|-----|------|
| **파일** | `app/controllers/onboarding/children_controller.rb:30` |
| **현재 값** | `"#{current_user.nickname}의 가족"` |
| **우선순위** | P2 |

### 현재 코드

```ruby
family = Family.create!(name: "#{current_user.nickname}의 가족")
```

### 개선 방향

```yaml
# config/locales/ko.yml
ko:
  families:
    default_name: "%{nickname}의 가족"
```

```ruby
# 컨트롤러
family = Family.create!(
  name: I18n.t('families.default_name', nickname: current_user.nickname)
)
```

---

## 3. 성별 표시 텍스트

| 항목 | 내용 |
|-----|------|
| **파일** | `app/views/families/children/index.html.erb:14` |
| **현재 값** | `"남"`, `"여"` |
| **우선순위** | P1 |

### 현재 코드

```erb
<span class="child-gender"><%= child.gender == "male" ? "남" : "여" %></span>
```

### 개선 방향

```yaml
# config/locales/ko.yml
ko:
  activerecord:
    attributes:
      child:
        genders:
          male: 남
          female: 여
```

```erb
<span class="child-gender">
  <%= t("activerecord.attributes.child.genders.#{child.gender}") %>
</span>
```

또는 Human Enum 사용:

```ruby
# app/models/child.rb
def gender_display
  I18n.t("activerecord.attributes.child.genders.#{gender}")
end
```

```erb
<span class="child-gender"><%= child.gender_display %></span>
```

---

## 4. 버튼 텍스트

| 항목 | 내용 |
|-----|------|
| **파일** | `app/views/onboarding/invites/show.html.erb:13` |
| **현재 값** | `"복사"` |
| **우선순위** | P2 |

### 현재 코드

```erb
<button type="button" onclick="navigator.clipboard.writeText('...')">
  복사
</button>
```

### 개선 방향

```yaml
# config/locales/ko.yml
ko:
  buttons:
    copy: 복사
    copied: 복사됨
```

```erb
<button type="button"
        data-controller="clipboard"
        data-clipboard-text="<%= @invite_url %>">
  <%= t('buttons.copy') %>
</button>
```

---

## 5. 토큰 길이

| 항목 | 내용 |
|-----|------|
| **파일** | `app/models/invitation.rb:21` |
| **현재 값** | `SecureRandom.hex(16)` (32자) |
| **우선순위** | P2 |

### 현재 코드

```ruby
def generate_token
  self.token = SecureRandom.hex(16)
end
```

### 개선 방향

```ruby
# app/models/invitation.rb
TOKEN_LENGTH = 16  # 결과: 32자 hex 문자열

def generate_token
  self.token = SecureRandom.hex(TOKEN_LENGTH)
end
```

---

## 6. Flash 메시지

| 파일 | 메시지 | 개선 필요 |
|-----|-------|---------|
| `families_controller.rb:14` | `"가족 정보가 수정되었습니다."` | i18n |
| `families_controller.rb:23` | `"접근 권한이 없습니다."` | i18n |
| `members_controller.rb:20` | `"자신의 역할은 변경할 수 없습니다."` | i18n |
| `children_controller.rb:24` | `"아이가 등록되었습니다."` | i18n |
| ... | ... | ... |

### 개선 방향

```yaml
# config/locales/ko.yml
ko:
  flash:
    families:
      updated: 가족 정보가 수정되었습니다.
      unauthorized: 접근 권한이 없습니다.
    members:
      cannot_change_self: 자신의 역할은 변경할 수 없습니다.
      role_changed: 역할이 변경되었습니다.
      removed: 구성원이 제거되었습니다.
    children:
      created: 아이가 등록되었습니다.
      updated: 아이 정보가 수정되었습니다.
      deleted: 아이가 삭제되었습니다.
```

```ruby
# 컨트롤러
redirect_to @family, notice: t('.updated')
```

---

## 7. 뷰 텍스트 전반

### 아직 i18n이 적용되지 않은 뷰 파일

| 파일 | 하드코딩된 텍스트 |
|-----|-----------------|
| `families/show.html.erb` | "가족 정보", "가족 이름", "수정" |
| `families/members/index.html.erb` | "구성원 관리", "역할", "저장", "내보내기" |
| `families/children/index.html.erb` | "아이 관리", "아이 추가" |
| `families/children/_form.html.erb` | "이름", "생년월일", "성별", "선택하세요" |
| `onboarding/*.html.erb` | 대부분의 텍스트 |
| `invitations/show.html.erb` | "초대", "수락하기" |

---

## 요약

| 항목 | 위치 | 우선순위 | 영향도 |
|-----|-----|---------|-------|
| 성별 표시 | View | P1 | 다국어 지원 |
| Flash 메시지 | Controllers | P2 | 다국어 지원 |
| 초대 만료 기간 | Model | P2 | 설정 유연성 |
| 가족 이름 기본값 | Controller | P2 | 다국어 지원 |
| 버튼 텍스트 | Views | P2 | 다국어 지원 |
| 토큰 길이 | Model | P2 | 코드 가독성 |

### i18n 적용 권장 순서

1. **P1**: 사용자에게 직접 보이는 텍스트 (성별, 역할명)
2. **P2**: Flash 메시지
3. **P2**: 폼 라벨 및 버튼
4. **P2**: 설정값 (만료 기간, 토큰 길이)
