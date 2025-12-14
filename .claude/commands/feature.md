# 기능 설계 자동화

$ARGUMENTS 기능을 설계합니다. 각 단계마다 확인을 요청합니다.

---

## 0단계: 폴더 생성

먼저 기능 문서를 저장할 폴더를 생성하세요:

```bash
mkdir -p docs/features/$ARGUMENTS
```

이후 모든 문서는 `docs/features/$ARGUMENTS/` 폴더에 생성됩니다.

---

## 1단계: 코드베이스 탐색

다음을 검색하여 관련 코드와 패턴을 파악하세요:

1. **모델**: `app/models/`에서 $ARGUMENTS 관련 모델 또는 유사 패턴
2. **컨트롤러**: `app/controllers/`에서 유사한 CRUD 패턴
3. **서비스**: `app/services/`에서 참고할 서비스 객체
4. **라우트**: `config/routes.rb`에서 중첩 리소스 패턴
5. **뷰**: `app/views/`에서 Turbo Frame/Stream 패턴
6. **테스트**: `test/`에서 유사 테스트 패턴

탐색 결과를 다음 형식으로 요약하세요:

```
## 코드베이스 탐색 결과

### 관련 모델
- [모델명]: [설명]

### 참고할 패턴
- [파일]: [참고할 내용]

### 필요한 변경
- [변경 내용]
```

**AskUserQuestion 도구를 사용하여 계속 진행할지 확인하세요.**
옵션: "계속 진행" / "탐색 더 필요" / "중단"

---

## 2단계: PRD 문서 생성

@docs/PRD.md 의 기존 형식을 참고하여 `docs/features/$ARGUMENTS/PRD.md` 파일을 작성하세요:

```markdown
# $ARGUMENTS 기능 PRD

## 기능 개요
[1-2문장으로 기능 설명]

## 사용자 스토리
- [역할]로서 [행동]을 할 수 있다, 그래서 [가치]를 얻는다
- [역할]로서 [행동]을 할 수 있다, 그래서 [가치]를 얻는다

## 수용 조건
- [ ] 조건1
- [ ] 조건2
- [ ] 조건3

## 우선순위
- Must Have / Should Have / Could Have / Won't Have (MVP)

## 관련 화면
- [화면 ID]: [화면명]
```

**미리보기를 보여주고 AskUserQuestion으로 확인하세요.**
옵션: "파일 생성" / "수정 필요" / "건너뛰기"

확인되면 `docs/features/$ARGUMENTS/PRD.md` 파일을 생성하세요.

---

## 3단계: ARCHITECTURE 문서 생성

@docs/ARCHITECTURE.md 형식을 참고하여 `docs/features/$ARGUMENTS/ARCHITECTURE.md` 파일을 작성하세요:

```markdown
# $ARGUMENTS 아키텍처

## 데이터 모델

### 테이블 정의

| 컬럼 | 타입 | 제약조건 | 설명 |
|-----|------|---------|------|
| id | bigint | PK | |
| [필드] | [타입] | [제약] | [설명] |
| created_at | datetime | NOT NULL | |
| updated_at | datetime | NOT NULL | |

### 연관관계

```ruby
class [모델명] < ApplicationRecord
  belongs_to :[부모]
  has_many :[자식], dependent: :destroy
end
```

### 인덱스
- `[컬럼]`: [용도]

## 시퀀스 다이어그램

```
[주요 플로우 설명]
```
```

**미리보기를 보여주고 AskUserQuestion으로 확인하세요.**
옵션: "파일 생성" / "수정 필요" / "건너뛰기"

확인되면 `docs/features/$ARGUMENTS/ARCHITECTURE.md` 파일을 생성하세요.

---

## 4단계: API 설계 문서 생성

@docs/API_DESIGN.md 형식을 참고하여 `docs/features/$ARGUMENTS/API_DESIGN.md` 파일을 작성하세요:

```markdown
# $ARGUMENTS API 설계

## 엔드포인트 목록

| Method | Path | Description |
|--------|------|-------------|
| GET | /families/{family_id}/[리소스] | 목록 조회 |
| POST | /families/{family_id}/[리소스] | 생성 |
| DELETE | /families/{family_id}/[리소스]/{id} | 삭제 |

## 상세 API

### 목록 조회
```
GET /families/{family_id}/[리소스]
```

**응답 예시:**
```json
{
  "data": []
}
```

### 생성
```
POST /families/{family_id}/[리소스]
```

**요청 예시:**
```json
{
  "[필드]": "[값]"
}
```

**응답:** 201 Created

### 삭제
```
DELETE /families/{family_id}/[리소스]/{id}
```

**응답:** 204 No Content
```

**미리보기를 보여주고 AskUserQuestion으로 확인하세요.**
옵션: "파일 생성" / "수정 필요" / "건너뛰기"

확인되면 `docs/features/$ARGUMENTS/API_DESIGN.md` 파일을 생성하세요.

---

## 5단계: 화면 설계 문서 생성

@docs/WIREFRAME.md 형식을 참고하여 `docs/features/$ARGUMENTS/WIREFRAME.md` 파일을 작성하세요:

```markdown
# $ARGUMENTS 화면 설계

## 화면 목록

| ID | 화면명 | 설명 |
|----|-------|------|
| [ID] | [화면명] | [설명] |

## 상세 화면

### [화면명] ([화면ID])

```
┌─────────────────────────────────────┐
│  [헤더]                              │
├─────────────────────────────────────┤
│                                     │
│  [메인 컨텐츠 영역]                  │
│                                     │
├─────────────────────────────────────┤
│  [입력/액션 영역]                    │
└─────────────────────────────────────┘
```

**구성 요소:**
- [요소1]: [설명]
- [요소2]: [설명]

**상호작용:**
- [트리거] → [결과]

**Turbo 처리:**
- turbo_frame_tag: [프레임 ID]
- turbo_stream: [액션]
```

**미리보기를 보여주고 AskUserQuestion으로 확인하세요.**
옵션: "파일 생성" / "수정 필요" / "건너뛰기"

확인되면 `docs/features/$ARGUMENTS/WIREFRAME.md` 파일을 생성하세요.

---

## 6단계: 규칙 문서 필요 여부

다음 조건에 해당하는지 판단하세요:
- 복잡한 비즈니스 로직 (3개 이상 규칙)
- 특수 보안 요구사항 (인증, 권한, 데이터 보호)
- 외부 API 연동
- 프로젝트 전반에 영향을 주는 새 패턴

**AskUserQuestion으로 확인:**
옵션: "규칙 문서 생성" / "필요 없음"

규칙 문서 생성 시 `docs/features/$ARGUMENTS/RULES.md` 파일을 생성하고,
@.claude/rules/coding-guide.md 형식을 참고하세요.

---

## 7단계: 완료 요약

모든 단계가 완료되면 다음을 요약하세요:

```
## $ARGUMENTS 기능 설계 완료

### 생성된 문서
📁 docs/features/$ARGUMENTS/
├── PRD.md           - 요구사항 정의
├── ARCHITECTURE.md  - 아키텍처 설계
├── API_DESIGN.md    - API 설계
├── WIREFRAME.md     - 화면 설계
└── RULES.md         - 규칙 문서 (해당 시)

### 다음 단계
1. plan.md에 TDD 작업 항목 추가
2. /tdd 커맨드로 구현 시작
```
