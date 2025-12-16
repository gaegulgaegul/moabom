# Phase 9.1: 레이아웃 구현 완료

> 작성일: 2025-12-15
> 상태: 구현 완료

## 구현 내용

### 1. 헤더 컴포넌트
- **파일**: `app/views/shared/_header.html.erb`
- **기능**:
  - 앱 로고 (🌸 모아봄)
  - 로그인 상태에 따른 분기
    - 비로그인: "로그인" 링크
    - 로그인: "로그아웃" 버튼
  - 고정 위치 (fixed top)

### 2. 하단 탭바 컴포넌트
- **파일**: `app/views/shared/_tabbar.html.erb`
- **탭 구성**:
  1. 홈 (🏠) - `/`
  2. 앨범 (📅) - Phase 5에서 구현 예정
  3. 추가 (⊕) - Phase 4에서 구현 예정
  4. 알림 (🔔) - Phase 6에서 구현 예정
  5. 설정 (⚙️) - `/settings/profile`
- **기능**:
  - 현재 페이지 하이라이트 (핑크색)
  - 고정 위치 (fixed bottom)
  - Safe Area Inset 지원 (iOS)

### 3. 레이아웃 개선
- **파일**: `app/views/layouts/application.html.erb`
- **변경사항**:
  - viewport 메타태그에 `viewport-fit=cover` 추가
  - 헤더 렌더링 (모든 페이지)
  - 탭바 렌더링 (로그인 시에만)
  - Flash 메시지 표시 (notice, alert)
  - 컨텐츠 영역 패딩 조정:
    - 로그인 전: `pt-14` (헤더 높이만)
    - 로그인 후: `pt-14 pb-16` (헤더 + 탭바)

### 4. 헬퍼 메서드
- **파일**: `app/helpers/application_helper.rb`
- **메서드**: `current_page_tab?(tab_name)`
  - 현재 페이지가 어느 탭에 속하는지 확인
  - 해당 탭에 핑크색 하이라이트 적용

### 5. 스타일링
- **파일**: `app/assets/tailwind/application.css`
- **추가**:
  - Safe Area Inset CSS 클래스
  - iOS 노치/홈바 대응

### 6. 홈 페이지 개선
- **파일**: `app/views/home/index.html.erb`
- **기능**:
  - 비로그인 사용자: 로그인 버튼 (Apple, 카카오, Google)
  - 로그인 사용자: 환영 메시지 + 빠른 액세스 카드

### 7. 테스트
- **파일**: `test/system/layout_test.rb`
- **테스트 케이스**:
  1. 비로그인 사용자 헤더만 표시
  2. 로그인 사용자 헤더+탭바 표시
  3. 탭바 현재 페이지 하이라이트
  4. Flash 메시지 표시

## 테스트 방법

### 1. 개발 서버 시작
```bash
bin/dev
```

### 2. 브라우저에서 확인
- http://localhost:3000

### 3. 확인 사항
- [ ] 헤더가 모든 페이지 상단에 고정
- [ ] 비로그인 시 "로그인" 링크 표시
- [ ] 로그인 후 "로그아웃" 버튼 표시
- [ ] 로그인 후 하단 탭바 표시
- [ ] 홈 탭 핑크색 하이라이트
- [ ] 설정 탭 클릭 시 이동 및 하이라이트
- [ ] 모바일 반응형 (375px ~ 768px)

### 4. 시스템 테스트 실행
```bash
rails test:system
```

## 디자인 가이드라인

### 색상
- 브랜드 핑크: `text-pink-500` (#EC4899)
- 회색: `text-gray-600`, `text-gray-900`
- 배경: `bg-white`, `bg-gray-50`

### 간격
- 헤더 높이: `h-14` (56px)
- 탭바 높이: `h-16` (64px)
- 패딩: `px-4`, `py-2`

### 반응형
- 모바일 퍼스트 디자인
- 최소 너비: 375px (iPhone SE)
- 최대 너비: 768px (iPad)

## 다음 단계

### Phase 9.2: 온보딩 플로우
- [ ] 프로필 설정 화면
- [ ] 아이 등록 화면
- [ ] 가족 초대 화면

### 개선 사항
- [ ] 탭바 아이콘을 SVG로 교체 (Heroicons)
- [ ] 탭 전환 애니메이션
- [ ] 읽지 않은 알림 뱃지
- [ ] 다크 모드 지원

## 파일 목록

```
app/
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   ├── shared/
│   │   ├── _header.html.erb
│   │   └── _tabbar.html.erb
│   └── home/
│       └── index.html.erb
├── helpers/
│   └── application_helper.rb
└── assets/
    └── tailwind/
        └── application.css

test/
└── system/
    └── layout_test.rb

docs/
└── implementation/
    └── phase-9.1-layout.md
```

## 참고 문서
- [WIREFRAME.md](/docs/features/mvp/WIREFRAME.md) - 화면 설계
- [ARCHITECTURE.md](/docs/features/mvp/ARCHITECTURE.md) - 아키텍처
- [Architecture Guide](/docs/guides/ARCHITECTURE_GUIDE.md) - 아키텍처 가이드
- [Coding Guide](/docs/guides/CODING_GUIDE.md) - 코딩 가이드
