# Intentional Simplifications - Phase 9.1 레이아웃

## 요약
- 총 항목 수: 5개
- P0 (즉시): 0개
- P1 (다음 스프린트): 0개
- P2 (백로그): 5개

## 항목 목록

### 1. PWA Manifest 비활성화
- **현재 상태**: application.html.erb에서 PWA manifest 주석 처리됨
- **개선 필요 사항**: MVP 단계에서는 웹 설치 기능 제외, 향후 PWA 기능 추가 시 활성화
- **우선순위**: P2 (백로그)
- **관련 파일**: app/views/layouts/application.html.erb:15

### 2. 이모지 아이콘 사용
- **현재 상태**:
  - 헤더 로고: 🌸 이모지 사용
  - 탭바 아이콘: 🏠📅⊕🔔⚙️ 이모지 사용
  - 로그인 버튼: 🍎💬📧 이모지 사용
- **개선 필요 사항**: MVP에서는 간단한 이모지 사용, 향후 SVG 아이콘 시스템으로 교체 예정
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/shared/_header.html.erb:5
  - app/views/shared/_tabbar.html.erb:4,9,14,18,23
  - app/views/home/index.html.erb:14,18,22

### 3. 기본 반응형 디자인
- **현재 상태**:
  - max-w-md, max-w-2xl 등 기본 컨테이너만 사용
  - grid-cols-2로 간단한 그리드만 구성
  - 태블릿/데스크톱 최적화 없음
- **개선 필요 사항**: MVP는 모바일 우선, 향후 태블릿/데스크톱 레이아웃 개선
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/views/home/index.html.erb:8,32,38

### 4. 단순한 Flash 메시지
- **현재 상태**:
  - 기본 Tailwind 스타일만 적용
  - 자동 사라짐 기능 없음
  - 닫기 버튼 없음
- **개선 필요 사항**: MVP는 기본 표시만, 향후 Stimulus로 인터랙션 개선
- **우선순위**: P2 (백로그)
- **관련 파일**: app/views/layouts/application.html.erb:30-40

### 5. 기본 Safe Area 지원만 구현
- **현재 상태**:
  - 하단 탭바에만 safe-area-inset-bottom 적용
  - 상단 헤더는 Safe Area 미적용
  - 좌우 Safe Area 미고려
- **개선 필요 사항**: MVP는 기본 지원만, 향후 전체 Safe Area 최적화
- **우선순위**: P2 (백로그)
- **관련 파일**:
  - app/assets/tailwind/application.css:3-6
  - app/views/shared/_tabbar.html.erb:1
