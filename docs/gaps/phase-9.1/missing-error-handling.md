# Missing Error Handling - Phase 9.1 레이아웃

## 요약
- 총 항목 수: 6개
- P0 (즉시): 0개
- P1 (다음 스프린트): 2개
- P2 (백로그): 4개

## 항목 목록

### 1. Flash 메시지 닫기 기능
- **현재 상태**:
  - Flash 메시지가 표시되면 새로고침 전까지 계속 표시됨
  - 사용자가 수동으로 닫을 방법 없음
- **개선 필요 사항**:
  - 닫기 버튼 추가 (×)
  - Stimulus 컨트롤러로 클릭 시 제거
  - 자동 사라짐과 병행
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**: app/views/layouts/application.html.erb:30-40

### 2. 네트워크 에러 처리
- **현재 상태**:
  - Turbo 요청 실패 시 기본 브라우저 에러만 표시
  - 사용자에게 재시도 옵션 없음
- **개선 필요 사항**:
  - turbo:fetch-request-error 이벤트 리스너
  - 사용자 친화적 에러 메시지 표시
  - "다시 시도" 버튼 제공
  - 오프라인 상태 감지 및 안내
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**:
  - app/views/layouts/application.html.erb
  - app/javascript/controllers/error_handler_controller.js (신규)

### 3. 이미지 로드 실패 처리
- **현재 상태**:
  - 파비콘, 아이콘 파일이 없을 경우 404 에러만 발생
  - 대체 이미지 없음
- **개선 필요 사항**:
  - 실제 아이콘 파일 준비 (public/icon.png, public/icon.svg)
  - 또는 onerror 핸들러로 대체 이미지 표시
  - 이미지 경로를 Rails asset pipeline으로 관리
- **우선순위**: P2 (백로그)
- **관련 파일**: app/views/layouts/application.html.erb:17-19

### 4. OAuth 콜백 에러 처리
- **현재 상태**:
  - OAuth 로그인 실패 시 에러 처리 미정의
  - 사용자 취소 시 처리 없음
- **개선 필요 사항**:
  - 로그인 실패 시 flash[:alert] 표시
  - 사용자 친화적 에러 메시지
  - 재시도 옵션 제공
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/home/index.html.erb
  - app/controllers/oauth_controller.rb (Phase 2에서 구현)

### 5. 탭바 미구현 기능 클릭 처리
- **현재 상태**:
  - 앨범, 업로드, 알림 탭 클릭 시 "#"로 이동
  - 사용자에게 피드백 없음
- **개선 필요 사항**:
  - 클릭 시 "준비 중입니다" Toast 메시지 표시
  - 또는 disabled 상태로 클릭 방지
  - Stimulus 컨트롤러로 처리
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/shared/_tabbar.html.erb:8,13,17
  - app/javascript/controllers/tabbar_controller.js (신규)

### 6. 레이아웃 렌더링 실패 처리
- **현재 상태**:
  - 헤더/탭바 렌더링 실패 시 에러 처리 없음
  - current_user가 nil일 경우 대응 부족
- **개선 필요 사항**:
  - logged_in? 헬퍼 메서드 방어적 코딩
  - partial 렌더링 실패 시 fallback UI
  - rescue_from으로 전역 에러 핸들러
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/layouts/application.html.erb:29,45
  - app/helpers/application_helper.rb
  - app/controllers/application_controller.rb
