# 미구현 기능 (Not Implemented) - Phase 5 사진 기능

## 요약
- 총 항목 수: 12개
- P0 (즉시): 0개
- P1 (다음 스프린트): 4개
- P2 (백로그): 8개

PRD나 설계에는 있지만 아직 구현되지 않은 기능들입니다.

---

## 항목 목록

### 1. 무한 스크롤 (Infinite Scroll)
- **현재 상태**: 페이지네이션 로직만 있고 UI 없음
- **개선 필요 사항**:
  - Stimulus controller로 스크롤 이벤트 감지
  - Turbo Frame으로 다음 페이지 자동 로드
  - 로딩 인디케이터 표시
- **우선순위**: P1
- **관련 파일**:
  - `app/views/families/photos/index.html.erb` - Turbo Frame 추가
  - `app/javascript/controllers/infinite_scroll_controller.js` 생성 필요

### 2. Background Job 처리
- **현재 상태**:
  - 이미지 처리를 동기적으로 수행
  - 대용량 파일 업로드 시 응답 지연 가능
- **개선 필요 사항**:
  - ProcessPhotoJob 생성
  - 썸네일 생성, EXIF 추출, 얼굴 인식 등 백그라운드 처리
  - NotifyFamilyJob으로 알림 전송
- **우선순위**: P1
- **관련 파일**:
  - `app/jobs/process_photo_job.rb` 생성 필요
  - `app/jobs/notify_family_job.rb` 생성 필요
  - `app/controllers/families/photos_controller.rb:create` - Job 호출

### 3. 사진 다운로드 기능
- **현재 상태**: 다운로드 버튼이나 링크 없음
- **개선 필요 사항**:
  - 원본 다운로드 링크
  - 앨범 전체 다운로드 (ZIP)
  - 다운로드 권한 체크
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb` - download 액션 추가
  - `app/views/families/photos/show.html.erb` - 다운로드 버튼

### 4. 사진 공유 기능
- **현재 상태**: 외부 공유 기능 없음
- **개선 필요 사항**:
  - 공유 링크 생성 (시간 제한, 비밀번호 옵션)
  - 소셜 미디어 공유
  - 링크 통계 (조회수)
- **우선순위**: P2
- **관련 파일**:
  - `app/models/shared_link.rb` 생성 필요
  - `app/controllers/shared_links_controller.rb` 생성 필요

### 5. 사진 편집 기능
- **현재 상태**: 캡션, 촬영일, 아이 태그만 수정 가능
- **개선 필요 사항**:
  - 이미지 회전
  - 자르기 (Crop)
  - 필터 적용
  - imgproxy 또는 Cloudinary 활용
- **우선순위**: P2
- **관련 파일**:
  - 외부 서비스 연동 또는 클라이언트 사이드 편집

### 6. 대량 삭제 기능
- **현재 상태**: 한 장씩만 삭제 가능
- **개선 필요 사항**:
  - 여러 사진 선택 UI
  - 일괄 삭제 API
  - 삭제 확인 모달
- **우선순위**: P1
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb` - bulk_destroy 액션
  - `app/views/families/photos/index.html.erb` - 체크박스 UI

### 7. 동시 업로드 제한 및 큐 관리
- **현재 상태**:
  - batch 업로드가 순차 처리
  - 동시 업로드 수 제한 없음
- **개선 필요 사항**:
  - 클라이언트에서 동시 업로드 3개로 제한
  - 업로드 큐 UI
  - 실패한 파일 재시도
- **우선순위**: P1
- **관련 파일**:
  - Stimulus controller로 큐 관리
  - `app/javascript/controllers/photo_upload_queue_controller.js`

### 8. 재시도 로직 (Upload Retry)
- **현재 상태**: 업로드 실패 시 재시도 없음
- **개선 필요 사항**:
  - 네트워크 오류 시 자동 재시도 (최대 3회)
  - 지수 백오프 (exponential backoff)
  - 실패 이유 로깅
- **우선순위**: P2
- **관련 파일**:
  - Stimulus controller 개선
  - Direct Upload 이벤트 핸들링

### 9. 타임존 처리 명시적 구현
- **현재 상태**:
  ```ruby
  <%= form.datetime_local_field :taken_at %>
  ```
  - 브라우저 로컬 시간 입력
  - 서버에서 UTC 변환 여부 불명확
- **개선 필요 사항**:
  - config.time_zone 확인
  - 뷰에서 시간 표시 시 사용자 타임존 적용
  - ISO8601 형식으로 API 응답
- **우선순위**: P2
- **관련 파일**:
  - `config/application.rb` - time_zone 설정 확인
  - `app/views/families/photos/_form.html.erb:29`

### 10. 중복 업로드 방지
- **현재 상태**: 같은 파일을 여러 번 업로드 가능
- **개선 필요 사항**:
  - 파일 해시(MD5/SHA256) 계산
  - 중복 파일 감지
  - 사용자에게 알림 후 스킵 또는 링크 생성
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb` - validate :unique_image
  - Background Job으로 해시 계산

### 11. 사진 검색 기능
- **현재 상태**: 아이별, 월별 필터만 가능
- **개선 필요 사항**:
  - 캡션 검색
  - 날짜 범위 검색
  - 태그 검색 (향후 태그 기능 추가 시)
  - Elasticsearch 또는 pg_search 활용
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:index` - search 파라미터
  - `app/models/photo.rb` - search scope

### 12. 업로드 통계 및 분석
- **현재 상태**: 업로드 관련 통계 없음
- **개선 필요 사항**:
  - 월별 업로드 수
  - 가족 구성원별 업로드 통계
  - 저장 공간 사용량
  - 인기 있는 사진 (반응 많은 순)
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb` - 통계 scope
  - Dashboard 페이지 필요

---

## 구현 우선순위

### P1 우선순위 (다음 스프린트)
1. **무한 스크롤**: 사용자 경험 개선, 페이지네이션 대체
2. **Background Job**: 성능 개선, 확장성 확보
3. **대량 삭제**: 사용자 편의성
4. **동시 업로드 큐**: 대량 업로드 시 필수

### P2 우선순위 (백로그)
- 사진 다운로드
- 공유 기능
- 편집 기능
- 재시도 로직
- 타임존 처리
- 중복 방지
- 검색 기능
- 통계 기능

---

## 기술 부채 노트

- **Background Job 미구현**은 확장성에 큰 영향
- **무한 스크롤** 없이는 사용자 경험이 불완전
- **대량 삭제** 없으면 관리가 불편

---

**작성일**: 2025-12-15
**검토 필요**: Background Job과 무한 스크롤은 우선 구현 권장
