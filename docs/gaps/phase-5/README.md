# Phase 5 사진 기능 Gap 분석

> 작성일: 2025-12-15
> 분석 대상: Phase 5 사진 업로드 및 타임라인 기능
> 상태: 기능 구현 완료, 개선 사항 식별됨

---

## 개요

Phase 5 사진 기능의 현재 구현 상태를 분석하고, MVP 출시 후 개선이 필요한 영역을 5가지 카테고리로 분류했습니다.

### 분석 파일
- `app/controllers/families/photos_controller.rb`
- `app/controllers/concerns/family_accessible.rb`
- `app/models/photo.rb`
- `app/views/families/photos/*.html.erb`
- `test/controllers/families/photos_controller_test.rb`

---

## Gap 카테고리별 요약

| 카테고리 | 총 항목 | P0 (즉시) | P1 (다음 스프린트) | P2 (백로그) | 문서 |
|---------|---------|-----------|-------------------|-------------|------|
| **의도적 단순화** | 8 | 0 | 3 | 5 | [intentional-simplifications.md](./intentional-simplifications.md) |
| **임시 구현** | 7 | 2 | 3 | 2 | [temporary-implementations.md](./temporary-implementations.md) |
| **미구현 기능** | 12 | 0 | 4 | 8 | [not-implemented.md](./not-implemented.md) |
| **하드코딩된 값** | 6 | 0 | 2 | 4 | [hardcoded-values.md](./hardcoded-values.md) |
| **에러 처리 누락** | 10 | 4 | 4 | 2 | [missing-error-handling.md](./missing-error-handling.md) |
| **전체** | **43** | **6** | **16** | **21** | - |

---

## 즉시 수정 필요 (P0)

### 1. 에러 처리 누락 (4개)
- ❌ **Batch 업로드 빈 배열 검증**: 잘못된 요청으로 500 에러 가능
- ❌ **Image.attach 실패 처리**: 파일 업로드 실패 시 데이터 불일치
- ❌ **Direct Upload 실패 피드백**: 사용자가 업로드 실패를 알 수 없음
- ❌ **JSON 파싱 에러**: 잘못된 형식 전송 시 500 에러

### 2. 임시 구현 (2개)
- ❌ **역할 기반 권한 체크 부재**: viewer/member/admin 구분 없이 모두 수정/삭제 가능
- ❌ **N+1 쿼리 위험**: `@family.children`에서 추가 쿼리 발생

---

## 다음 스프린트 우선순위 (P1)

### 의도적 단순화 개선 (3개)
1. ✅ 이미지 Variant 생성 (썸네일/중간/대형)
2. ✅ 페이지네이션 UI 구현
3. ✅ 앨범 기능 UI 구현

### 임시 구현 개선 (3개)
1. ✅ Batch 업로드 트랜잭션 처리
2. ✅ Direct Upload 진행률 표시
3. ✅ JSON 응답 표준화

### 미구현 기능 (4개)
1. ✅ 무한 스크롤
2. ✅ Background Job 처리
3. ✅ 대량 삭제 기능
4. ✅ 동시 업로드 큐 관리

### 하드코딩 개선 (2개)
1. ✅ 페이지당 아이템 수 설정화
2. ✅ i18n 메시지 적용

### 에러 처리 추가 (4개)
1. ✅ 파일 타입 이중 검증
2. ✅ set_family 로깅
3. ✅ destroy 실패 처리
4. ✅ 페이지 파라미터 검증

---

## 주요 발견 사항

### ✅ 잘 구현된 부분
- Active Storage Direct Upload 활용
- N+1 쿼리 방지 (`includes(:uploader, :child)`)
- 파일 크기 및 타입 검증 (모델 레벨)
- RESTful 라우팅 및 컨트롤러 구조
- Batch 업로드 API (부분 성공 허용)
- 테스트 커버리지 양호

### ⚠️ 개선 필요한 부분
1. **보안**: 역할 기반 권한 체크 부재
2. **성능**: 이미지 variant 없어 원본 로딩 (느림)
3. **UX**: 페이지네이션 UI 없음, 진행률 표시 없음
4. **에러 처리**: 예외 상황 대응 부족
5. **확장성**: Background Job 미사용, 대량 데이터 처리 고려 부족

---

## 개선 로드맵

### 단기 (1-2주)
1. **P0 에러 처리 수정**: 안정성 확보
2. **역할 기반 권한 구현**: 보안 강화
3. **이미지 Variant 생성**: 성능 개선

### 중기 (1개월)
1. **Background Job 도입**: 확장성 확보
2. **무한 스크롤 구현**: UX 개선
3. **페이지네이션 UI**: 사용자 편의성
4. **i18n 적용**: 유지보수성

### 장기 (2-3개월)
1. **동영상 지원**: 기능 확장
2. **얼굴 인식**: AI 기능
3. **앨범 관리**: 사진 정리
4. **검색 기능**: 편의성

---

## 메트릭

### 코드 품질
- 테스트 커버리지: ~80% (추정)
- RuboCop 위반: 없음 (확인 필요)
- 보안 취약점: 중간 (권한 체크 부족)

### 성능
- N+1 쿼리: 부분적으로 방지됨
- 이미지 최적화: 미흡 (variant 없음)
- 페이지네이션: 간단한 offset (대량 데이터 시 느림)

### 유지보수성
- i18n 적용: 미흡 (하드코딩된 메시지)
- 설정 분리: 미흡 (하드코딩된 상수)
- 문서화: 양호 (테스트가 문서 역할)

---

## 참고 자료

- [PRD - Phase 5 사진 기능](/docs/features/mvp/PRD.md#phase-5-사진-기능)
- [API 설계 - Photos API](/docs/features/mvp/API_DESIGN.md#photos-api)
- [아키텍처 가이드](/docs/guides/ARCHITECTURE_GUIDE.md)
- [코딩 가이드](/docs/guides/CODING_GUIDE.md)

---

## 관련 이슈

- 생성 예정: "Phase 5 사진 기능 개선 - P0 에러 처리"
- 생성 예정: "Phase 5 사진 기능 개선 - P1 UX 개선"

---

**검토자**: -
**승인자**: -
**다음 검토일**: 2025-12-22
