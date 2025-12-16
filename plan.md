# 모아봄 디자인 적용 계획

> DESIGN_GUIDE.md와 PAGE_LAYOUTS.md 기반 UI/UX 디자인 적용
> 생성일: 2025-12-16

---

## 현황 분석

### 현재 상태
- TailwindCSS 커스텀 테마 설정 완료 (application.css)
- 기본 컴포넌트 클래스 정의됨 (btn-primary, card-glass, input-text 등)
- 뷰 파일들은 기본 Tailwind 클래스만 사용 중 (디자인 시스템 미적용)
- heroicon gem 미사용 (이모지로 대체 중)

### 적용 필요 항목
- 커스텀 색상 체계 (primary, cream, warm-gray) 적용
- Glassmorphism 효과 적용
- Heroicons 통합
- PAGE_LAYOUTS.md의 레이아웃 구조 적용
- 다크 모드 지원 준비

---

## 작업 계획

### Phase 1: 기반 설정 (Infrastructure)

#### 1.1 Heroicons gem 설치 및 설정
- [ ] **RED**: heroicon helper 사용 테스트 작성
- [ ] **GREEN**: Gemfile에 heroicon gem 추가 및 설치
- [ ] **REFACTOR**: 필요시 설정 조정

#### 1.2 TailwindCSS 보완
- [ ] **RED**: 누락된 컴포넌트 클래스 테스트
- [ ] **GREEN**: application.css에 추가 유틸리티 클래스 정의
  - tab-item, tab-item-active 클래스
  - bg-gradient-warm 그라디언트 확인
  - 다크 모드 변수 준비
- [ ] **REFACTOR**: 클래스 정리 및 최적화

---

### Phase 2: 공통 레이아웃 (Shared Components)

#### 2.1 application.html.erb 레이아웃 개선
- [ ] **RED**: 레이아웃 구조 테스트 (시스템 테스트)
- [ ] **GREEN**:
  - body에 bg-cream-50 적용
  - main 영역 pt-14 pb-20 적용
  - flash 메시지 디자인 시스템 적용 (alert-success, alert-error)
- [ ] **REFACTOR**: 중복 코드 제거

#### 2.2 Header (_header.html.erb) 재디자인
- [ ] **RED**: 헤더 렌더링 테스트
- [ ] **GREEN**:
  - glass 효과 적용 (bg-white/80 backdrop-blur-md)
  - safe-area-inset-top 적용
  - heroicon 적용 (bell 아이콘)
  - 알림 뱃지 추가
- [ ] **REFACTOR**: 접근성 개선 (aria-label)

#### 2.3 Tab Bar (_tabbar.html.erb) 재디자인
- [ ] **RED**: 탭바 렌더링 및 활성 상태 테스트
- [ ] **GREEN**:
  - glass 효과 적용 (bg-white/90 backdrop-blur-md)
  - safe-area-inset-bottom 적용
  - heroicon 적용 (home, photo, plus, bell, cog-6-tooth)
  - 중앙 FAB 버튼 (업로드) 스타일링
  - 활성 탭 상태 표시 (text-primary-500)
- [ ] **REFACTOR**: tab-item 클래스로 통합

---

### Phase 3: 로그인/온보딩 화면

#### 3.1 홈 화면 - 비로그인 상태 (home/index.html.erb)
- [ ] **RED**: 로그인 페이지 UI 테스트
- [ ] **GREEN**:
  - bg-gradient-warm 배경 적용
  - 로고/일러스트 영역 추가
  - 소셜 로그인 버튼 재디자인
    - Apple: 검정 배경 rounded-2xl
    - 카카오: 노란색 배경 (#FEE500)
    - Google: card-glass 스타일
  - 약관 링크 스타일링
- [ ] **REFACTOR**: 버튼 공통 스타일 추출

#### 3.2 온보딩 - 프로필 설정 (onboarding/profiles/show.html.erb)
- [ ] **RED**: 프로필 폼 UI 테스트
- [ ] **GREEN**:
  - 진행률 표시 (1/3 ●○○)
  - 아이콘 원형 배경 (primary-100)
  - 타이틀/설명 텍스트 스타일링
  - input-text 클래스 적용
  - btn-primary 버튼
- [ ] **REFACTOR**: 온보딩 공통 레이아웃 partial 추출

#### 3.3 온보딩 - 아이 등록 (onboarding/children/show.html.erb)
- [ ] **RED**: 아이 등록 폼 UI 테스트
- [ ] **GREEN**:
  - 진행률 표시 (2/3 ○●○)
  - secondary 색상 아이콘
  - 성별 선택 버튼 그룹 (토글 스타일)
  - 날짜 입력 스타일링
  - "나중에 할게요" 텍스트 링크
- [ ] **REFACTOR**: 버튼 그룹 컴포넌트화

#### 3.4 온보딩 - 가족 초대 (onboarding/invites/show.html.erb)
- [ ] **RED**: 초대 페이지 UI 테스트
- [ ] **GREEN**:
  - 진행률 표시 (3/3 ○○●)
  - accent 색상 아이콘
  - 초대 링크 card-glass 카드
  - 공유 버튼들 (카카오톡, 링크 복사)
  - "시작하기" btn-primary
- [ ] **REFACTOR**: 공유 버튼 partial 추출

---

### Phase 4: 대시보드/홈 (로그인 상태)

#### 4.1 대시보드 (dashboard/index.html.erb 또는 home/index.html.erb 로그인 상태)
- [ ] **RED**: 대시보드 UI 테스트
- [ ] **GREEN**:
  - 인사 메시지 섹션
  - 아이 D+일 카드 (card-glass)
  - 최근 사진 가로 스크롤 섹션
  - 빠른 메뉴 Bento Grid (card-flat)
    - 사진 업로드, 가족 관리, 앨범 보기, 아이 프로필
  - heroicon 적용
- [ ] **REFACTOR**: 섹션별 partial 분리

---

### Phase 5: 사진 기능

#### 5.1 사진 타임라인 (families/photos/index.html.erb)
- [ ] **RED**: 타임라인 UI 테스트
- [ ] **GREEN**:
  - 필터 탭 (전체, 아이별) - pill 스타일
  - 월별 그룹 헤더
  - 3열 사진 그리드 (gap-1, rounded-lg)
  - 빈 상태 디자인 (empty-state)
- [ ] **REFACTOR**: 사진 그리드 partial 추출

#### 5.2 사진 상세 (families/photos/show.html.erb)
- [ ] **RED**: 사진 상세 UI 테스트
- [ ] **GREEN**:
  - 투명 헤더 (bg-black/30 backdrop-blur-sm)
  - 전체 너비 이미지
  - 정보 영역 (rounded-t-3xl 흰색 카드)
  - 반응 버튼 (heart, comment)
  - 댓글 영역
  - 고정 댓글 입력창
- [ ] **REFACTOR**: 반응/댓글 컴포넌트 분리

#### 5.3 사진 업로드 (families/photos/new.html.erb, _form.html.erb)
- [ ] **RED**: 업로드 폼 UI 테스트
- [ ] **GREEN**:
  - 취소/완료 헤더
  - 이미지 미리보기 영역
  - 추가 선택 썸네일 스크롤
  - 캡션 input-textarea
  - 아이 태그 pill 버튼
  - 촬영일 날짜 입력
- [ ] **REFACTOR**: 파일 업로드 Stimulus 컨트롤러

---

### Phase 6: 가족 관리

#### 6.1 가족 구성원 목록 (families/members/index.html.erb)
- [ ] **RED**: 구성원 목록 UI 테스트
- [ ] **GREEN**:
  - 페이지 타이틀
  - 구성원 카드 (card-solid, divide-y)
  - 아바타 + 닉네임 + 역할 뱃지
  - 관리 액션 (역할 변경, 내보내기)
  - "가족 초대하기" btn-outline
- [ ] **REFACTOR**: 구성원 카드 partial

#### 6.2 아이 목록 (families/children/index.html.erb)
- [ ] **RED**: 아이 목록 UI 테스트
- [ ] **GREEN**:
  - 페이지 타이틀
  - 아이 카드 (card-glass)
    - 프로필 사진 영역
    - 이름, D+일, 사진 수
  - "아이 추가하기" btn-outline
- [ ] **REFACTOR**: 아이 카드 partial

---

### Phase 7: 설정

#### 7.1 설정 메인 (settings/profiles/show.html.erb)
- [ ] **RED**: 설정 페이지 UI 테스트
- [ ] **GREEN**:
  - 페이지 타이틀
  - 설정 그룹 카드 (card-solid, divide-y)
    - 프로필 설정, 알림 설정, 다크 모드 토글
  - 정보 그룹 (이용약관, 개인정보, 앱 정보)
  - 로그아웃 버튼 (text-red-500)
  - heroicon 적용
- [ ] **REFACTOR**: 설정 아이템 partial

#### 7.2 알림 설정 (settings/notifications/show.html.erb)
- [ ] **RED**: 알림 설정 UI 테스트
- [ ] **GREEN**:
  - 토글 스위치 스타일링
  - 설정 항목 리스트
- [ ] **REFACTOR**: 토글 컴포넌트 추출

---

### Phase 8: 에러 페이지

#### 8.1 404 페이지 (errors/not_found.html.erb)
- [ ] **RED**: 404 페이지 UI 테스트
- [ ] **GREEN**:
  - 중앙 정렬 레이아웃
  - 아이콘 (magnifying-glass)
  - 타이틀/설명 텍스트
  - btn-primary 홈 버튼
- [ ] **REFACTOR**: 에러 페이지 공통 레이아웃

#### 8.2 500 페이지 (errors/internal_server_error.html.erb 생성)
- [ ] **RED**: 500 페이지 UI 테스트
- [ ] **GREEN**:
  - 빨간색 원형 아이콘 배경
  - exclamation-triangle 아이콘
  - 에러 메시지
- [ ] **REFACTOR**: 에러 페이지 partial 통합

---

### Phase 9: 마무리 및 최적화

#### 9.1 반응형 테스트
- [ ] 모바일 (< 640px) 레이아웃 확인
- [ ] 태블릿 (768px) 레이아웃 확인
- [ ] 데스크톱 (1024px+) 레이아웃 확인

#### 9.2 접근성 검토
- [ ] 색상 대비 4.5:1 확인
- [ ] 터치 타겟 48px 확인
- [ ] ARIA 라벨 적용 확인
- [ ] 키보드 네비게이션 테스트

#### 9.3 성능 최적화
- [ ] 이미지 lazy loading 확인
- [ ] CSS 번들 사이즈 확인
- [ ] 불필요한 클래스 제거

---

## 우선순위 정리

### 높음 (MVP 필수)
1. Phase 1: 기반 설정
2. Phase 2: 공통 레이아웃
3. Phase 3: 로그인/온보딩
4. Phase 5: 사진 기능

### 중간 (사용성 개선)
5. Phase 4: 대시보드
6. Phase 6: 가족 관리
7. Phase 7: 설정

### 낮음 (품질 향상)
8. Phase 8: 에러 페이지
9. Phase 9: 마무리

---

## 참고 문서
- [DESIGN_GUIDE.md](docs/references/DESIGN_GUIDE.md) - 디자인 시스템
- [PAGE_LAYOUTS.md](docs/references/PAGE_LAYOUTS.md) - 페이지 레이아웃
- [design-system.md](.claude/rules/design-system.md) - 상세 디자인 가이드
