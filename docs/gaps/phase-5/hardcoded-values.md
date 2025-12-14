# 하드코딩된 값 (Hardcoded Values) - Phase 5 사진 기능

## 요약
- 총 항목 수: 6개
- P0 (즉시): 0개
- P1 (다음 스프린트): 2개
- P2 (백로그): 4개

설정 파일이나 상수로 분리해야 할 하드코딩된 값들입니다.

---

## 항목 목록

### 1. 페이지당 아이템 수 (per_page)
- **현재 상태**:
  ```ruby
  # app/controllers/families/photos_controller.rb:25
  per_page = 20
  ```
  - 컨트롤러에 하드코딩
  - 변경 시 코드 수정 필요
- **개선 필요 사항**:
  - `config/initializers/pagination.rb` 생성
  - 또는 `Rails.application.config.pagination_default = 20`
  - 상수로 분리: `Photo::PER_PAGE = 20`
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:25`

### 2. 파일 크기 제한 (MAX_FILE_SIZE)
- **현재 상태**:
  ```ruby
  # app/models/photo.rb:4
  MAX_FILE_SIZE = 50.megabytes
  ```
  - 모델 상수로 정의됨 (괜찮지만 설정으로 분리 가능)
- **개선 필요 사항**:
  - `config/settings.yml` 또는 환경변수로 관리
  - 환경별로 다른 값 설정 가능 (development: 10MB, production: 50MB)
  - Rails credentials 사용 고려
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb:4,36`

### 3. 허용 파일 타입 (ALLOWED_CONTENT_TYPES)
- **현재 상태**:
  ```ruby
  # app/models/photo.rb:5
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/heic image/webp].freeze
  ```
  - 모델 상수로 하드코딩
- **개선 필요 사항**:
  - 설정 파일로 분리
  - 동영상 추가 시 쉽게 변경 가능하도록
  - 예: `Rails.application.config.photo.allowed_types`
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb:5,32`
  - `app/views/families/photos/_form.html.erb:16` - accept 속성도 동일하게

### 4. 성공/에러 메시지
- **현재 상태**:
  ```ruby
  redirect_to family_photo_path(@family, @photo), notice: "사진이 업로드되었습니다."
  redirect_to family_photos_path(@family), notice: "사진이 수정되었습니다."
  redirect_to family_photos_path(@family), notice: "사진이 삭제되었습니다."
  ```
  - 한글 메시지가 컨트롤러에 하드코딩
  - i18n 사용 안함
- **개선 필요 사항**:
  - `config/locales/ko.yml`에 정의
  ```yaml
  ko:
    families:
      photos:
        create:
          success: "사진이 업로드되었습니다."
        update:
          success: "사진이 수정되었습니다."
        destroy:
          success: "사진이 삭제되었습니다."
  ```
  - 컨트롤러에서 `t('.create.success')` 사용
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:46,79,87`

### 5. 에러 메시지 (모델 Validation)
- **현재 상태**:
  ```ruby
  errors.add(:image, "허용되지 않는 파일 형식입니다. (허용: JPEG, PNG, HEIC, WebP)")
  errors.add(:image, "파일 크기가 50MB를 초과합니다.")
  ```
  - 모델에 한글 에러 메시지 하드코딩
- **개선 필요 사항**:
  - `config/locales/ko.yml`에 정의
  ```yaml
  activerecord:
    errors:
      models:
        photo:
          attributes:
            image:
              invalid_content_type: "허용되지 않는 파일 형식입니다. (허용: %{types})"
              too_large: "파일 크기가 %{max_size}를 초과합니다."
  ```
  - 동적 값 삽입 가능
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb:33,37`

### 6. Grid 레이아웃 클래스
- **현재 상태**:
  ```erb
  <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
  ```
  - Tailwind 클래스가 뷰에 하드코딩
- **개선 필요 사항**:
  - 설정으로 분리하거나 partial로 추출
  - ViewComponent 사용 시 props로 전달
  - 예: `<%= render PhotoGridComponent.new(columns: { sm: 2, md: 3, lg: 4 }) %>`
- **우선순위**: P2
- **관련 파일**:
  - `app/views/families/photos/index.html.erb:12`

---

## 리팩토링 계획

### P1 우선순위 (다음 스프린트)
1. **페이지당 아이템 수**: 재사용 가능하도록 상수화
2. **i18n 메시지**: 다국어 지원 대비, 유지보수성 향상

### P2 우선순위 (백로그)
1. **파일 크기/타입 제한**: 환경별 설정 가능하도록
2. **에러 메시지**: 일관성 있는 i18n 적용
3. **Grid 클래스**: 재사용 가능한 컴포넌트화

---

## 설정 파일 구조 제안

```ruby
# config/initializers/photo_settings.rb
Rails.application.config.photo = ActiveSupport::OrderedOptions.new
Rails.application.config.photo.max_file_size = ENV.fetch("PHOTO_MAX_FILE_SIZE", 50).to_i.megabytes
Rails.application.config.photo.allowed_types = %w[image/jpeg image/png image/heic image/webp]
Rails.application.config.photo.per_page = ENV.fetch("PHOTO_PER_PAGE", 20).to_i
```

또는 config gem 사용:

```yaml
# config/settings.yml
photo:
  max_file_size: 52428800  # 50MB in bytes
  allowed_types:
    - image/jpeg
    - image/png
    - image/heic
    - image/webp
  per_page: 20
```

---

**작성일**: 2025-12-15
**검토 필요**: i18n 적용은 다국어 지원 전에 미리 준비 권장
