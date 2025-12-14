# Temporary Implementations - Phase 9.1 레이아웃

## 요약
- 총 항목 수: 6개
- P0 (즉시): 0개
- P1 (다음 스프린트): 3개
- P2 (백로그): 3개

## 항목 목록

### 1. Flash 메시지 자동 사라짐 기능
- **현재 상태**: Flash 메시지가 수동으로 새로고침하기 전까지 계속 표시됨
- **개선 필요 사항**:
  - Stimulus 컨트롤러로 3-5초 후 자동 사라짐 구현
  - 닫기 버튼 추가
  - Fade-out 애니메이션 적용
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**: app/views/layouts/application.html.erb:30-40

### 2. current_page_tab? 헬퍼 리팩토링
- **현재 상태**:
  - 탭 판단 로직과 CSS 클래스 반환이 하나의 메서드에 혼합됨
  - 각 탭마다 false를 반환하는 주석 처리된 코드
- **개선 필요 사항**:
  - 탭 활성 여부 판단과 CSS 클래스 반환을 분리
  - active_tab_class?(tab_name) 별도 메서드 생성
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**: app/helpers/application_helper.rb:11-26

### 3. 이모지 아이콘을 SVG/폰트 아이콘으로 교체
- **현재 상태**: 모든 아이콘이 이모지로 구현됨
- **개선 필요 사항**:
  - Heroicons 또는 Lucide Icons 도입
  - 일관된 크기와 스타일 적용
  - 접근성 개선 (aria-label 추가)
- **우선순위**: P1 (다음 스프린트)
- **관련 파일**:
  - app/views/shared/_header.html.erb:5
  - app/views/shared/_tabbar.html.erb
  - app/views/home/index.html.erb

### 4. 헤더 Safe Area 적용
- **현재 상태**: 헤더에 Safe Area 미적용
- **개선 필요 사항**:
  - iPhone X 이상 노치 영역 고려
  - safe-area-inset-top 적용
  - 좌우 Safe Area도 고려
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/shared/_header.html.erb:1-2
  - app/assets/tailwind/application.css

### 5. 반응형 레이아웃 개선
- **현재 상태**: 모바일 중심 고정 레이아웃만 존재
- **개선 필요 사항**:
  - 태블릿: 사이드바 탭 네비게이션
  - 데스크톱: 2-3 컬럼 레이아웃
  - 컨테이너 max-width 조정
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/layouts/application.html.erb
  - app/views/home/index.html.erb

### 6. Turbo Frame 활용 개선
- **현재 상태**: 전체 페이지 새로고침 방식
- **개선 필요 사항**:
  - Flash 메시지를 Turbo Stream으로 표시
  - 탭바 클릭 시 메인 영역만 교체 (Turbo Frame)
  - 로딩 상태 표시
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/layouts/application.html.erb:29-43
  - app/views/shared/_tabbar.html.erb
