# 단순화/생략 작업 추적 및 반영

## 기본 사용
```text
지금까지 작업한 내용 중에 의도적으로 작업을 단순화하거나 작업하지 않은 부분을 분석해줘.

먼저 폴더를 생성해줘:
mkdir -p docs/gaps/[작업명]

다음 카테고리별로 파일을 생성해줘:
1. **의도적 단순화**: `intentional-simplifications.md` - MVP 범위로 축소한 기능
2. **임시 구현**: `temporary-implementations.md` - 나중에 개선이 필요한 코드
3. **미구현 항목**: `not-implemented.md` - 건너뛴 기능이나 테스트
4. **하드코딩**: `hardcoded-values.md` - 설정값이나 상수로 분리해야 할 부분
5. **에러 처리 누락**: `missing-error-handling.md` - 예외 상황 처리가 부족한 부분

각 파일 형식:
```markdown
# [카테고리명] - [작업명]

## 요약
- 총 항목 수: N개
- P0 (즉시): N개
- P1 (다음 스프린트): N개
- P2 (백로그): N개

## 항목 목록

### 1. [항목명]
- **현재 상태**:
- **개선 필요 사항**:
- **우선순위**: P0/P1/P2
- **관련 파일**:
```

## 생성되는 폴더 구조
```
docs/gaps/[작업명]/
├── intentional-simplifications.md  # 의도적 단순화
├── temporary-implementations.md    # 임시 구현
├── not-implemented.md              # 미구현 항목
├── hardcoded-values.md             # 하드코딩
└── missing-error-handling.md       # 에러 처리 누락
```

---

## gaps 기반 plan.md 업데이트
```text
@docs/gaps/[작업명]/ 폴더의 모든 파일을 분석하고 우선 작업할 수 있도록 @plan.md 에 반영해줘.

수행할 작업:
1. 각 파일에서 P0(즉시 반영) 항목 추출
2. plan.md에 해당 작업을 TDD 사이클로 추가
   - 각 항목을 RED/GREEN/REFACTOR 단계로 분해
   - 기존 Phase 흐름에 맞게 배치
3. P1/P2 항목은 plan.md 하단 "Future Work" 섹션에 정리

업데이트 후 변경 사항 요약해줘.
```

```text
서브 에이전트에게 대상 폴더 하위의 파일을 분석하고 우선 작업할 수 있도록 @plan.md 에 반영해줘.

# gap 대상 폴더
@docs/gaps/phase-5/
@docs/gaps/phase-6/
@docs/gaps/phase-7/
@docs/gaps/phase-8/
@docs/gaps/phase-9.1/

---

수행할 작업:
1. 각 파일에서 P0(즉시 반영) 항목 추출
2. plan.md에 해당 작업을 TDD 사이클로 추가
   - 각 항목을 RED/GREEN/REFACTOR 단계로 분해
   - 기존 Phase 흐름에 맞게 배치
3. P1/P2 항목은 plan.md 하단 "Future Work" 섹션에 정리
4. 각 기능의 연관관계를 파악해서 작업 우선순위 설정

업데이트 후 할당해서 변경 사항 요약해줘.
```

---

## 세션 종료 전 갭 분석
```text
이번 세션에서 작업한 내용을 기준으로 갭 분석해줘.

작업명: [작업명 또는 날짜]

확인 사항:
1. plan.md 체크리스트 중 완료 표시했지만 실제로 불완전한 항목
2. 테스트는 통과하지만 엣지케이스 누락된 부분
3. 설계 문서(PRD, API_DESIGN, ARCHITECTURE)와 실제 구현 차이
4. TODO/FIXME 주석으로 남긴 부분

결과를 docs/gaps/[작업명]/ 폴더에 카테고리별로 저장하고,
즉시 수정이 필요한 항목은 @plan.md 에도 반영해줘.
```

---

## 코드베이스 전체 갭 스캔
```text
프로젝트 전체에서 단순화/미완성 부분을 스캔해줘.

작업명: [스캔 날짜 또는 버전]

검색할 패턴:
- TODO, FIXME, HACK, XXX 주석
- raise NotImplementedError
- skip 또는 pending 테스트
- 하드코딩된 값 (매직 넘버, 문자열)
- 빈 rescue 블록
- 주석 처리된 코드

결과를 docs/gaps/[작업명]/ 폴더에 카테고리별로 저장해줘.
각 파일은 다음 형식으로 정리:

| 파일:라인 | 내용 | 우선순위 |
|-----------|------|----------|

P0 항목은 @plan.md 에 즉시 추가해줘.
```

---

## 특정 기능 갭 분석
```text
[기능명] 구현에 대한 갭 분석해줘.

작업명: [기능명]

분석 대상:
- @docs/features/[기능명]/ 설계 문서
- 관련 컨트롤러, 모델, 서비스, 테스트 파일

결과를 docs/gaps/[기능명]/ 폴더에 저장해줘.
```
