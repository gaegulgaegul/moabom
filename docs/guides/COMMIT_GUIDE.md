# 모아봄 커밋 가이드

> Git 커밋 메시지 및 워크플로우 규칙
> 버전: 1.0
> 최종 수정: 2025-12-14

---

## 1. 커밋 메시지 형식

### 1.1 기본 구조

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 1.2 실제 예시

```
feat(photo): 사진 업로드 기능 구현

- Active Storage Direct Upload 적용
- 업로드 진행률 표시 UI 추가
- 배치 업로드 API 구현

Closes #12
```

---

## 2. 타입 (Type)

### 2.1 주요 타입

| 타입 | 설명 | 예시 |
|-----|------|------|
| `feat` | 새로운 기능 추가 | `feat(auth): 카카오 로그인 구현` |
| `fix` | 버그 수정 | `fix(photo): 이미지 회전 오류 수정` |
| `refactor` | 코드 리팩토링 (기능 변경 없음) | `refactor(photo): 업로드 서비스 분리` |
| `style` | 코드 스타일 변경 (포맷팅) | `style: rubocop 자동 수정 적용` |
| `test` | 테스트 추가/수정 | `test(photo): 업로드 서비스 테스트 추가` |
| `docs` | 문서 변경 | `docs: API 문서 업데이트` |
| `chore` | 빌드, 설정 변경 | `chore: tailwind 설정 업데이트` |
| `perf` | 성능 개선 | `perf(photo): 이미지 로딩 최적화` |

### 2.2 Tidy First 원칙

Kent Beck의 "Tidy First" 원칙에 따라 **구조적 변경**과 **동작적 변경**을 분리합니다.

```
# 구조적 변경 (Structural) - 동작 변경 없음
refactor(photo): PhotoService를 PhotoUploadService로 이름 변경
refactor(model): Photo 모델에서 validation을 concern으로 추출
style: 들여쓰기 수정

# 동작적 변경 (Behavioral) - 기능 변경
feat(photo): 사진 업로드 기능 추가
fix(photo): 중복 업로드 방지 로직 추가
```

**중요: 하나의 커밋에 구조적 변경과 동작적 변경을 섞지 않습니다.**

---

## 3. 스코프 (Scope)

### 3.1 도메인 스코프

| 스코프 | 설명 |
|-------|------|
| `auth` | 인증/인가 |
| `user` | 사용자 관리 |
| `family` | 가족 그룹 |
| `child` | 아이 프로필 |
| `photo` | 사진/동영상 |
| `album` | 앨범 |
| `reaction` | 반응 |
| `comment` | 댓글 |
| `notification` | 알림 |
| `invite` | 초대 |

### 3.2 기술 스코프

| 스코프 | 설명 |
|-------|------|
| `api` | API 관련 |
| `db` | 데이터베이스/마이그레이션 |
| `ui` | 프론트엔드 UI |
| `job` | Background Job |
| `config` | 설정 파일 |
| `deps` | 의존성 |

---

## 4. 제목 (Subject)

### 4.1 규칙

- 50자 이내
- 명령형 현재 시제 사용 (한글: "~구현", "~수정", "~추가")
- 첫 글자 소문자 (영어) / 명사로 시작 (한글)
- 마침표 없음

### 4.2 예시

```
# Good
feat(photo): 사진 업로드 기능 구현
fix(auth): 로그인 세션 만료 오류 수정
refactor(photo): 업로드 로직을 서비스로 분리

# Bad
feat(photo): 사진 업로드 기능 구현.          # 마침표
feat(photo): 사진 업로드 기능을 구현했습니다   # 과거형
feat(photo): Added photo upload             # 과거형 (영어)
feat: 기능 추가                              # 스코프 없음, 불명확
```

---

## 5. 본문 (Body)

### 5.1 규칙

- 72자에서 줄바꿈
- "무엇을"과 "왜"를 설명 (어떻게는 코드가 설명)
- 빈 줄로 제목과 구분

### 5.2 예시

```
feat(photo): 대량 업로드 기능 구현

기존 단일 업로드 방식으로는 많은 사진을 올리기 어려웠음.
사용자가 한 번에 수백 장의 사진을 선택하여 업로드할 수 있도록
배치 처리 방식을 도입함.

- 순차 업로드로 서버 부하 분산 (동시 3개)
- 실패한 파일 자동 재시도 (최대 3회)
- 업로드 진행률 실시간 표시
```

---

## 6. 푸터 (Footer)

### 6.1 이슈 참조

```
# 이슈 종료
Closes #123
Fixes #456
Resolves #789

# 이슈 참조 (종료하지 않음)
Refs #123
Related to #456
```

### 6.2 Breaking Changes

```
feat(api): 사진 API 응답 형식 변경

BREAKING CHANGE: 사진 API의 응답 형식이 변경되었습니다.
- `image_url` → `thumbnail_url`, `original_url`로 분리
- `date` → `taken_at`으로 이름 변경
```

---

## 7. TDD 워크플로우 커밋

### 7.1 Red-Green-Refactor 사이클

```bash
# RED: 실패하는 테스트 작성
git commit -m "test(photo): 업로드 서비스 테스트 추가 (RED)"

# GREEN: 테스트 통과하는 최소 코드
git commit -m "feat(photo): 업로드 서비스 구현 (GREEN)"

# REFACTOR: 구조 개선
git commit -m "refactor(photo): 업로드 로직 정리"
```

### 7.2 plan.md 연동

```markdown
# plan.md에서 체크박스 업데이트
- [x] **RED**: 업로드 서비스 테스트 ✅ 2025-01-15
- [x] **GREEN**: 업로드 서비스 구현 ✅ 2025-01-15
- [x] **REFACTOR**: 코드 정리 ✅ 2025-01-15
```

---

## 8. 커밋 체크리스트

### 8.1 커밋 전 확인사항

```bash
# 1. 테스트 통과 확인
rails test

# 2. Linter 확인
rubocop

# 3. 타입체크 (Sorbet 사용 시)
srb tc

# 4. 변경 내용 검토
git diff --staged
```

### 8.2 커밋하지 말아야 할 것

- [ ] 테스트가 실패하는 상태
- [ ] 디버그 코드 (puts, binding.pry, debugger)
- [ ] 주석 처리된 코드
- [ ] 환경 변수나 시크릿
- [ ] 구조적 변경과 동작적 변경 혼합

---

## 9. Git 명령어

### 9.1 일상 워크플로우

```bash
# 브랜치 생성
git checkout -b feature/photo-upload

# 변경 사항 스테이징
git add -p                    # 부분적으로 스테이징 (권장)
git add app/services/         # 특정 디렉토리
git add .                     # 전체 (주의해서 사용)

# 커밋
git commit -m "feat(photo): 업로드 서비스 구현"

# 푸시
git push -u origin feature/photo-upload
```

### 9.2 커밋 수정

```bash
# 마지막 커밋 메시지 수정 (푸시 전)
git commit --amend -m "새 메시지"

# 마지막 커밋에 파일 추가 (푸시 전)
git add forgotten_file.rb
git commit --amend --no-edit

# Interactive rebase (푸시 전, 여러 커밋 정리)
git rebase -i HEAD~3
```

### 9.3 커밋 분리

```bash
# 너무 큰 커밋을 분리하고 싶을 때
git reset HEAD~1              # 마지막 커밋 취소 (변경 유지)
git add -p                    # 부분적으로 스테이징
git commit -m "feat: 첫 번째 부분"
git add .
git commit -m "feat: 두 번째 부분"
```

---

## 10. 커밋 메시지 템플릿

### 10.1 설정

```bash
# 템플릿 파일 생성
cat > ~/.gitmessage << 'EOF'
# <type>(<scope>): <subject>
# |<----  50자 이내  ---->|

# 본문 (선택사항)
# |<----  72자에서 줄바꿈  ---->|

# 푸터 (선택사항)
# Closes #이슈번호

# --- 타입 ---
# feat:     새 기능
# fix:      버그 수정
# refactor: 리팩토링
# style:    코드 스타일
# test:     테스트
# docs:     문서
# chore:    빌드/설정
# perf:     성능 개선
EOF

# Git 설정
git config --global commit.template ~/.gitmessage
```

---

## 11. 예시 모음

### 11.1 기능 추가

```
feat(photo): 사진 업로드 기능 구현

- Active Storage Direct Upload 사용
- 병렬 업로드 (동시 3개)
- 진행률 표시 UI

Closes #12
```

### 11.2 버그 수정

```
fix(photo): HEIC 이미지 업로드 실패 수정

iOS에서 촬영한 HEIC 형식 이미지가 업로드되지 않는
문제를 수정함. image_processing gem에서 HEIC를
JPEG로 변환하도록 설정 추가.

Fixes #45
```

### 11.3 리팩토링

```
refactor(photo): 업로드 로직을 서비스 객체로 분리

컨트롤러가 비대해져서 PhotoUploadService로 분리.
테스트 용이성 향상 및 단일 책임 원칙 준수.

- PhotosController#create 단순화
- PhotoUploadService 생성
- 기존 테스트 수정
```

### 11.4 데이터베이스

```
chore(db): photos 테이블에 taken_at 인덱스 추가

월별 조회 쿼리 성능 개선을 위해 복합 인덱스 추가.
기존 쿼리 실행 시간 500ms → 50ms로 개선.
```

### 11.5 의존성

```
chore(deps): Rails 8.1.1로 업그레이드

- Gemfile 업데이트
- 새 기본값 적용
- 테스트 수정
```

---

## 12. 참고 자료

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Kent Beck - Tidy First?](https://www.oreilly.com/library/view/tidy-first/9781098151232/)
