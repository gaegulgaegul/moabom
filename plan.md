# Wave 2: Shared Layout (공통 레이아웃)

> 실행 순서: 2.1 → (2.2 ∥ 2.3)
> 선행 조건: Wave 1 완료
> 후속 작업: Wave 3

---

## 2.1 application.html.erb 레이아웃 개선 (순차)

### 작업 내용
- [x] **RED**: 레이아웃 구조 테스트 (시스템 테스트) ✅ 2025-12-16
- [x] **GREEN**: ✅ 2025-12-16
  - body에 `bg-cream-50` 적용
  - main 영역 `pt-14 pb-20` 적용
  - flash 메시지 디자인 시스템 적용

```erb
<body class="bg-cream-50 dark:bg-warm-gray-900">
  <%= render "shared/header" %>

  <main class="<%= logged_in? ? 'pt-14 pb-20' : 'pt-14' %> min-h-screen">
    <% if flash[:notice] %>
      <div class="alert-success flex items-center gap-3 mx-4 mt-4">
        <%= heroicon "check-circle", variant: :solid, options: { class: "w-5 h-5 text-emerald-600 shrink-0" } %>
        <p class="text-sm"><%= flash[:notice] %></p>
      </div>
    <% end %>

    <% if flash[:alert] %>
      <div class="alert-error flex items-center gap-3 mx-4 mt-4">
        <%= heroicon "exclamation-circle", variant: :solid, options: { class: "w-5 h-5 text-red-600 shrink-0" } %>
        <p class="text-sm"><%= flash[:alert] %></p>
      </div>
    <% end %>

    <%= yield %>
  </main>

  <%= render "shared/tabbar" if logged_in? %>
</body>
```

- [x] **REFACTOR**: 중복 코드 제거 ✅ 2025-12-16 (중복 없음)

### 완료 기준
- ✅ cream-50 배경색 적용됨
- ✅ flash 메시지 스타일링 완료

---

## 2.2 Header (_header.html.erb) 재디자인 (병렬 가능)

### 작업 내용
- [x] **RED**: 헤더 렌더링 테스트 ✅ 2025-12-16
- [x] **GREEN**: ✅ 2025-12-16

```erb
<header class="fixed top-0 left-0 right-0 z-50
               bg-white/80 backdrop-blur-md
               border-b border-cream-200
               safe-area-inset-top">
  <div class="flex items-center justify-between px-4 h-14">
    <!-- 로고 -->
    <%= link_to root_path, class: "flex items-center gap-2" do %>
      <span class="text-2xl">🌸</span>
      <span class="text-lg font-bold text-warm-gray-800">모아봄</span>
    <% end %>

    <!-- 우측 액션 -->
    <div class="flex items-center gap-3">
      <% if logged_in? %>
        <button class="relative p-2 rounded-full hover:bg-cream-100 tap-highlight-none">
          <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
          <span class="absolute top-1 right-1 w-2 h-2 bg-accent-500 rounded-full"></span>
        </button>
      <% end %>
    </div>
  </div>
</header>
```

- [x] **REFACTOR**: 접근성 개선 (aria-label) ✅ 2025-12-16

### 완료 기준
- ✅ glass 효과 적용됨
- ✅ heroicon bell 아이콘 표시
- ✅ 알림 뱃지 표시

---

## 2.3 Tab Bar (_tabbar.html.erb) 재디자인 (병렬 가능)

### 작업 내용
- [x] **RED**: 탭바 렌더링 및 활성 상태 테스트 ✅ 2025-12-16
- [x] **GREEN**: ✅ 2025-12-16

```erb
<nav class="fixed bottom-0 left-0 right-0 z-50
            bg-white/90 backdrop-blur-md
            border-t border-cream-200
            safe-area-inset-bottom">
  <div class="flex items-center justify-around h-16">
    <!-- 홈 -->
    <%= link_to root_path, class: "tab-item #{current_page?(root_path) ? 'tab-item-active' : ''}" do %>
      <%= heroicon "home", variant: current_page?(root_path) ? :solid : :outline, options: { class: "w-6 h-6" } %>
      <span class="text-xs mt-1">홈</span>
    <% end %>

    <!-- 앨범 -->
    <%= link_to "#", class: "tab-item" do %>
      <%= heroicon "photo", variant: :outline, options: { class: "w-6 h-6" } %>
      <span class="text-xs mt-1">앨범</span>
    <% end %>

    <!-- 업로드 (FAB) -->
    <%= link_to "#", class: "flex items-center justify-center -mt-4 tap-highlight-none" do %>
      <div class="w-14 h-14 bg-primary-500 rounded-full flex items-center justify-center
                  shadow-lg shadow-primary-500/30
                  hover:bg-primary-600 active:bg-primary-700
                  transition-colors duration-200">
        <%= heroicon "plus", variant: :solid, options: { class: "w-7 h-7 text-white" } %>
      </div>
    <% end %>

    <!-- 알림 -->
    <%= link_to "#", class: "tab-item" do %>
      <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6" } %>
      <span class="text-xs mt-1">알림</span>
    <% end %>

    <!-- 설정 -->
    <%= link_to settings_profile_path, class: "tab-item #{current_page?(settings_profile_path) ? 'tab-item-active' : ''}" do %>
      <%= heroicon "cog-6-tooth", variant: current_page?(settings_profile_path) ? :solid : :outline, options: { class: "w-6 h-6" } %>
      <span class="text-xs mt-1">설정</span>
    <% end %>
  </div>
</nav>
```

- [x] **REFACTOR**: tab-item 클래스로 통합 ✅ 2025-12-16 (이미 적용됨)

### 완료 기준
- ✅ glass 효과 적용됨
- ✅ heroicon 아이콘 표시
- ✅ 중앙 FAB 버튼 스타일링
- ✅ 활성 탭 하이라이트

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 1. 공통 레이아웃
