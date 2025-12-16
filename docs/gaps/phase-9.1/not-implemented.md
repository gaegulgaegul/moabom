# Not Implemented - Phase 9.1 레이아웃

## 요약
- 총 항목 수: 8개
- P0 (즉시): 0개
- P1 (다음 스프린트): 2개
- P2 (백로그): 6개

## 항목 목록

### 1. 다크 모드
- **현재 상태**: 다크 모드 완전 미구현
- **개선 필요 사항**:
  - Tailwind CSS dark: 모드 설정
  - 시스템 설정 감지 (prefers-color-scheme)
  - 사용자 선택 저장 (localStorage)
  - 다크 모드 토글 UI
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/assets/tailwind/application.css
  - 모든 뷰 파일

### 2. 접근성 (ARIA Labels)
- **현재 상태**:
  - 탭바 아이콘에 aria-label 없음
  - 로그인 버튼에 aria-label 없음
  - role 속성 일부만 적용 (alert만)
- **개선 필요 사항**:
  - 모든 인터랙티브 요소에 aria-label 추가
  - 스크린 리더 테스트
  - 키보드 네비게이션 개선
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**:
  - app/views/shared/_header.html.erb
  - app/views/shared/_tabbar.html.erb
  - app/views/home/index.html.erb

### 3. Turbo Native 전용 최적화
- **현재 상태**:
  - 기본 웹뷰 지원만 구현
  - Native Bridge API 미연동
  - Native 전용 스타일 없음
- **개선 필요 사항**:
  - Turbo.navigator 감지
  - Native 환경에서 헤더/탭바 숨김 옵션
  - Native 전용 인터랙션 (스와이프 등)
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/layouts/application.html.erb

### 4. 로딩 상태 표시
- **현재 상태**:
  - 페이지 전환 시 로딩 표시 없음
  - Turbo 기본 프로그레스 바만 사용
- **개선 필요 사항**:
  - Turbo:before-fetch-request 이벤트 리스너
  - 커스텀 로딩 스피너/스켈레톤
  - 느린 네트워크 환경 대응
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**:
  - app/views/layouts/application.html.erb
  - app/javascript/controllers/ (신규)

### 5. 에러 상태 표시
- **현재 상태**:
  - 네트워크 에러 시 기본 브라우저 에러만 표시
  - Turbo 에러 처리 없음
- **개선 필요 사항**:
  - Turbo:fetch-request-error 이벤트 리스너
  - 사용자 친화적 에러 메시지
  - 재시도 버튼
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/layouts/application.html.erb
  - app/javascript/controllers/ (신규)

### 6. 오프라인 지원
- **현재 상태**: 오프라인 시 앱 사용 불가
- **개선 필요 사항**:
  - Service Worker 등록
  - 오프라인 페이지
  - 캐시 전략 (네트워크 우선, 캐시 폴백)
- **우선순위**: P2 (백로그)
- **관련 파일**: 신규 파일 필요

### 7. 페이지 전환 애니메이션
- **현재 상태**: 기본 페이지 전환만 지원
- **개선 필요 사항**:
  - View Transitions API 활용
  - Turbo morphing 설정
  - 부드러운 페이드 인/아웃
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/assets/tailwind/application.css
  - app/views/layouts/application.html.erb

### 8. 반응형 테스트
- **현재 상태**:
  - 데스크톱 해상도 테스트만 존재
  - 모바일 뷰포트 테스트 없음
  - 태블릿 테스트 없음
- **개선 필요 사항**:
  - Capybara resize_window을 사용한 다양한 해상도 테스트
  - 모바일 (375px), 태블릿 (768px), 데스크톱 (1024px) 테스트
  - Safe Area 동작 테스트
- **우선순위**: P2 (백로그)
- **관련 파일**: test/system/layout_test.rb
