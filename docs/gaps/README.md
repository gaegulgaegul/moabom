# 구현 현황 분석 (Implementation Gaps)

> 작업별 갭 분석 결과를 관리하는 폴더입니다.

---

## 폴더 구조

각 작업/Phase별로 하위 폴더가 생성됩니다:

```
docs/gaps/
├── README.md                    # 이 파일 (인덱스)
├── phase-4/                     # Phase 4 완료 시점 분석
│   ├── README.md
│   ├── intentional-simplifications.md
│   ├── temporary-implementations.md
│   ├── not-implemented.md
│   ├── hardcoded-values.md
│   └── missing-error-handling.md
└── [작업명]/                    # 이후 추가되는 분석
    └── ...
```

---

## 분석 목록

| 작업명 | 분석일 | P0 | P1 | P2 | 합계 |
|-------|--------|----|----|----|----|
| [phase-4](./phase-4/) | 2025-12-14 | 5 | 13 | 11 | 29 |

---

## 카테고리 설명

| 파일명 | 설명 |
|-------|------|
| `intentional-simplifications.md` | MVP 범위로 축소한 기능 |
| `temporary-implementations.md` | 나중에 개선이 필요한 코드 |
| `not-implemented.md` | 건너뛴 기능이나 테스트 |
| `hardcoded-values.md` | 설정값이나 상수로 분리해야 할 부분 |
| `missing-error-handling.md` | 예외 상황 처리가 부족한 부분 |

---

## 우선순위 정의

- **P0 (즉시)**: 보안 이슈, 데이터 손실 위험, 핵심 기능 차단
- **P1 (다음 스프린트)**: MVP 출시 전 필수, 사용자 경험 영향
- **P2 (백로그)**: 출시 후 개선, 기술 부채

---

## 새 분석 추가하기

```bash
# 1. 폴더 생성
mkdir -p docs/gaps/[작업명]

# 2. 프롬프트 사용
# @docs/prompt/gap-scan.md 참고
```
