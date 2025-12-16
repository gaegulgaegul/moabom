# 누락된 에러 처리 (Missing Error Handling) - Phase 5 사진 기능

## 요약
- 총 항목 수: 10개
- P0 (즉시): 4개
- P1 (다음 스프린트): 4개
- P2 (백로그): 2개

예외 상황이나 엣지 케이스에 대한 에러 처리가 부족한 부분입니다.

---

## 항목 목록

### 1. Batch 업로드 빈 배열 처리
- **현재 상태**:
  ```ruby
  def batch
    results = []
    (params[:photos] || []).each do |photo_params|
      # ...
    end
    render json: { results: results }
  end
  ```
  - `params[:photos]`가 없거나 빈 배열이면 빈 results 반환
  - 명시적인 검증 없음
- **개선 필요 사항**:
  ```ruby
  if params[:photos].blank?
    return render json: { error: "업로드할 사진을 선택해주세요." }, status: :bad_request
  end

  if params[:photos].size > 50
    return render json: { error: "한 번에 최대 50장까지 업로드할 수 있습니다." }, status: :bad_request
  end
  ```
- **우선순위**: P0
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:52-72`

### 2. 파일 타입 검증 중복 (모델만 체크)
- **현재 상태**:
  - 파일 타입 검증이 모델(`acceptable_image`)에만 있음
  - 컨트롤러에서 사전 검증 없음
  - 업로드 후 validation 실패 시 이미 저장된 blob 정리 필요
- **개선 필요 사항**:
  - 컨트롤러 레벨에서도 검증
  - Direct Upload 시 클라이언트에서 accept 속성으로 1차 검증 (이미 있음)
  - 서버에서 content_type 재검증 (MIME 스푸핑 방지)
  ```ruby
  unless ALLOWED_CONTENT_TYPES.include?(params[:photo][:image].content_type)
    # early return
  end
  ```
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:create`
  - `app/models/photo.rb:29-39`

### 3. Image.attach 실패 시 에러 처리
- **현재 상태**:
  ```ruby
  photo.image.attach(photo_params[:image]) if photo_params[:image]
  ```
  - attach 실패 시 예외 처리 없음
  - blob 저장 실패, 디스크 공간 부족 등 고려 안됨
- **개선 필요 사항**:
  ```ruby
  begin
    photo.image.attach(photo_params[:image]) if photo_params[:image]
  rescue ActiveStorage::IntegrityError => e
    Rails.logger.error "Image attach failed: #{e.message}"
    photo.errors.add(:image, "파일 업로드 중 오류가 발생했습니다.")
  end
  ```
- **우선순위**: P0
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:62`

### 4. Set_family nil 체크만 하고 로깅 없음
- **현재 상태**:
  ```ruby
  def set_family
    @family = current_user.families.find_by(id: params[:family_id])
    redirect_to root_path, alert: "접근 권한이 없습니다." unless @family
  end
  ```
  - nil일 때 redirect만 하고 로그 없음
  - 보안 이벤트 추적 불가
- **개선 필요 사항**:
  ```ruby
  def set_family
    @family = current_user.families.find_by(id: params[:family_id])

    unless @family
      Rails.logger.warn "Unauthorized access attempt: user=#{current_user.id}, family_id=#{params[:family_id]}"
      redirect_to root_path, alert: "접근 권한이 없습니다."
    end
  end
  ```
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/concerns/family_accessible.rb:8-11`

### 5. Direct Upload 실패 처리 없음
- **현재 상태**:
  ```erb
  <%= form.file_field :image, direct_upload: true %>
  ```
  - Direct Upload 실패 시 사용자 피드백 없음
  - 네트워크 오류, 서버 오류 등 처리 안됨
- **개선 필요 사항**:
  - Stimulus controller로 `direct-upload:error` 이벤트 리스닝
  ```javascript
  document.addEventListener('direct-upload:error', event => {
    const { error } = event.detail
    alert(`업로드 실패: ${error}`)
  })
  ```
- **우선순위**: P0
- **관련 파일**:
  - `app/views/families/photos/_form.html.erb:18`
  - Stimulus controller 추가 필요

### 6. Acceptable_image에서 blob nil 체크 부족
- **현재 상태**:
  ```ruby
  def acceptable_image
    return unless image.attached?

    unless ALLOWED_CONTENT_TYPES.include?(image.blob.content_type)
      # ...
    end
  end
  ```
  - `image.attached?`는 체크하지만 `image.blob`이 nil일 수 있음 (rare case)
- **개선 필요 사항**:
  ```ruby
  def acceptable_image
    return unless image.attached?
    return unless image.blob.present?  # 추가 안전장치

    unless ALLOWED_CONTENT_TYPES.include?(image.blob.content_type)
      # ...
    end
  end
  ```
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb:29-39`

### 7. Destroy 실패 시 에러 처리 없음
- **현재 상태**:
  ```ruby
  def destroy
    @photo.destroy
    redirect_to family_photos_path(@family), notice: "사진이 삭제되었습니다."
  end
  ```
  - destroy 실패 가능성 (dependent 레코드 삭제 실패 등) 무시
- **개선 필요 사항**:
  ```ruby
  def destroy
    if @photo.destroy
      redirect_to family_photos_path(@family), notice: "사진이 삭제되었습니다."
    else
      redirect_to family_photo_path(@family, @photo), alert: "삭제에 실패했습니다: #{@photo.errors.full_messages.join(', ')}"
    end
  end
  ```
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:85-88`

### 8. JSON 파싱 에러 처리 (Batch)
- **현재 상태**:
  - `params[:photos]`가 배열이 아닐 경우 처리 없음
  - 잘못된 JSON 형식 전송 시 500 에러 가능
- **개선 필요 사항**:
  ```ruby
  def batch
    unless params[:photos].is_a?(Array)
      return render json: { error: "Invalid format" }, status: :bad_request
    end
    # ...
  end
  ```
- **우선순위**: P0
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:52-72`

### 9. 동시성 문제 (Race Condition)
- **현재 상태**:
  - 같은 사진을 동시에 업로드하면 중복 생성 가능
  - 트랜잭션 격리 레벨 고려 없음
- **개선 필요 사항**:
  - 유니크 제약 조건 추가 (예: 파일 해시)
  - 낙관적 잠금(Optimistic Locking) 또는 비관적 잠금 고려
  ```ruby
  # Migration
  add_index :photos, [:family_id, :file_hash], unique: true
  ```
- **우선순위**: P2
- **관련 파일**:
  - `db/migrate/` - 새 마이그레이션
  - `app/models/photo.rb` - 유효성 검증

### 10. 페이지 파라미터 검증 부족
- **현재 상태**:
  ```ruby
  page = (params[:page] || 1).to_i
  ```
  - 음수나 비정상적으로 큰 값 처리 안됨
  - `params[:page] = "abc"` → 0으로 변환
- **개선 필요 사항**:
  ```ruby
  page = [params[:page].to_i, 1].max  # 최소 1
  page = [page, 1000].min              # 최대 1000 (DoS 방지)
  ```
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:24`

---

## 에러 처리 우선순위

### P0 우선순위 (즉시 수정)
1. **Batch 업로드 빈 배열 검증**: 잘못된 요청 방지
2. **Image.attach 실패 처리**: 데이터 일관성
3. **Direct Upload 실패 피드백**: 사용자 경험
4. **JSON 파싱 에러**: 500 에러 방지

### P1 우선순위 (다음 스프린트)
1. **파일 타입 이중 검증**: 보안 강화
2. **Set_family 로깅**: 보안 감사
3. **Destroy 실패 처리**: 데이터 정합성
4. **페이지 파라미터 검증**: DoS 방지

### P2 우선순위 (백로그)
1. **Blob nil 체크**: 엣지 케이스 방어
2. **동시성 문제**: 대규모 트래픽 대비

---

## 에러 로깅 전략

### 로그 레벨 가이드
- **ERROR**: 즉시 조치 필요 (파일 업로드 실패, DB 오류)
- **WARN**: 비정상적인 접근 시도, 검증 실패
- **INFO**: 정상 업로드, 삭제 등 주요 이벤트

### Sentry/Rollbar 연동
```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
end
```

---

**작성일**: 2025-12-15
**검토 필요**: P0 에러 처리는 즉시 수정 권장 (보안 및 안정성)
