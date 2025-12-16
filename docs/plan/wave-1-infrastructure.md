# Wave 1: Infrastructure (기반 설정)

> 병렬 실행: 1.1 ∥ 1.2
> 선행 조건: 없음
> 후속 작업: Wave 2

---

## 1.1 Heroicons gem 설치 및 설정

### 작업 내용
- [ ] **RED**: heroicon helper 사용 테스트 작성
  ```ruby
  # test/helpers/heroicon_helper_test.rb
  test "heroicon helper renders svg" do
    # heroicon "home" 호출 시 SVG 반환 확인
  end
  ```
- [ ] **GREEN**: Gemfile에 heroicon gem 추가 및 설치
  ```ruby
  # Gemfile
  gem "heroicon"
  ```
  ```bash
  bundle install
  ```
- [ ] **REFACTOR**: 필요시 설정 조정

### 완료 기준
- `<%= heroicon "home", variant: :outline %>` 호출 시 SVG 렌더링
- 테스트 통과

---

## 1.2 TailwindCSS 보완

### 작업 내용
- [ ] **RED**: 누락된 컴포넌트 클래스 테스트
- [ ] **GREEN**: `app/assets/tailwind/application.css`에 추가
  - tab-item, tab-item-active 클래스
  - bg-gradient-warm 그라디언트 확인
  - 다크 모드 변수 준비

```css
@layer components {
  /* 탭 아이템 */
  .tab-item {
    @apply flex flex-col items-center justify-center py-2 px-4
           text-warm-gray-500
           transition-colors duration-200
           tap-highlight-none;
  }

  .tab-item-active {
    @apply text-primary-500;
  }
}
```

- [ ] **REFACTOR**: 클래스 정리 및 최적화

### 완료 기준
- 모든 디자인 시스템 클래스 사용 가능
- `rails tailwindcss:build` 성공

---

## 참고
- [DESIGN_GUIDE.md](../references/DESIGN_GUIDE.md)
- [design-system.md](../../.claude/rules/design-system.md)
