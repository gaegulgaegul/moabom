# 모아봄 MVP 개발 계획

> TDD 기반 개발 계획서
> 작성일: 2025-12-14
> 상태: 진행 중

---

## Phase 1: 기본 모델 및 데이터베이스

### 1.1 User 모델

- [x] **RED**: User 모델 기본 테스트 ✅
  - [x] 유효한 속성으로 생성 가능
  - [x] email 필수 검증
  - [x] nickname 필수 검증
  - [x] provider, uid 조합 유일성 검증
- [x] **GREEN**: User 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 1.2 Family 모델

- [x] **RED**: Family 모델 기본 테스트 ✅
  - [x] 유효한 속성으로 생성 가능
  - [x] name 필수 검증
  - [x] User와 다대다 관계 (FamilyMembership 통해)
- [x] **GREEN**: Family 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 1.3 FamilyMembership 모델

- [x] **RED**: FamilyMembership 모델 기본 테스트 ✅
  - [x] User와 Family 연결
  - [x] role enum (owner, admin, member, viewer)
  - [x] User-Family 조합 유일성
- [x] **GREEN**: FamilyMembership 모델 구현 ✅ (Family와 함께 구현됨)
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음)

### 1.4 Child 모델

- [x] **RED**: Child 모델 기본 테스트 ✅
  - [x] Family에 속함
  - [x] name, birthdate 필수
  - [x] gender enum (male, female)
  - [x] 나이 계산 메서드
- [x] **GREEN**: Child 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 1.5 Photo 모델

- [x] **RED**: Photo 모델 기본 테스트 ✅
  - [x] Family에 속함
  - [x] uploader (User) 연관
  - [x] Child 연관 (선택)
  - [x] Active Storage 이미지 첨부
  - [x] taken_at 필수
  - [x] 스코프: recent, by_month
- [x] **GREEN**: Photo 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 1.6 Reaction 모델

- [x] **RED**: Reaction 모델 기본 테스트 ✅
  - [x] Photo에 속함
  - [x] User에 속함
  - [x] emoji 필수
  - [x] User-Photo 조합 유일성
- [x] **GREEN**: Reaction 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 1.7 Comment 모델

- [x] **RED**: Comment 모델 기본 테스트 ✅
  - [x] Photo에 속함
  - [x] User에 속함
  - [x] body 필수
- [x] **GREEN**: Comment 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 1.8 Invitation 모델

- [x] **RED**: Invitation 모델 기본 테스트 ✅
  - [x] Family에 속함
  - [x] inviter (User) 연관
  - [x] token 자동 생성
  - [x] expires_at 기본값 (7일)
  - [x] role 지정
- [x] **GREEN**: Invitation 모델 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 2: 인증 시스템

### 2.1 OAuth 기본 설정

- [x] **RED**: OAuth 콜백 처리 테스트 ✅
  - [x] 카카오 OAuth 콜백
  - [x] 신규 사용자 생성
  - [x] 기존 사용자 로그인
- [x] **GREEN**: OmniAuth 설정 및 OauthController 구현 ✅
  - [x] omniauth-oauth2 기반 커스텀 Kakao 전략 구현
  - [x] OauthCallbacksController 구현
  - [x] User.find_or_create_from_oauth 메서드 구현
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 2.2 세션 관리

- [x] **RED**: 세션 관리 테스트 ✅
  - [x] 로그인 세션 생성
  - [x] current_user 헬퍼
  - [x] 로그아웃
- [x] **GREEN**: SessionsController 구현 ✅
  - [x] SessionsController#create (테스트용 로그인)
  - [x] SessionsController#destroy (로그아웃)
  - [x] current_user, logged_in? 헬퍼 추가
- [x] **REFACTOR**: ApplicationController에 인증 헬퍼 추출 ✅ (이미 구현됨)

### 2.3 인증 필터

- [x] **RED**: 인증 필터 테스트 ✅
  - [x] 미인증 사용자 리다이렉트
  - [x] 인증 사용자 접근 허용
- [x] **GREEN**: before_action :authenticate_user! 구현 ✅
  - [x] authenticate_user! 메서드 추가
  - [x] DashboardController에 인증 필터 적용
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 3: 온보딩 플로우

### 3.1 프로필 설정

- [ ] **RED**: 프로필 설정 테스트
  - [ ] 프로필 폼 표시
  - [ ] 닉네임, 아바타 저장
  - [ ] 다음 단계로 리다이렉트
- [ ] **GREEN**: Onboarding::ProfilesController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 3.2 아이 등록

- [ ] **RED**: 아이 등록 테스트
  - [ ] 아이 등록 폼 표시
  - [ ] 아이 정보 저장
  - [ ] Family 자동 생성
- [ ] **GREEN**: Onboarding::ChildrenController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 3.3 가족 초대

- [ ] **RED**: 가족 초대 테스트
  - [ ] 초대 링크 생성
  - [ ] 링크 표시
- [ ] **GREEN**: Onboarding::InvitesController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

---

## Phase 4: 가족 관리

### 4.1 가족 정보

- [ ] **RED**: 가족 정보 테스트
  - [ ] 가족 정보 조회
  - [ ] 가족 이름 수정
- [ ] **GREEN**: FamiliesController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 4.2 구성원 관리

- [ ] **RED**: 구성원 관리 테스트
  - [ ] 구성원 목록 조회
  - [ ] 역할 변경 (owner/admin만)
  - [ ] 구성원 내보내기
- [ ] **GREEN**: Families::MembersController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 4.3 초대 시스템

- [ ] **RED**: 초대 시스템 테스트
  - [ ] 초대 링크 생성
  - [ ] 초대 수락 (로그인 상태)
  - [ ] 초대 수락 (비로그인 → 로그인 후 수락)
  - [ ] 만료된 초대 처리
- [ ] **GREEN**: InvitationsController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 4.4 아이 관리

- [ ] **RED**: 아이 관리 테스트
  - [ ] 아이 목록 조회
  - [ ] 아이 추가
  - [ ] 아이 정보 수정
  - [ ] 아이 삭제
- [ ] **GREEN**: Families::ChildrenController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

---

## Phase 5: 사진 기능 (MVP 핵심)

### 5.1 사진 타임라인

- [ ] **RED**: 타임라인 테스트
  - [ ] 가족 사진 목록 조회
  - [ ] 날짜별 그룹핑
  - [ ] 무한 스크롤 (페이지네이션)
  - [ ] 아이별 필터링
- [ ] **GREEN**: Families::PhotosController#index 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 5.2 사진 업로드

- [ ] **RED**: 사진 업로드 테스트
  - [ ] 단일 사진 업로드
  - [ ] Direct Upload URL 발급
  - [ ] 사진 메타데이터 저장
- [ ] **GREEN**: Families::PhotosController#create 구현
- [ ] **REFACTOR**: PhotoUploadService 추출

### 5.3 대량 업로드

- [ ] **RED**: 대량 업로드 테스트
  - [ ] 배치 API로 여러 사진 저장
  - [ ] 실패한 항목 응답
- [ ] **GREEN**: Families::PhotosController#batch 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 5.4 사진 상세

- [ ] **RED**: 사진 상세 테스트
  - [ ] 사진 상세 조회
  - [ ] 반응 목록
  - [ ] 댓글 목록
- [ ] **GREEN**: Families::PhotosController#show 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 5.5 사진 수정/삭제

- [ ] **RED**: 사진 수정/삭제 테스트
  - [ ] 캡션 수정
  - [ ] 아이 태그 변경
  - [ ] 사진 삭제 (업로더 또는 admin)
- [ ] **GREEN**: PhotosController#update, #destroy 구현
- [ ] **REFACTOR**: 필요시 코드 정리

---

## Phase 6: 반응 및 댓글

### 6.1 반응 기능

- [ ] **RED**: 반응 기능 테스트
  - [ ] 반응 추가
  - [ ] 반응 변경
  - [ ] 반응 삭제
  - [ ] Turbo Stream 응답
- [ ] **GREEN**: Photos::ReactionsController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 6.2 댓글 기능

- [ ] **RED**: 댓글 기능 테스트
  - [ ] 댓글 작성
  - [ ] 댓글 삭제 (작성자만)
  - [ ] Turbo Stream 응답
- [ ] **GREEN**: Photos::CommentsController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

---

## Phase 7: 설정 및 프로필

### 7.1 사용자 프로필

- [ ] **RED**: 프로필 설정 테스트
  - [ ] 프로필 조회
  - [ ] 닉네임 수정
  - [ ] 아바타 변경
- [ ] **GREEN**: Settings::ProfilesController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 7.2 알림 설정

- [ ] **RED**: 알림 설정 테스트
  - [ ] 알림 설정 조회
  - [ ] 알림 설정 변경
- [ ] **GREEN**: Settings::NotificationsController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

---

## Phase 8: Native 브릿지 API

### 8.1 동기화 API

- [ ] **RED**: 동기화 API 테스트
  - [ ] 앱 시작 시 필요 정보 일괄 조회
  - [ ] JSON 응답 형식 확인
- [ ] **GREEN**: Api::Native::SyncController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 8.2 푸시 토큰 등록

- [ ] **RED**: 푸시 토큰 테스트
  - [ ] 기기 토큰 등록
  - [ ] 기기 토큰 업데이트
- [ ] **GREEN**: Api::Native::PushTokensController 구현
- [ ] **REFACTOR**: 필요시 코드 정리

---

## Phase 9: UI/UX 마무리

### 9.1 레이아웃

- [ ] **RED**: 레이아웃 테스트
  - [ ] 메인 레이아웃 렌더링
  - [ ] 하단 탭바 표시
  - [ ] 인증 상태별 분기
- [ ] **GREEN**: 레이아웃 뷰 구현
- [ ] **REFACTOR**: 공통 partial 추출

### 9.2 빈 상태 및 에러

- [ ] **RED**: 상태 화면 테스트
  - [ ] 사진 없음 상태
  - [ ] 404 페이지
  - [ ] 500 페이지
- [ ] **GREEN**: 상태 화면 구현
- [ ] **REFACTOR**: 필요시 코드 정리

### 9.3 반응형 디자인

- [ ] **RED**: 반응형 테스트
  - [ ] 모바일 레이아웃
  - [ ] 태블릿 레이아웃
- [ ] **GREEN**: TailwindCSS 반응형 적용
- [ ] **REFACTOR**: 필요시 코드 정리

---

## 진행 현황

| Phase | 상태 | 완료일 |
|-------|------|-------|
| Phase 1: 기본 모델 | ✅ 완료 | 2025-12-14 |
| Phase 2: 인증 시스템 | ✅ 완료 | 2025-12-14 |
| Phase 3: 온보딩 | ⏳ 대기 | - |
| Phase 4: 가족 관리 | ⏳ 대기 | - |
| Phase 5: 사진 기능 | ⏳ 대기 | - |
| Phase 6: 반응/댓글 | ⏳ 대기 | - |
| Phase 7: 설정 | ⏳ 대기 | - |
| Phase 8: Native API | ⏳ 대기 | - |
| Phase 9: UI/UX | ⏳ 대기 | - |

---

## 참고 문서

- [PRD](/docs/PRD.md)
- [아키텍처](/docs/ARCHITECTURE.md)
- [API 설계](/docs/API_DESIGN.md)
- [화면 설계](/docs/WIREFRAME.md)
