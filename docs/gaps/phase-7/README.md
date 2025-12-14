# Phase 7 설정 기능 - Gap Analysis

> Phase 7 설정 기능의 구현 격차 분석 문서
> 생성일: 2025-12-15

## 개요

Phase 7 설정 기능(프로필 설정, 알림 설정)의 현재 구현 상태를 분석하고, 개선이 필요한 영역을 카테고리별로 문서화했습니다.

## 분석 대상

- **Controllers**: `settings/profiles_controller.rb`, `settings/notifications_controller.rb`
- **Views**: `settings/profiles/show.html.erb`, `settings/notifications/show.html.erb`
- **Models**: `user.rb`
- **Tests**: `settings/profiles_controller_test.rb`, `settings/notifications_controller_test.rb`
- **Migrations**: `add_notification_settings_to_users.rb`

## 문서 구조

### 1. [Intentional Simplifications](./intentional-simplifications.md)
MVP 범위로 의도적으로 축소한 기능들

- **총 6개 항목** (P1: 3개, P2: 3개)
- 주요 항목:
  - 프로필 아바타 업로드 미구현
  - 푸시 알림 실제 전송 미구현
  - 계정 탈퇴 기능 미구현

### 2. [Temporary Implementations](./temporary-implementations.md)
추후 개선이 필요한 임시 구현

- **총 5개 항목** (P0: 1개, P1: 3개, P2: 1개)
- 주요 항목:
  - UI/UX가 매우 기본적 (TailwindCSS 미적용) **[P0]**
  - 간단한 Boolean 필드로만 알림 설정 관리
  - Turbo Frame/Stream 미적용

### 3. [Not Implemented](./not-implemented.md)
계획했으나 구현하지 못한 기능

- **총 8개 항목** (P0: 2개, P1: 4개, P2: 2개)
- 주요 항목:
  - 닉네임 길이 및 형식 검증 **[P0]**
  - 닉네임 중복 체크
  - 알림 그룹화 설정

### 4. [Hardcoded Values](./hardcoded-values.md)
설정값이나 상수로 분리해야 할 하드코딩

- **총 4개 항목** (P0: 2개, P1: 2개)
- 주요 항목:
  - 성공/에러 메시지 하드코딩 **[P0]**
  - 뷰 레이블 텍스트 하드코딩 **[P0]**

### 5. [Missing Error Handling](./missing-error-handling.md)
예외 상황 처리가 부족한 부분

- **총 7개 항목** (P0: 3개, P1: 3개, P2: 1개)
- 주요 항목:
  - 닉네임 유효성 검증 부족 **[P0]**
  - 파일 업로드 검증 부족 **[P0]**
  - 에러 응답 형식 불일치 **[P0]**

## 우선순위 요약

| 우선순위 | 총 개수 | 카테고리별 분포 |
|---------|--------|----------------|
| **P0** (즉시) | **11개** | Temporary(1), Not Implemented(2), Hardcoded(2), Error Handling(3) |
| **P1** (다음 스프린트) | **13개** | Intentional(3), Temporary(3), Not Implemented(4), Hardcoded(2), Error Handling(3) |
| **P2** (백로그) | **6개** | Intentional(3), Temporary(1), Not Implemented(2), Error Handling(1) |

## 즉시 해결해야 할 항목 (P0)

1. **UI/UX 개선** - TailwindCSS 적용, 반응형 디자인
2. **닉네임 검증 강화** - 길이, 형식, 특수문자 검증
3. **i18n 적용** - 하드코딩된 메시지 및 레이블 분리
4. **에러 처리 개선** - JSON API 에러 형식, 유효성 검증
5. **파일 업로드 검증** - 아바타 업로드 구현 시 필수

## 다음 스프린트 목표 (P1)

1. **푸시 알림 연동** - FCM/APNs 실제 전송 기능
2. **계정 탈퇴** - 사용자 데이터 처리 정책 포함
3. **Turbo 적용** - Frame/Stream으로 부분 업데이트
4. **알림 설정 고도화** - JSON 기반 세밀한 제어
5. **동시 수정 충돌 처리** - Optimistic locking

## 분석 기준

### 보안
- ✅ CSRF 보호 (Rails 기본)
- ✅ Strong Parameters
- ⚠️ 닉네임 유효성 검증 부족
- ⚠️ 파일 업로드 검증 없음 (아바타 미구현)

### 사용자 경험
- ⚠️ UI/UX 매우 기본적
- ❌ 반응형 디자인 없음
- ❌ 실시간 검증 피드백 없음
- ❌ 접근성 고려 부족

### 확장성
- ⚠️ 간단한 boolean 알림 설정 (세밀한 제어 불가)
- ❌ 가족별 알림 설정 미지원
- ❌ 알림 시간대 설정 없음

### 테스트
- ✅ 기본적인 컨트롤러 테스트 존재
- ❌ 엣지 케이스 테스트 부족
- ❌ 시스템 테스트 없음
- ❌ 알림 전송 테스트 없음

## 권장 사항

### 단기 (1-2주)
1. i18n 파일로 메시지 분리
2. TailwindCSS UI 적용
3. 닉네임 유효성 검증 강화
4. JSON API 에러 형식 표준화

### 중기 (1개월)
1. 푸시 알림 FCM/APNs 연동
2. 계정 탈퇴 기능 구현
3. Turbo Frame/Stream 적용
4. 알림 설정 JSON 구조화

### 장기 (2-3개월)
1. 가족별 알림 설정
2. 알림 시간대 설정
3. 설정 백업/복원 기능
4. 감사 로그 및 이력 관리

## 관련 문서

- [Phase 7 PRD](../../features/mvp/PRD.md#7-설정)
- [Architecture Guide](../../guides/ARCHITECTURE_GUIDE.md)
- [API Design](../../features/mvp/API_DESIGN.md#7-설정-api)
