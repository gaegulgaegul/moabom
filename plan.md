# Wave 3: Phase 8 - 에러 페이지

> 선행 조건: Wave 1 완료 (heroicon만 필요)
> 병렬 실행: 8.1 ∥ 8.2 (내부 병렬), Phase 3, 4, 5, 6, 7과도 병렬 가능

---

## 8.1 404 페이지 (병렬 가능)

### 파일: `app/views/errors/not_found.html.erb`

### 작업 내용
- [x] **RED**: 404 페이지 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: 404 페이지 구현 ✅ 2025-12-17
- [x] **REFACTOR**: 에러 페이지 공통 레이아웃 partial ✅ 2025-12-17

### 완료 기준
- 중앙 정렬 레이아웃
- magnifying-glass 아이콘
- btn-primary 홈 버튼

---

## 8.2 500 페이지 (병렬 가능)

### 파일: `app/views/errors/internal_server_error.html.erb` (신규 생성)

### 작업 내용
- [x] **RED**: 500 페이지 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: 500 페이지 구현 ✅ 2025-12-17
- [x] **REFACTOR**: 에러 페이지 partial 통합 ✅ 2025-12-17

### 추가 작업
- [x] `config/routes.rb`에 에러 라우트 추가 ✅ 2025-12-17
- [x] `app/controllers/errors_controller.rb`에 `internal_server_error` 액션 추가 ✅ 2025-12-17

### 완료 기준
- 빨간색 원형 아이콘 배경
- exclamation-triangle 아이콘
- 에러 메시지

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 8. 에러 페이지
