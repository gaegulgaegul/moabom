# 임시 구현 (Temporary Implementations) - Phase 5 사진 기능

## 요약
- 총 항목 수: 7개
- P0 (즉시): 2개
- P1 (다음 스프린트): 3개
- P2 (백로그): 2개

작동은 하지만 프로덕션 수준으로 개선이 필요한 임시 구현입니다.

---

## 항목 목록

### 1. Batch 업로드 트랜잭션 부재
- **현재 상태**:
  ```ruby
  def batch
    results = []
    (params[:photos] || []).each do |photo_params|
      photo = @family.photos.build(...)
      if photo.save
        results << { success: true, ... }
      else
        results << { success: false, ... }
      end
    end
  end
  ```
  - 부분 성공 허용 (일부만 성공해도 커밋)
  - 트랜잭션 없음
- **개선 필요 사항**:
  - 전체 성공/실패 옵션 제공
  - `ActiveRecord::Base.transaction` 사용 고려
  - 실패 시 이미 업로드된 파일 정리 로직 필요
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:52-72`

### 2. 간단한 권한 체크만 존재
- **현재 상태**:
  ```ruby
  def set_family
    @family = current_user.families.find_by(id: params[:family_id])
    redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
  end
  ```
  - 가족 구성원인지만 확인
  - 역할 기반 권한 체크 없음 (viewer, member, admin)
  - uploader만 수정/삭제 가능한지 컨트롤러에서 체크 안함
- **개선 필요 사항**:
  - Pundit 또는 CanCanCan 도입
  - PhotoPolicy 구현
  - viewer는 보기만, member는 업로드, admin은 전체 삭제 가능
- **우선순위**: P0
- **관련 파일**:
  - `app/controllers/concerns/family_accessible.rb:8-11`
  - `app/controllers/families/photos_controller.rb:74-88`

### 3. Direct Upload 진행률 표시 없음
- **현재 상태**:
  ```erb
  <%= form.file_field :image, direct_upload: true %>
  ```
  - Active Storage Direct Upload 사용
  - 진행률 UI 없음
- **개선 필요 사항**:
  - Stimulus controller로 업로드 진행률 표시
  - 큰 파일 업로드 시 사용자 피드백 필요
  - 업로드 실패 시 재시도 옵션
- **우선순위**: P1
- **관련 파일**:
  - `app/views/families/photos/_form.html.erb:18`
  - Stimulus controller 추가 필요

### 4. Index 뷰의 N+1 위험
- **현재 상태**:
  ```erb
  <% @family.children.each do |child| %>
    <%= link_to child.name, ... %>
  <% end %>
  ```
  - `@family.children`에서 쿼리 발생 가능
  - 컨트롤러에서 `@photos = @family.photos.includes(:uploader, :child)`는 했지만 children은 별도
- **개선 필요 사항**:
  - 컨트롤러에서 `@children = @family.children` 미리 로드
  - 또는 캐싱 적용
- **우선순위**: P0
- **관련 파일**:
  - `app/views/families/photos/index.html.erb:6-8`
  - `app/controllers/families/photos_controller.rb:12-31`

### 5. Offset 페이지네이션 성능 문제
- **현재 상태**:
  ```ruby
  @photos = @photos.offset((page - 1) * per_page).limit(per_page)
  ```
  - offset이 커질수록 쿼리 느려짐 (예: 10,000번째 페이지)
- **개선 필요 사항**:
  - Pagy gem 도입 (더 효율적)
  - 커서 기반 페이지네이션 검토 (무한 스크롤에 적합)
  - `taken_at` 기준 커서 사용
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:23-26`

### 6. 성공/에러 메시지 하드코딩
- **현재 상태**:
  ```ruby
  redirect_to family_photo_path(@family, @photo), notice: "사진이 업로드되었습니다."
  redirect_to family_photos_path(@family), notice: "사진이 삭제되었습니다."
  ```
  - i18n 사용 안함
  - 메시지가 컨트롤러에 하드코딩
- **개선 필요 사항**:
  - `config/locales/ko.yml`에 메시지 정의
  - `t('.created')`, `t('.destroyed')` 사용
  - 다국어 지원 대비
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:46,79,87`

### 7. JSON 응답 형식 일관성 부족
- **현재 상태**:
  ```ruby
  # index
  format.json { render json: { data: @photos.as_json(...) } }

  # batch
  render json: { results: results }
  ```
  - 응답 구조가 액션마다 다름
  - 에러 응답 형식도 미정의
- **개선 필요 사항**:
  - API 응답 표준 형식 정의
  - Serializer 도입 (ActiveModel::Serializer 또는 jsonapi-serializer)
  - 에러 응답: `{ error: { code: "", message: "", details: {} } }`
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:30,71`
  - docs/features/mvp/API_DESIGN.md 참조 필요

---

## 개선 계획

### P0 우선순위 (즉시 개선)
1. **역할 기반 권한 체크**: 보안 문제, 빠른 수정 필요
2. **N+1 쿼리 방지**: 성능 문제, index 액션 최적화

### P1 우선순위 (다음 스프린트)
1. **Batch 업로드 트랜잭션**: 데이터 일관성
2. **Direct Upload 진행률**: 사용자 경험 개선
3. **JSON 응답 표준화**: API 일관성

### P2 우선순위 (백로그)
1. **페이지네이션 개선**: 대량 데이터 대비
2. **i18n 메시지**: 유지보수성

---

**작성일**: 2025-12-15
**검토 필요**: P0 항목은 보안/성능 이슈이므로 우선 처리 필요
