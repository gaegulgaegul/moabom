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

- [x] **RED**: 프로필 설정 테스트 ✅
  - [x] 프로필 폼 표시
  - [x] 닉네임 저장
  - [x] 다음 단계로 리다이렉트
- [x] **GREEN**: Onboarding::ProfilesController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 3.2 아이 등록

- [x] **RED**: 아이 등록 테스트 ✅
  - [x] 아이 등록 폼 표시
  - [x] 아이 정보 저장
  - [x] Family 자동 생성
- [x] **GREEN**: Onboarding::ChildrenController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 3.3 가족 초대

- [x] **RED**: 가족 초대 테스트 ✅
  - [x] 초대 링크 생성
  - [x] 링크 표시
- [x] **GREEN**: Onboarding::InvitesController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 3.5: 온보딩 보완 (Phase 4 시작 전 필수)

> IMPLEMENTATION_GAPS.md 분석 결과 반영

### 3.5.1 온보딩 완료 추적

- [x] **RED**: 온보딩 완료 추적 테스트 ✅
  - [x] User 모델에 onboarding_completed_at 필드 존재
  - [x] 온보딩 완료 시 필드 업데이트
  - [x] 미완료 사용자 온보딩으로 리다이렉트
- [x] **GREEN**: 온보딩 완료 추적 구현 ✅
  - [x] 마이그레이션: users 테이블에 onboarding_completed_at 추가
  - [x] ApplicationController에 require_onboarding! 필터
  - [x] InvitationsController에서 온보딩 완료 처리 (Phase 3.5.2에서 구현)
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 3.5.2 초대 수락 컨트롤러

- [x] **RED**: 초대 수락 테스트 ✅
  - [x] 유효한 초대 토큰으로 페이지 접근
  - [x] 로그인 상태에서 초대 수락
  - [x] 비로그인 상태에서 초대 수락 (로그인 후 처리)
  - [x] 만료된 초대 처리
  - [x] 이미 가족 구성원인 경우 처리
- [x] **GREEN**: InvitationsController#show, #accept 구현 ✅
  - [x] 초대 정보 표시 페이지
  - [x] 초대 수락 처리 (FamilyMembership 생성)
  - [x] 세션에 pending_invitation 저장 (비로그인 시)
  - [x] 온보딩 완료 처리 (complete_onboarding!)
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 4: 가족 관리

### 4.1 가족 정보

- [x] **RED**: 가족 정보 테스트 ✅
  - [x] 가족 정보 조회
  - [x] 가족 이름 수정
  - [x] 권한 체크 (멤버만 조회, owner/admin만 수정)
- [x] **GREEN**: FamiliesController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 4.2 구성원 관리

- [x] **RED**: 구성원 관리 테스트 ✅
  - [x] 구성원 목록 조회
  - [x] 역할 변경 (owner/admin만)
  - [x] 구성원 내보내기
  - [x] 자신의 역할 변경/내보내기 방지
- [x] **GREEN**: Families::MembersController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 4.3 초대 시스템

> Phase 3.5.2에서 InvitationsController 구현 완료

- [x] **RED**: 초대 시스템 테스트 ✅ (Phase 3.5.2)
- [x] **GREEN**: InvitationsController 구현 ✅ (Phase 3.5.2)
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (Phase 3.5.2)

### 4.4 아이 관리

- [x] **RED**: 아이 관리 테스트 ✅
  - [x] 아이 목록 조회
  - [x] 아이 추가
  - [x] 아이 정보 수정
  - [x] 아이 삭제
  - [x] 권한 체크 (owner/admin만 수정/삭제)
- [x] **GREEN**: Families::ChildrenController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 4.5: 에러 처리 및 보안 강화 (P0 즉시)

> gap-scan Phase 4 분석 결과 - P0 항목 반영

### 4.5.1 글로벌 에러 핸들러

- [x] **RED**: 에러 핸들러 테스트 ✅
  - [x] RecordNotFound → 404 응답
  - [x] ParameterMissing → 400 응답
  - [x] InvalidAuthenticityToken → 적절한 처리
  - [x] HTML/JSON 응답 형식 분기
- [x] **GREEN**: ApplicationController에 rescue_from 구현 ✅
  - [x] rescue_from 블록 추가
  - [x] 에러 페이지 뷰 생성 (errors/not_found, errors/bad_request)
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 4.5.2 Photo 파일 검증

- [x] **RED**: 파일 검증 테스트 ✅
  - [x] 파일 크기 50MB 초과 시 거부
  - [x] 허용되지 않은 파일 타입 거부
  - [x] 허용된 파일 타입 (jpeg, png, heic, webp) 통과
- [x] **GREEN**: Photo 모델에 파일 검증 추가 ✅
  - [x] content_type 검증
  - [x] size 검증 (50MB 제한)
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 4.5.3 초대 링크 재사용

- [x] **RED**: 초대 링크 재사용 테스트 ✅
  - [x] 유효한 기존 초대가 있으면 재사용
  - [x] 만료된 초대만 있으면 새로 생성
  - [x] 초대가 없으면 새로 생성
- [x] **GREEN**: InvitesController에 find_or_create 로직 구현 ✅
  - [x] active 스코프 활용
  - [x] 기존 초대 재사용 로직
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 5: 사진 기능 (MVP 핵심)

### 5.1 사진 타임라인

- [x] **RED**: 타임라인 테스트 ✅
  - [x] 가족 사진 목록 조회
  - [x] 날짜별 그룹핑
  - [x] 무한 스크롤 (페이지네이션)
  - [x] 아이별 필터링
- [x] **GREEN**: Families::PhotosController#index 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 5.2 사진 업로드

- [x] **RED**: 사진 업로드 테스트 ✅
  - [x] 단일 사진 업로드
  - [x] 사진 메타데이터 저장
  - [x] 유효성 검증 (이미지, taken_at 필수)
- [x] **GREEN**: Families::PhotosController#create 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 로직 단순)

### 5.3 대량 업로드

- [x] **RED**: 대량 업로드 테스트 ✅
  - [x] 배치 API로 여러 사진 저장
  - [x] 실패한 항목 응답
- [x] **GREEN**: Families::PhotosController#batch 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 5.4 사진 상세

- [x] **RED**: 사진 상세 테스트 ✅
  - [x] 사진 상세 조회
  - [ ] 반응 목록 (Phase 6에서 구현)
  - [ ] 댓글 목록 (Phase 6에서 구현)
- [x] **GREEN**: Families::PhotosController#show 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 5.5 사진 수정/삭제

- [x] **RED**: 사진 수정/삭제 테스트 ✅
  - [x] 캡션 수정
  - [x] 아이 태그 변경
  - [x] 사진 삭제 (업로더 또는 admin)
- [x] **GREEN**: PhotosController#update, #destroy 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 5.6: 사진 기능 보안/안정성 강화 (P0)

> gap-scan Phase 5 분석 결과 - P0 항목 반영

### 5.6.1 역할 기반 권한 체크

- [x] **RED**: 역할 기반 권한 테스트 ✅
  - [x] viewer는 사진 업로드 불가
  - [x] member 이상만 업로드 가능
  - [x] owner/admin만 다른 사용자 사진 삭제 가능
- [x] **GREEN**: FamilyMembership에 권한 메서드 구현 ✅
  - [x] can_upload?, can_delete_photo? 메서드 추가
  - [x] PhotosController에 권한 체크 적용
- [x] **REFACTOR**: 변경 없음 (코드 간결) ✅

### 5.6.2 배치 업로드 검증

- [ ] **RED**: 배치 업로드 검증 테스트
  - [ ] 빈 배열 요청 시 400 응답
  - [ ] 배열이 아닌 요청 시 400 응답
  - [ ] 최대 개수 초과 시 400 응답
- [ ] **GREEN**: batch 액션에 입력 검증 추가
  - [ ] photos 파라미터 존재 여부 확인
  - [ ] 배열 타입 검증
  - [ ] MAX_BATCH_SIZE 상수 정의 및 검증
- [ ] **REFACTOR**: 검증 로직 메서드 추출

### 5.6.3 이미지 첨부 실패 처리

- [ ] **RED**: 이미지 첨부 실패 테스트
  - [ ] image.attach 실패 시 에러 메시지 반환
  - [ ] 저장소 오류 시 적절한 에러 처리
  - [ ] JSON 응답에 에러 상세 포함
- [ ] **GREEN**: Photo 모델에 첨부 에러 처리
  - [ ] ActiveStorage::Error rescue 추가
  - [ ] 사용자 친화적 에러 메시지 설정
- [ ] **REFACTOR**: 에러 처리 로직 정리

### 5.6.4 Direct Upload 실패 피드백

- [ ] **RED**: Direct Upload 실패 UI 테스트
  - [ ] 업로드 실패 시 사용자에게 피드백 표시
  - [ ] 재시도 옵션 제공
  - [ ] 실패 원인 안내
- [ ] **GREEN**: Stimulus 컨트롤러에 에러 핸들링 추가
  - [ ] direct-upload:error 이벤트 처리
  - [ ] 에러 메시지 UI 표시
- [ ] **REFACTOR**: 에러 UI 컴포넌트 추출

### 5.6.5 JSON 파싱 에러 처리

- [ ] **RED**: JSON 파싱 에러 테스트
  - [ ] 잘못된 JSON 형식 요청 시 400 응답
  - [ ] 파싱 에러 메시지 반환
- [ ] **GREEN**: ApplicationController에 JSON 파싱 에러 핸들러
  - [ ] ActionDispatch::Http::Parameters::ParseError rescue
  - [ ] 적절한 에러 응답 반환
- [ ] **REFACTOR**: 에러 핸들러 정리

### 5.6.6 N+1 쿼리 해결

- [ ] **RED**: N+1 쿼리 테스트
  - [ ] index 액션 쿼리 수 검증
  - [ ] 연관 객체 eager loading 확인
- [ ] **GREEN**: includes로 eager loading 적용
  - [ ] Photo.includes(:uploader, :child, image_attachment: :blob)
  - [ ] 페이지네이션과 함께 동작 확인
- [ ] **REFACTOR**: 쿼리 최적화 스코프 추출

---

## Phase 6: 반응 및 댓글

### 6.1 반응 기능

- [x] **RED**: 반응 기능 테스트 ✅
  - [x] 반응 추가
  - [x] 반응 변경
  - [x] 반응 삭제
  - [x] Turbo Stream 응답
- [x] **GREEN**: Photos::ReactionsController 구현 ✅
- [x] **REFACTOR**: FamilyAccessible concern 추출 ✅

### 6.2 댓글 기능

- [x] **RED**: 댓글 기능 테스트 ✅
  - [x] 댓글 작성
  - [x] 댓글 삭제 (작성자만)
  - [x] Turbo Stream 응답
- [x] **GREEN**: Photos::CommentsController 구현 ✅
- [x] **REFACTOR**: FamilyAccessible concern 적용 ✅

---

## Phase 6.5: 반응/댓글 입력 검증 (P0)

> gap-scan Phase 6 분석 결과 - P0 항목 반영

### 6.5.1 이모지 유효성 검증

- [ ] **RED**: 이모지 검증 테스트
  - [ ] 허용된 이모지만 저장 가능
  - [ ] 허용되지 않은 문자열 거부
  - [ ] 빈 값 거부
- [ ] **GREEN**: Reaction 모델에 이모지 검증 추가
  - [ ] ALLOWED_EMOJIS 상수 정의
  - [ ] validates :emoji, inclusion: { in: ALLOWED_EMOJIS }
- [ ] **REFACTOR**: 이모지 상수를 config로 추출

### 6.5.2 댓글 길이 제한

- [ ] **RED**: 댓글 길이 제한 테스트
  - [ ] 1000자 이하 댓글 저장 가능
  - [ ] 1000자 초과 시 거부
  - [ ] 에러 메시지 확인
- [ ] **GREEN**: Comment 모델에 길이 검증 추가
  - [ ] validates :body, length: { maximum: 1000 }
  - [ ] i18n 에러 메시지 설정
- [ ] **REFACTOR**: 상수로 추출 (MAX_BODY_LENGTH)

### 6.5.3 허용 이모지 목록 정의

- [ ] **RED**: 이모지 목록 테스트
  - [ ] UI에서 허용된 이모지 목록 제공
  - [ ] API에서 이모지 목록 조회 가능
- [ ] **GREEN**: 이모지 목록 구현
  - [ ] Reaction::ALLOWED_EMOJIS 정의
  - [ ] 이모지 선택 UI 구현
- [ ] **REFACTOR**: 이모지 설정 중앙화

### 6.5.4 잘못된 이모지 입력 처리

- [ ] **RED**: 잘못된 이모지 에러 처리 테스트
  - [ ] 유효하지 않은 이모지 요청 시 422 응답
  - [ ] 사용자 친화적 에러 메시지 반환
  - [ ] Turbo Stream으로 에러 표시
- [ ] **GREEN**: ReactionsController에 에러 처리 추가
  - [ ] 검증 실패 시 에러 응답
  - [ ] Turbo Stream 에러 템플릿
- [ ] **REFACTOR**: 에러 응답 패턴 정리

### 6.5.5 긴 댓글 입력 처리

- [ ] **RED**: 긴 댓글 에러 처리 테스트
  - [ ] 길이 초과 시 422 응답
  - [ ] 현재 길이 및 최대 길이 안내
  - [ ] 입력 중 실시간 카운터 표시
- [ ] **GREEN**: CommentsController 및 UI 개선
  - [ ] 검증 에러 응답 처리
  - [ ] Stimulus로 글자 수 카운터 구현
- [ ] **REFACTOR**: 입력 검증 UI 컴포넌트화

---

## Phase 7: 설정 및 프로필

### 7.1 사용자 프로필

- [x] **RED**: 프로필 설정 테스트 ✅
  - [x] 프로필 조회
  - [x] 닉네임 수정
  - [x] 아바타 변경
- [x] **GREEN**: Settings::ProfilesController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 7.2 알림 설정

- [x] **RED**: 알림 설정 테스트 ✅
  - [x] 알림 설정 조회
  - [x] 알림 설정 변경
- [x] **GREEN**: Settings::NotificationsController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 7.5: 설정/프로필 UI 및 검증 (P0)

> gap-scan Phase 7 분석 결과 - P0 항목 반영

### 7.5.1 TailwindCSS 스타일링

- [ ] **RED**: UI 스타일 테스트
  - [ ] 프로필 페이지에 TailwindCSS 클래스 적용 확인
  - [ ] 알림 설정 페이지 스타일 확인
  - [ ] 반응형 레이아웃 동작 확인
- [ ] **GREEN**: TailwindCSS 스타일 적용
  - [ ] 프로필 폼 스타일링
  - [ ] 알림 설정 토글 스타일링
  - [ ] 공통 form 컴포넌트 스타일
- [ ] **REFACTOR**: 스타일 클래스 component로 추출

### 7.5.2 닉네임 검증 강화

- [ ] **RED**: 닉네임 검증 테스트
  - [ ] 2-20자 길이 제한
  - [ ] 허용 문자 (한글, 영문, 숫자, 언더스코어)
  - [ ] 금지어 필터링
  - [ ] XSS 방지 (스크립트 태그 등 거부)
- [ ] **GREEN**: User 모델에 닉네임 검증 추가
  - [ ] validates :nickname, length: { in: 2..20 }
  - [ ] validates :nickname, format: { with: NICKNAME_REGEX }
  - [ ] custom validator로 금지어 체크
- [ ] **REFACTOR**: 검증 로직 concern으로 추출

### 7.5.3 i18n 메시지 적용

- [ ] **RED**: i18n 테스트
  - [ ] flash 메시지가 i18n 키로 제공
  - [ ] 에러 메시지 한국어로 표시
  - [ ] 설정 페이지 레이블 i18n
- [ ] **GREEN**: i18n 파일 구성
  - [ ] config/locales/settings.ko.yml 생성
  - [ ] 컨트롤러 flash 메시지 i18n 적용
  - [ ] 뷰 텍스트 i18n 적용
- [ ] **REFACTOR**: locale 파일 구조화

### 7.5.4 뷰 레이블 i18n

- [ ] **RED**: 뷰 레이블 i18n 테스트
  - [ ] form_for 레이블 i18n
  - [ ] 버튼 텍스트 i18n
  - [ ] 안내 문구 i18n
- [ ] **GREEN**: 뷰에 i18n 헬퍼 적용
  - [ ] t(".label_name") 형식 사용
  - [ ] model attribute 번역 설정
- [ ] **REFACTOR**: 공통 번역 키 추출

### 7.5.5 닉네임 보안 검증

- [ ] **RED**: 닉네임 보안 테스트
  - [ ] HTML 태그 포함 시 거부
  - [ ] SQL injection 패턴 거부
  - [ ] 특수문자 제한
- [ ] **GREEN**: 보안 검증 구현
  - [ ] sanitize 처리
  - [ ] 허용 문자 화이트리스트
- [ ] **REFACTOR**: 보안 검증 공통화

### 7.5.6 아바타 파일 검증

- [ ] **RED**: 아바타 파일 검증 테스트
  - [ ] 허용 타입 (jpeg, png, webp)만 업로드 가능
  - [ ] 파일 크기 5MB 제한
  - [ ] 잘못된 파일 에러 메시지
- [ ] **GREEN**: User 모델에 아바타 검증 추가
  - [ ] content_type 검증
  - [ ] byte_size 검증
- [ ] **REFACTOR**: 파일 검증 concern 추출

### 7.5.7 API 에러 응답 표준화

- [ ] **RED**: API 에러 응답 테스트
  - [ ] 검증 실패 시 표준 JSON 형식
  - [ ] 필드별 에러 메시지 포함
  - [ ] HTTP 상태 코드 적절성
- [ ] **GREEN**: 에러 응답 포맷 구현
  - [ ] render_validation_errors 헬퍼
  - [ ] { errors: { field: [messages] } } 형식
- [ ] **REFACTOR**: API 응답 헬퍼 모듈화

---

## Phase 8: Native 브릿지 API

### 8.1 동기화 API

- [x] **RED**: 동기화 API 테스트 ✅
  - [x] 앱 시작 시 필요 정보 일괄 조회
  - [x] JSON 응답 형식 확인
- [x] **GREEN**: Api::Native::SyncsController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 8.2 푸시 토큰 등록

- [x] **RED**: 푸시 토큰 테스트 ✅
  - [x] 기기 토큰 등록
  - [x] 기기 토큰 삭제
- [x] **GREEN**: Api::Native::PushTokensController 구현 ✅
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 8.5: Native API 보안 및 기능 (P0)

> gap-scan Phase 8 분석 결과 - P0 항목 반영

### 8.5.1 CSRF 보호 검토

- [x] **RED**: CSRF 보안 테스트 ✅
  - [x] API 엔드포인트 CSRF 보호 상태 확인
  - [x] Origin 헤더 검증 테스트
  - [x] 무단 요청 차단 테스트
- [x] **GREEN**: API 보안 구현 ✅
  - [x] skip_before_action :verify_authenticity_token 검토
  - [x] Origin 헤더 검증 추가
  - [x] ALLOWED_ORIGINS 화이트리스트 구현
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

### 8.5.2 푸시 알림 실제 전송

- [x] **RED**: 푸시 알림 전송 테스트 ✅
  - [x] iOS 토큰으로 알림 전송
  - [x] Android 토큰으로 알림 전송
  - [x] 전송 실패 처리
- [x] **GREEN**: 푸시 알림 서비스 구현 ✅
  - [x] PushNotificationService 생성
  - [x] 플랫폼별 전송 로직 (스텁 구현)
  - [x] SendPushNotificationJob 구현
- [x] **REFACTOR**: 필요시 코드 정리 ✅ (변경 없음 - 코드 간결)

---

## Phase 9: UI/UX 마무리

### 9.1 레이아웃

- [x] **RED**: 레이아웃 테스트 ✅
  - [x] 메인 레이아웃 렌더링
  - [x] 하단 탭바 표시
  - [x] 인증 상태별 분기
- [x] **GREEN**: 레이아웃 뷰 구현 ✅
- [x] **REFACTOR**: 공통 partial 추출 ✅ (_header, _tabbar)

---

## Phase 9.1.5: 레이아웃 기능 연결 (P0)

> gap-scan Phase 9.1 분석 결과 - P0 항목 반영

### 9.1.5.1 OAuth 제공자 링크 연결

- [x] **RED**: OAuth 링크 테스트 ✅
  - [x] 카카오 로그인 버튼이 실제 OAuth URL로 연결
  - [x] 미구현 제공자(Apple/Google) 비활성화 처리
  - [x] '#' 하드코딩 제거 확인
- [x] **GREEN**: OAuth 링크 구현 ✅
  - [x] /auth/kakao 경로로 연결
  - [x] 미구현 제공자는 비활성화 처리 (opacity-50, cursor-not-allowed)
  - [x] 로그인 버튼 클릭 시 OAuth 플로우 시작
- [x] **REFACTOR**: 로그인 버튼 partial 추출 ✅ (변경 없음 - 코드 간결)

---

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
| Phase 3: 온보딩 | ✅ 완료 | 2025-12-14 |
| Phase 3.5: 온보딩 보완 | ✅ 완료 | 2025-12-14 |
| Phase 4: 가족 관리 | ✅ 완료 | 2025-12-14 |
| Phase 4.5: 에러/보안 강화 | ✅ 완료 | 2025-12-15 |
| Phase 5: 사진 기능 | ✅ 완료 | 2025-12-15 |
| **Phase 5.6: 사진 보안/안정성** | 📋 대기 중 | - |
| Phase 6: 반응/댓글 | ✅ 완료 | 2025-12-15 |
| **Phase 6.5: 반응/댓글 검증** | 📋 대기 중 | - |
| Phase 7: 설정 | ✅ 완료 | 2025-12-15 |
| **Phase 7.5: 설정 UI/검증** | 📋 대기 중 | - |
| Phase 8: Native API | ✅ 완료 | 2025-12-15 |
| Phase 8.5: Native API 보안 | ✅ 완료 | 2025-12-15 |
| Phase 9.1: 레이아웃 | ✅ 완료 | 2025-12-15 |
| **Phase 9.1.5: 레이아웃 연결** | ✅ 완료 | 2025-12-15 |
| Phase 9.2-9.3: UI/UX 마무리 | 🔄 진행 중 | - |

---

## 기술 부채 및 향후 개선 사항

> 상세 분석: [docs/gaps/](./docs/gaps/)

### P1: 다음 스프린트 (MVP 출시 전)

#### Phase 5: 사진 기능

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 썸네일 variant 미정의 | variant 없음 | :thumbnail, :medium variant 추가 |
| 페이지네이션 미구현 | 전체 로딩 | pagy/kaminari 적용 |
| 타임라인 그룹핑 | 미구현 | 날짜별 그룹핑 뷰 |
| 사진 수정 기능 | update 미구현 | PhotosController#edit, #update |
| taken_at 자동 설정 | before_save 없음 | EXIF 또는 created_at 폴백 |
| 배치 업로드 트랜잭션 | 개별 저장 | 트랜잭션 래핑, 롤백 처리 |

#### Phase 6: 반응/댓글

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 반응 카운트 캐싱 | 매번 count | counter_cache 적용 |
| 댓글 페이지네이션 | 전체 로딩 | 무한 스크롤 구현 |
| 반응 Turbo Stream | 미구현 | 실시간 반응 업데이트 |
| 이모지 선택 UI | 텍스트 입력 | 이모지 피커 컴포넌트 |

#### Phase 7: 설정/프로필

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 프로필 show 뷰 | 미생성 | settings/profiles/show.html.erb |
| 알림 설정 show 뷰 | 미생성 | settings/notifications/show.html.erb |
| 아바타 업로드 | 미구현 | Active Storage 연동, 업로드 UI |
| 알림 on/off 토글 | 단순 boolean | notification_settings 분리 |

#### Phase 8: Native API

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| JWT/토큰 인증 | 세션 기반 | 토큰 기반 인증 구현 |
| API 버저닝 | 미적용 | /api/v1/ 네임스페이스 |
| 응답 포맷 표준화 | 기본 JSON | JSON:API 또는 커스텀 포맷 |
| 동기화 데이터 | 기본 정보만 | 변경 추적, delta sync |

#### Phase 9: UI/UX

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 탭바 active 상태 | 미구현 | current_page? 활용 |
| 헤더 뒤로가기 | 미구현 | 조건부 back 버튼 |
| 로딩 상태 | 미구현 | 스켈레톤 UI |
| 접근성 | 미적용 | ARIA 레이블, 포커스 관리 |

#### 공통

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 알림 시스템 | 미구현 | Notification 모델, FCM/APNs 연동 |
| 이용약관 동의 | 미구현 | User에 terms_agreed_at 필드, 동의 페이지 |
| 인가 로직 중복 | 3개 컨트롤러 반복 | FamilyAuthorizable concern 추출 |
| 테스트용 세션 보안 | 환경 체크 없음 | Rails.env.test? 체크 추가 |
| HTTP 상태 코드 | 권한 없음에 302 | 403/401 응답 적용 |
| Email 포맷 검증 | presence만 검증 | URI::MailTo::EMAIL_REGEXP 적용 |
| OAuth 실패 처리 | 기본 처리만 | failure 액션 및 에러 처리 추가 |
| 에러 페이지 뷰 | 미구현 | errors/404, 500, 403 생성 |
| System Tests | 미구현 | 온보딩, 사진 업로드 E2E 테스트 |

---

### P2: 백로그 (출시 후 개선)

#### Phase 5: 사진 기능

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 이미지 최적화 | 미적용 | WebP 변환, 압축 |
| 대용량 처리 | 단순 저장 | Background Job 처리 |
| 다중 선택 삭제 | 미구현 | 배치 삭제 API |
| 사진 정렬 옵션 | taken_at만 | 다양한 정렬 옵션 |
| EXIF 추출 | 미구현 | 촬영 정보 메타데이터 |
| 비디오 지원 | 미구현 | MP4 업로드, 썸네일 생성 |
| 중복 사진 감지 | 미구현 | 해시 기반 중복 체크 |
| 필터링 옵션 | child만 | 날짜, 업로더 필터 |

#### Phase 6: 반응/댓글

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 댓글 수정 | 미구현 | CommentsController#edit, #update |
| 대댓글 | 미구현 | parent_id 추가 |
| 멘션 기능 | 미구현 | @user 파싱, 알림 |
| 반응 통계 | 미구현 | 이모지별 카운트 표시 |
| 댓글 알림 | 미구현 | 댓글 작성 시 알림 |

#### Phase 7: 설정/프로필

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 계정 삭제 | 미구현 | 데이터 삭제 정책 |
| 개인정보 내보내기 | 미구현 | GDPR 대응 |
| 테마 설정 | 미구현 | 다크 모드 지원 |
| 언어 설정 | 한국어 고정 | 다국어 지원 |

#### Phase 8: Native API

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 오프라인 지원 | 미구현 | 로컬 캐시, 동기화 큐 |
| 배터리 최적화 | 미고려 | 백그라운드 업로드 최적화 |
| Rate limiting | 미적용 | API 호출 제한 |
| 에러 모니터링 | 기본만 | Sentry/Bugsnag 연동 |

#### Phase 9: UI/UX

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| 애니메이션 | 미적용 | Turbo 전환 애니메이션 |
| 제스처 | 미구현 | 스와이프, 핀치 줌 |
| PWA 지원 | 미구현 | Service Worker, manifest |
| 다크 모드 | 미구현 | TailwindCSS dark: |
| 온보딩 튜토리얼 | 미구현 | 첫 사용자 가이드 |

#### 공통

| 항목 | 현재 상태 | 필요 작업 |
|-----|----------|----------|
| OAuth 제공자 확장 | 카카오만 | Apple, Google omniauth 추가 |
| 초대 공유 방법 | URL 복사만 | 카카오톡 공유, QR 코드 |
| 검색 기능 | 미구현 | 사진 검색 UI, Photo 스코프 |
| 앨범 기능 | 미구현 | Album 모델, AlbumsController |
| 초대 만료 기간 | 하드코딩 | config 또는 상수로 추출 |
| 버튼/Flash 텍스트 | 하드코딩 | i18n 적용 |
| 동시 요청 처리 | 중복 생성 에러 | find_or_create_by 사용 |
| 로깅 개선 | Rails 기본만 | 주요 액션에 감사 로깅 추가 |
| 성능 모니터링 | 미구현 | APM 도구 연동 |
| CDN | 미적용 | Active Storage CDN 설정 |

---

## 참고 문서

- [PRD](/docs/features/mvp/PRD.md)
- [아키텍처](/docs/features/mvp/ARCHITECTURE.md)
- [API 설계](/docs/features/mvp/API_DESIGN.md)
- [화면 설계](/docs/features/mvp/WIREFRAME.md)
- [구현 현황 분석](/docs/features/mvp/IMPLEMENTATION_GAPS.md)
