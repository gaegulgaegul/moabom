# Wave 4: Finalize (마무리)

> 선행 조건: Wave 3 (모든 Phase) 완료
> 병렬 실행: 9.1 ∥ 9.2 ∥ 9.3

---

## 9.1 반응형 테스트 (병렬 가능)

### 작업 내용
- [ ] 모바일 (< 640px) 레이아웃 확인
  - 모든 페이지 세로 스크롤 동작
  - 터치 인터랙션 정상 동작
  - 사진 그리드 3열 유지

- [ ] 태블릿 (768px) 레이아웃 확인
  - 사진 그리드 4열로 확장
  - 카드 너비 조정
  - 폼 최대 너비 제한

- [ ] 데스크톱 (1024px+) 레이아웃 확인
  - 사이드바 레이아웃 고려
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
- [ ] 색상 대비 4.5:1 확인
  - 텍스트 색상 vs 배경색
  - 버튼 텍스트 vs 버튼 배경
  - 링크 색상

- [ ] 터치 타겟 48px 확인
  - 모든 버튼 최소 크기
  - 탭바 아이템 크기
  - 링크/버튼 간격

- [ ] ARIA 라벨 적용 확인
  ```erb
  <%# 아이콘만 있는 버튼에 aria-label %>
  <button aria-label="사진 업로드">
    <%= heroicon "plus", variant: :solid %>
  </button>

  <%# 이미지에 적절한 alt %>
  <%= image_tag photo.image, alt: photo.caption || "사진" %>
  ```

- [ ] 키보드 네비게이션 테스트
  - Tab 키로 모든 인터랙티브 요소 접근 가능
  - Enter/Space로 버튼 동작
  - Escape로 모달 닫기

### 도구
- [axe DevTools](https://www.deque.com/axe/) 브라우저 확장
- Lighthouse 접근성 점수 80점 이상 목표

---

## 9.3 성능 최적화 (병렬 가능)

### 작업 내용
- [ ] 이미지 lazy loading 확인
  ```erb
  <%= image_tag photo.image, loading: "lazy" %>
  ```

- [ ] CSS 번들 사이즈 확인
  ```bash
  # 프로덕션 빌드 후 사이즈 확인
  rails tailwindcss:build
  ls -la app/assets/builds/
  ```

- [ ] 불필요한 클래스 제거
  - 사용하지 않는 컴포넌트 클래스 정리
  - 중복 스타일 통합

- [ ] Turbo Frame 최적화
  - 적절한 영역에 turbo_frame_tag 적용
  - 불필요한 전체 페이지 리로드 방지

### 성능 목표
- First Contentful Paint (FCP): < 1.5s
- Largest Contentful Paint (LCP): < 2.5s
- Cumulative Layout Shift (CLS): < 0.1
- Total Blocking Time (TBT): < 200ms

---

## 최종 체크리스트

### 디자인 시스템
- [ ] 모든 페이지에 cream-50 배경 적용
- [ ] 모든 버튼에 btn-* 클래스 사용
- [ ] 모든 카드에 card-* 클래스 사용
- [ ] 모든 입력에 input-* 클래스 사용
- [ ] heroicon 아이콘 통일

### 기능
- [ ] 로그인/로그아웃 정상 동작
- [ ] 온보딩 플로우 완료 가능
- [ ] 사진 업로드/조회/삭제 정상 동작
- [ ] 가족 관리 기능 정상 동작
- [ ] 설정 변경 저장됨

### 품질
- [ ] 모든 테스트 통과 (`rails test`)
- [ ] Rubocop 에러 없음 (`rubocop`)
- [ ] 콘솔 에러 없음
- [ ] 404/500 페이지 정상 표시

---

## 참고
- [DESIGN_GUIDE.md](../references/DESIGN_GUIDE.md) - 9. 접근성 가이드
