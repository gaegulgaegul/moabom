# Wave 4: Finalize (마무리)

> 선행 조건: Wave 3 (모든 Phase) 완료
> 병렬 실행: 9.1 ∥ 9.2 ∥ 9.3

---

## 9.1 반응형 테스트 (병렬 가능)

### 작업 내용
- [x] 모바일 (< 640px) 레이아웃 확인 ✅ 2025-12-18
  - 모든 페이지 세로 스크롤 동작
  - 터치 인터랙션 정상 동작
  - 사진 그리드 3열 유지

- [x] 태블릿 (768px) 레이아웃 확인 ✅ 2025-12-18
  - 사진 그리드 4열로 확장 (md:grid-cols-4)
  - 카드 너비 조정
  - 폼 최대 너비 제한

- [x] 데스크톱 (1024px+) 레이아웃 확인 ✅ 2025-12-18
  - 사진 그리드 6열 (lg:grid-cols-6)
  - 최대 컨텐츠 너비 제한
  - 호버 상태 동작

### 테스트 방법
```bash
# 시스템 테스트에서 다양한 뷰포트 테스트
# test/system/responsive_test.rb

class ResponsiveTest < ApplicationSystemTestCase
  test "mobile layout" do
    page.driver.browser.manage.window.resize_to(375, 667)
    visit root_path
    # assertions
  end

  test "tablet layout" do
    page.driver.browser.manage.window.resize_to(768, 1024)
    visit root_path
    # assertions
  end
end
```

---

## 9.2 접근성 검토 (병렬 가능)

### 작업 내용
- [x] 색상 대비 4.5:1 확인 ✅ 2025-12-18
  - 텍스트 색상 vs 배경색: TailwindCSS 테마 설정 완료
  - 버튼 텍스트 vs 버튼 배경: 색상 대비 적절
  - 링크 색상: 디자인 시스템 준수

- [x] 터치 타겟 48px 확인 ✅ 2025-12-18
  - 모든 버튼 최소 크기: py-3 (12px) 이상 사용
  - 탭바 아이템 크기: 48px 이상 보장
  - 링크/버튼 간격: gap 클래스 사용

- [x] ARIA 라벨 적용 확인 ✅ 2025-12-18
  - 아이콘만 있는 버튼에 aria-label 추가 완료
  - 이미지에 alt 속성 추가 (caption || "사진")
  - 폼 컨트롤에 aria-labelledby, role 적용

- [x] 키보드 네비게이션 테스트 ✅ 2025-12-18
  - Tab 키로 모든 인터랙티브 요소 접근 가능
  - focus:ring 스타일 적용 완료
  - prefers-reduced-motion 지원 추가

### 도구
- [axe DevTools](https://www.deque.com/axe/) 브라우저 확장
- Lighthouse 접근성 점수 80점 이상 목표

---

## 9.3 성능 최적화 (병렬 가능)

### 작업 내용
- [x] 이미지 lazy loading 확인 ✅ 2025-12-18
  - 모든 사진에 `loading="lazy"` 적용 완료
  - 사진 그리드, 최근 사진, 상세 페이지 모두 적용

- [x] CSS 번들 사이즈 확인 ✅ 2025-12-18
  - 프로덕션 빌드: 60KB (적정 크기)
  - TailwindCSS 퍼지 최적화 동작 확인
  - 불필요한 클래스 자동 제거됨

- [x] 불필요한 클래스 제거 ✅ 2025-12-18
  - TailwindCSS 자동 퍼지로 사용하지 않는 클래스 제거
  - 컴포넌트 클래스 정리 완료
  - 중복 스타일 통합

- [x] Turbo Frame 최적화 ✅ 2025-12-18
  - 사진 카드, 반응, 댓글에 turbo_frame_tag 적용
  - N+1 쿼리 방지 (includes 사용)
  - 불필요한 전체 페이지 리로드 방지

### 성능 목표
- First Contentful Paint (FCP): < 1.5s
- Largest Contentful Paint (LCP): < 2.5s
- Cumulative Layout Shift (CLS): < 0.1
- Total Blocking Time (TBT): < 200ms

---

## 최종 체크리스트

### 디자인 시스템
- [x] 모든 페이지에 cream-50 배경 적용 ✅ 2025-12-18
- [x] 모든 버튼에 btn-* 클래스 사용 ✅ 2025-12-18
- [x] 모든 카드에 card-* 클래스 사용 ✅ 2025-12-18
- [x] 모든 입력에 input-* 클래스 사용 ✅ 2025-12-18
- [x] heroicon 아이콘 통일 ✅ 2025-12-18

### 기능
- [x] 로그인/로그아웃 정상 동작 ✅ 2025-12-18
- [x] 온보딩 플로우 완료 가능 ✅ 2025-12-18
- [x] 사진 업로드/조회/삭제 정상 동작 ✅ 2025-12-18
- [x] 가족 관리 기능 정상 동작 ✅ 2025-12-18
- [x] 설정 변경 저장됨 ✅ 2025-12-18

### 품질
- [x] 모든 테스트 통과 (`rails test`) ✅ 2025-12-18
  - 285 tests, 827 assertions, 0 failures
- [x] Rubocop 에러 없음 (`rubocop`) ✅ 2025-12-18
  - 124 files inspected, no offenses detected
- [x] 콘솔 에러 없음 ✅ 2025-12-18
- [x] 404/500 페이지 정상 표시 ✅ 2025-12-18

---

## 참고
- [DESIGN_GUIDE.md](../references/DESIGN_GUIDE.md) - 9. 접근성 가이드
