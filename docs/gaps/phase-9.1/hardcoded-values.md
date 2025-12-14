# Hardcoded Values - Phase 9.1 레이아웃

## 요약
- 총 항목 수: 7개
- P0 (즉시): 1개
- P1 (다음 스프린트): 3개
- P2 (백로그): 3개

## 항목 목록

### 1. OAuth 제공자 링크
- **현재 상태**: 모든 OAuth 로그인 링크가 "#"로 하드코딩됨
- **개선 필요 사항**:
  - config/routes.rb에 정의된 oauth_path 사용
  - `oauth_path(:apple)`, `oauth_path(:kakao)`, `oauth_path(:google)` 활용
- **우선순위**: P0 (즉시) - Phase 2 구현 시 필수
- **관련 파일**: app/views/home/index.html.erb:13,17,21

### 2. 탭바 미구현 기능 링크
- **현재 상태**: 앨범, 업로드, 알림 탭이 "#"로 하드코딩됨
- **개선 필요 사항**:
  - 해당 기능 구현 전까지 disabled 스타일 적용
  - 클릭 시 "준비 중" 메시지 표시
  - 또는 조건부 렌더링으로 숨김
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**: app/views/shared/_tabbar.html.erb:8,13,17

### 3. CSS 색상값
- **현재 상태**:
  - Tailwind 기본 색상만 사용 (gray, green, red, pink, yellow, black, white)
  - 브랜드 색상 정의 없음
- **개선 필요 사항**:
  - tailwind.config.js에 브랜드 색상 정의
  - primary, secondary, accent 색상 시스템 구축
  - CSS 변수로 다크 모드 대응
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**:
  - tailwind.config.js (신규)
  - 모든 뷰 파일

### 4. 레이아웃 높이값
- **현재 상태**:
  - 헤더 높이: h-14 (56px) 하드코딩
  - 탭바 높이: h-16 (64px) 하드코딩
  - 메인 padding: pt-14, pb-16 하드코딩
- **개선 필요 사항**:
  - CSS 변수로 정의
  - --header-height, --tabbar-height 사용
  - calc()로 동적 계산
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**:
  - app/views/layouts/application.html.erb:29
  - app/views/shared/_header.html.erb:2
  - app/views/shared/_tabbar.html.erb:2
  - app/assets/tailwind/application.css

### 5. 최대 너비값
- **현재 상태**:
  - max-w-md (28rem / 448px) 하드코딩
  - max-w-2xl (42rem / 672px) 하드코딩
- **개선 필요 사항**:
  - 디자인 시스템에 맞는 컨테이너 너비 정의
  - tailwind.config.js에서 확장
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/home/index.html.erb:8,32

### 6. z-index 값
- **현재 상태**:
  - 헤더: z-10
  - 탭바: z-10
  - 명시적인 레이어 시스템 없음
- **개선 필요 사항**:
  - z-index 레이어 시스템 정의
  - header: 100, tabbar: 90, modal: 1000 등
  - CSS 변수 또는 Tailwind 확장
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/shared/_header.html.erb:1
  - app/views/shared/_tabbar.html.erb:1

### 7. Flash 메시지 스타일
- **현재 상태**:
  - 성공: bg-green-100, border-green-500, text-green-700
  - 실패: bg-red-100, border-red-500, text-red-700
  - 직접 클래스 하드코딩
- **개선 필요 사항**:
  - 헬퍼 메서드로 추출 (flash_class_for(type))
  - success, error, warning, info 타입 지원
  - 일관된 스타일 시스템
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/layouts/application.html.erb:31-39
  - app/helpers/application_helper.rb (신규 메서드)
