# 의도적 단순화 (Intentional Simplifications) - Phase 5 사진 기능

## 요약
- 총 항목 수: 8개
- P0 (즉시): 0개
- P1 (다음 스프린트): 3개
- P2 (백로그): 5개

MVP 출시를 위해 의도적으로 단순화하거나 제외한 기능들입니다.

---

## 항목 목록

### 1. 이미지 리사이징 및 Variant 생성
- **현재 상태**:
  - 원본 이미지만 저장
  - Active Storage variant 미사용
  - 썸네일/중간/대형 크기 없음
- **개선 필요 사항**:
  - thumbnail (300x300), medium (800x800), large (1600x1600) variant 생성
  - 리스트 뷰에서 썸네일 사용하여 로딩 속도 개선
  - 상세 뷰에서 적절한 크기 이미지 제공
- **우선순위**: P1
- **관련 파일**:
  - `app/models/photo.rb` - variant 정의 필요
  - `app/views/families/photos/index.html.erb` - 썸네일 사용
  - `app/views/families/photos/show.html.erb` - 최적화된 크기 사용

### 2. 간단한 Offset 기반 페이지네이션
- **현재 상태**:
  ```ruby
  page = (params[:page] || 1).to_i
  per_page = 20
  @photos = @photos.offset((page - 1) * per_page).limit(per_page)
  ```
  - Kaminari나 Pagy 같은 gem 미사용
  - 커서 기반 페이지네이션 미구현
- **개선 필요 사항**:
  - 대량 데이터에서 성능 문제 발생 가능 (offset이 클수록 느림)
  - Pagy gem 도입 또는 커서 기반 페이지네이션 구현 검토
- **우선순위**: P2
- **관련 파일**:
  - `app/controllers/families/photos_controller.rb:23-26`

### 3. 페이지네이션 UI 부재
- **현재 상태**:
  - 페이지네이션 로직은 있지만 UI가 없음
  - 사용자가 다음 페이지로 이동할 방법 없음
- **개선 필요 사항**:
  - 페이지 번호 표시 UI 추가
  - 이전/다음 버튼 구현
  - 무한 스크롤 방식 고려
- **우선순위**: P1
- **관련 파일**:
  - `app/views/families/photos/index.html.erb` - 페이지네이션 UI 필요

### 4. 동영상 지원 제외
- **현재 상태**:
  ```ruby
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/heic image/webp].freeze
  ```
  - 이미지만 지원, video/mp4 등 동영상 타입 없음
- **개선 필요 사항**:
  - PRD에는 동영상 지원 언급되어 있음
  - video/mp4, video/quicktime 추가
  - 동영상 썸네일 생성 로직 필요
  - 용량 제한 별도 설정 필요 (동영상은 더 클 수 있음)
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb:5`
  - `app/views/families/photos/_form.html.erb:16` - accept 속성

### 5. EXIF 메타데이터 추출 없음
- **현재 상태**:
  - 촬영일(taken_at)을 수동으로 입력
  - EXIF에서 자동 추출하지 않음
- **개선 필요 사항**:
  - exifr gem으로 EXIF 데이터 읽기
  - 촬영 날짜, 위치, 카메라 정보 자동 추출
  - 사용자가 수정할 수 있도록 기본값으로 설정
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb` - EXIF 추출 로직 추가
  - `app/controllers/families/photos_controller.rb:new` - 기본값 설정

### 6. 워터마크 기능 없음
- **현재 상태**: 워터마크 없이 원본 이미지만 저장
- **개선 필요 사항**:
  - 가족명이나 로고를 워터마크로 추가 옵션
  - 공유 시 출처 표시
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb` - 워터마크 처리

### 7. 얼굴 인식 및 자동 태깅 제외
- **현재 상태**:
  - 아이 태깅을 수동으로 선택
  - 얼굴 인식 기능 없음
- **개선 필요 사항**:
  - AWS Rekognition 또는 Vision API 연동
  - 얼굴 감지 후 아이 자동 태깅
  - 여러 아이가 있는 사진 처리
- **우선순위**: P2
- **관련 파일**:
  - `app/models/photo.rb` - belongs_to :child (단일만 지원)
  - Background Job 필요

### 8. 앨범 기능 미구현
- **현재 상태**:
  - Album 모델은 존재하지만 UI 미구현
  - 모든 사진이 타임라인에만 표시
- **개선 필요 사항**:
  - 앨범 생성/편집 UI
  - 사진을 앨범에 추가/제거
  - 앨범별 사진 조회
- **우선순위**: P1
- **관련 파일**:
  - `app/models/album.rb` (존재 여부 확인 필요)
  - 컨트롤러 및 뷰 새로 구현

---

## 다음 단계

### P1 우선순위 (다음 스프린트)
1. **이미지 Variant 생성**: 성능 개선을 위해 필수
2. **페이지네이션 UI**: 사용자가 여러 페이지 탐색 불가능
3. **앨범 기능**: 사진 정리 기능으로 사용자 가치 높음

### P2 우선순위 (백로그)
- 동영상 지원
- EXIF 자동 추출
- 워터마크
- 얼굴 인식
- 고급 페이지네이션

---

**작성일**: 2025-12-15
**검토 필요**: 이미지 variant와 페이지네이션 UI는 빠른 시일 내 구현 권장
