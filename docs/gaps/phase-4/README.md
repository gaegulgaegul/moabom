# 구현 현황 분석 (Implementation Gaps)

> 분석일: 2025-12-14
> 분석 시점: Phase 4 완료 (126 tests passing)

---

## 개요

MVP 개발 과정에서 의도적으로 단순화하거나 임시로 구현한 항목들을 추적합니다.
이 문서는 기술 부채 관리 및 향후 개선 계획 수립에 활용됩니다.

---

## 문서 구조

| 파일 | 설명 |
|-----|------|
| [intentional-simplifications.md](./intentional-simplifications.md) | MVP 범위로 축소한 기능 |
| [temporary-implementations.md](./temporary-implementations.md) | 나중에 개선이 필요한 코드 |
| [not-implemented.md](./not-implemented.md) | 건너뛴 기능이나 테스트 |
| [hardcoded-values.md](./hardcoded-values.md) | 설정값이나 상수로 분리해야 할 부분 |
| [missing-error-handling.md](./missing-error-handling.md) | 예외 상황 처리가 부족한 부분 |

---

## 요약 대시보드

### 우선순위별 현황

| 카테고리 | P0 (즉시) | P1 (다음 스프린트) | P2 (백로그) | 합계 |
|---------|----------|-----------------|-----------|-----|
| 의도적 단순화 | 0 | 3 | 4 | 7 |
| 임시 구현 | 1 | 2 | 0 | 3 |
| 미구현 항목 | 2 | 5 | 2 | 9 |
| 하드코딩 | 0 | 1 | 4 | 5 |
| 에러 처리 | 2 | 2 | 1 | 5 |
| **합계** | **5** | **13** | **11** | **29** |

### 우선순위 정의

- **P0 (즉시)**: 보안 이슈, 데이터 손실 위험, 핵심 기능 차단
- **P1 (다음 스프린트)**: MVP 출시 전 필수, 사용자 경험 영향
- **P2 (백로그)**: 출시 후 개선, 기술 부채

---

## P0 즉시 조치 항목

### 1. 글로벌 에러 핸들러 추가
- **파일**: `app/controllers/application_controller.rb`
- **현재**: `rescue_from` 블록 없음
- **위험**: 사용자에게 Rails 기본 에러 페이지 노출

### 2. Photo 파일 크기 제한
- **파일**: `app/models/photo.rb`
- **현재**: 파일 크기 검증 없음
- **위험**: 서버 스토리지 고갈, DoS 공격 가능성

### 3. 초대 링크 재사용 로직
- **파일**: `app/controllers/onboarding/invites_controller.rb:9`
- **현재**: 페이지 방문마다 새 초대 생성
- **위험**: 불필요한 데이터 누적, 성능 저하

### 4. 사진 컨트롤러 구현
- **상태**: Phase 5 대상
- **위험**: MVP 핵심 기능 미구현

### 5. Photo Controller Tests
- **상태**: 컨트롤러 없어서 테스트 불가
- **조치**: Phase 5와 함께 TDD로 구현

---

## Phase별 해결 계획

| Phase | 해결 항목 | 예상 테스트 추가 |
|-------|---------|---------------|
| Phase 5 | P0 #4, #5 + Photo 관련 | +30~40 tests |
| Phase 6 | Reaction, Comment 컨트롤러 | +20 tests |
| Phase 7 | Settings 컨트롤러 | +10 tests |
| 별도 Sprint | P0 #1, #2, #3 (에러/보안) | +10 tests |

---

## 변경 이력

| 날짜 | 변경 내용 |
|-----|----------|
| 2025-12-14 | 최초 작성 (Phase 4 완료 시점) |
