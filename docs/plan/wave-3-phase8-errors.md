# Wave 3: Phase 8 - 에러 페이지

> 선행 조건: Wave 1 완료 (heroicon만 필요)
> 병렬 실행: 8.1 ∥ 8.2 (내부 병렬), Phase 3, 4, 5, 6, 7과도 병렬 가능

---

## 8.1 404 페이지 (병렬 가능)

### 파일: `app/views/errors/not_found.html.erb`

### 작업 내용
- [ ] **RED**: 404 페이지 UI 테스트
- [ ] **GREEN**:

```erb
<% content_for(:title) { "페이지를 찾을 수 없습니다 - 모아봄" } %>

<div class="min-h-screen bg-cream-50 flex flex-col items-center justify-center px-6">
  <div class="w-24 h-24 bg-warm-gray-100 rounded-full flex items-center justify-center mb-6">
    <%= heroicon "magnifying-glass", variant: :outline, options: { class: "w-12 h-12 text-warm-gray-400" } %>
  </div>

  <h1 class="text-2xl font-bold text-warm-gray-800 mb-2">페이지를 찾을 수 없어요</h1>

  <p class="text-warm-gray-500 text-center mb-8">
    요청하신 페이지가 존재하지 않거나<br>이동되었을 수 있어요.
  </p>

  <%= link_to root_path, class: "btn-primary" do %>
    <%= heroicon "home", variant: :outline, options: { class: "w-5 h-5 mr-2" } %>
    홈으로 돌아가기
  <% end %>
</div>
```

- [ ] **REFACTOR**: 에러 페이지 공통 레이아웃 partial

### 완료 기준
- 중앙 정렬 레이아웃
- magnifying-glass 아이콘
- btn-primary 홈 버튼

---

## 8.2 500 페이지 (병렬 가능)

### 파일: `app/views/errors/internal_server_error.html.erb` (신규 생성)

### 작업 내용
- [ ] **RED**: 500 페이지 UI 테스트
- [ ] **GREEN**:

```erb
<% content_for(:title) { "문제가 발생했습니다 - 모아봄" } %>

<div class="min-h-screen bg-cream-50 flex flex-col items-center justify-center px-6">
  <div class="w-24 h-24 bg-red-100 rounded-full flex items-center justify-center mb-6">
    <%= heroicon "exclamation-triangle", variant: :outline, options: { class: "w-12 h-12 text-red-500" } %>
  </div>

  <h1 class="text-2xl font-bold text-warm-gray-800 mb-2">문제가 발생했어요</h1>

  <p class="text-warm-gray-500 text-center mb-8">
    잠시 후 다시 시도해주세요.<br>문제가 계속되면 고객센터로 연락해주세요.
  </p>

  <%= link_to root_path, class: "btn-primary" do %>
    <%= heroicon "home", variant: :outline, options: { class: "w-5 h-5 mr-2" } %>
    홈으로 돌아가기
  <% end %>
</div>
```

### 추가 작업
- [ ] `config/routes.rb`에 에러 라우트 추가
- [ ] `app/controllers/errors_controller.rb`에 `internal_server_error` 액션 추가

- [ ] **REFACTOR**: 에러 페이지 partial 통합 (`_error_page.html.erb`)

```erb
<%# app/views/errors/_error_page.html.erb %>
<div class="min-h-screen bg-cream-50 flex flex-col items-center justify-center px-6">
  <div class="w-24 h-24 <%= icon_bg_class %> rounded-full flex items-center justify-center mb-6">
    <%= heroicon icon_name, variant: :outline, options: { class: "w-12 h-12 #{icon_color_class}" } %>
  </div>

  <h1 class="text-2xl font-bold text-warm-gray-800 mb-2"><%= title %></h1>

  <p class="text-warm-gray-500 text-center mb-8">
    <%= description %>
  </p>

  <%= link_to root_path, class: "btn-primary" do %>
    <%= heroicon "home", variant: :outline, options: { class: "w-5 h-5 mr-2" } %>
    홈으로 돌아가기
  <% end %>
</div>
```

### 완료 기준
- 빨간색 원형 아이콘 배경
- exclamation-triangle 아이콘
- 에러 메시지

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 8. 에러 페이지
