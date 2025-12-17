# Wave 3: Phase 7 - 설정

> 선행 조건: Wave 2 완료
> 병렬 실행: 7.1 ∥ 7.2 (내부 병렬), Phase 3, 4, 5, 6, 8과도 병렬 가능

---

## 7.1 설정 메인 (병렬 가능)

### 파일: `app/views/settings/profiles/show.html.erb`

### 작업 내용
- [x] **RED**: 설정 페이지 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: 설정 페이지 뷰 구현 ✅ 2025-12-17

```erb
<div class="px-4 py-6 space-y-6">
  <h1 class="text-xl font-bold text-warm-gray-800">설정</h1>

  <!-- 계정 설정 -->
  <div class="card-solid divide-y divide-warm-gray-100">
    <%= link_to "#", class: "flex items-center justify-between py-4 tap-highlight-none" do %>
      <div class="flex items-center gap-3">
        <%= heroicon "user-circle", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">프로필 설정</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    <% end %>

    <%= link_to settings_notifications_path, class: "flex items-center justify-between py-4 tap-highlight-none" do %>
      <div class="flex items-center gap-3">
        <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">알림 설정</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    <% end %>

    <div class="flex items-center justify-between py-4">
      <div class="flex items-center gap-3">
        <%= heroicon "moon", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">다크 모드</span>
      </div>
      <!-- Toggle Switch -->
      <button class="w-12 h-7 bg-warm-gray-200 rounded-full relative transition-colors"
              data-controller="toggle"
              data-action="click->toggle#toggle">
        <span class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full shadow transition-transform"
              data-toggle-target="knob"></span>
      </button>
    </div>
  </div>

  <!-- 프로필 수정 폼 -->
  <div class="card-solid">
    <h2 class="text-lg font-semibold text-warm-gray-800 mb-4">프로필 정보</h2>

    <%= form_with model: current_user, url: settings_profile_path, method: :patch, class: "space-y-4" do |form| %>
      <% if current_user.errors.any? %>
        <div class="alert-error">
          <% current_user.errors.full_messages.each do |message| %>
            <p class="text-sm"><%= message %></p>
          <% end %>
        </div>
      <% end %>

      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">이메일</label>
        <%= form.email_field :email, disabled: true, class: "input-text bg-warm-gray-100 cursor-not-allowed" %>
        <p class="text-xs text-warm-gray-400 mt-1">이메일은 변경할 수 없습니다</p>
      </div>

      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">닉네임</label>
        <%= form.text_field :nickname, class: "input-text" %>
      </div>

      <%= form.submit "저장", class: "btn-primary w-full" %>
    <% end %>
  </div>

  <!-- 정보 -->
  <div class="card-solid divide-y divide-warm-gray-100">
    <%= link_to "#", class: "flex items-center justify-between py-4 tap-highlight-none" do %>
      <div class="flex items-center gap-3">
        <%= heroicon "document-text", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">이용약관</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    <% end %>

    <%= link_to "#", class: "flex items-center justify-between py-4 tap-highlight-none" do %>
      <div class="flex items-center gap-3">
        <%= heroicon "shield-check", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">개인정보 처리방침</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    <% end %>

    <%= link_to "#", class: "flex items-center justify-between py-4 tap-highlight-none" do %>
      <div class="flex items-center gap-3">
        <%= heroicon "information-circle", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">앱 정보</span>
      </div>
      <span class="text-sm text-warm-gray-400">v1.0.0</span>
    <% end %>
  </div>

  <!-- 로그아웃 -->
  <div class="card-solid">
    <%= button_to logout_path, method: :delete, class: "flex items-center gap-3 py-4 w-full tap-highlight-none" do %>
      <%= heroicon "arrow-right-on-rectangle", variant: :outline, options: { class: "w-6 h-6 text-red-500" } %>
      <span class="text-red-500">로그아웃</span>
    <% end %>
  </div>
</div>
```

- [x] **REFACTOR**: 설정 아이템 partial (`_setting_item.html.erb`) ✅ 2025-12-17

### 완료 기준
- card-solid 그룹 카드
- heroicon 아이콘
- 토글 스위치
- 로그아웃 버튼 (text-red-500)

---

## 7.2 알림 설정 (병렬 가능)

### 파일: `app/views/settings/notifications/show.html.erb`

### 작업 내용
- [x] **RED**: 알림 설정 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: 알림 설정 뷰 구현 ✅ 2025-12-17

```erb
<div class="px-4 py-6 space-y-6">
  <!-- 헤더 -->
  <div class="flex items-center gap-4">
    <button onclick="history.back()" class="p-2 -ml-2">
      <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
    </button>
    <h1 class="text-xl font-bold text-warm-gray-800">알림 설정</h1>
  </div>

  <!-- 알림 설정 목록 -->
  <div class="card-solid divide-y divide-warm-gray-100">
    <div class="flex items-center justify-between py-4">
      <div>
        <p class="text-warm-gray-800 font-medium">새 사진 알림</p>
        <p class="text-sm text-warm-gray-500">가족이 새 사진을 올리면 알려드려요</p>
      </div>
      <button class="w-12 h-7 bg-primary-500 rounded-full relative transition-colors"
              data-controller="toggle" data-toggle-active="true">
        <span class="absolute right-1 top-1 w-5 h-5 bg-white rounded-full shadow transition-transform"
              data-toggle-target="knob"></span>
      </button>
    </div>

    <div class="flex items-center justify-between py-4">
      <div>
        <p class="text-warm-gray-800 font-medium">댓글 알림</p>
        <p class="text-sm text-warm-gray-500">내 사진에 댓글이 달리면 알려드려요</p>
      </div>
      <button class="w-12 h-7 bg-primary-500 rounded-full relative transition-colors"
              data-controller="toggle" data-toggle-active="true">
        <span class="absolute right-1 top-1 w-5 h-5 bg-white rounded-full shadow transition-transform"
              data-toggle-target="knob"></span>
      </button>
    </div>

    <div class="flex items-center justify-between py-4">
      <div>
        <p class="text-warm-gray-800 font-medium">반응 알림</p>
        <p class="text-sm text-warm-gray-500">내 사진에 반응이 달리면 알려드려요</p>
      </div>
      <button class="w-12 h-7 bg-warm-gray-200 rounded-full relative transition-colors"
              data-controller="toggle">
        <span class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full shadow transition-transform"
              data-toggle-target="knob"></span>
      </button>
    </div>

    <div class="flex items-center justify-between py-4">
      <div>
        <p class="text-warm-gray-800 font-medium">가족 초대 알림</p>
        <p class="text-sm text-warm-gray-500">새 가족이 참여하면 알려드려요</p>
      </div>
      <button class="w-12 h-7 bg-primary-500 rounded-full relative transition-colors"
              data-controller="toggle" data-toggle-active="true">
        <span class="absolute right-1 top-1 w-5 h-5 bg-white rounded-full shadow transition-transform"
              data-toggle-target="knob"></span>
      </button>
    </div>
  </div>
</div>
```

- [x] **REFACTOR**: 토글 컴포넌트 추출 (`toggle_controller.js`) ✅ 2025-12-17

### 완료 기준
- 토글 스위치 ON/OFF 상태
- 설정 항목 설명 텍스트
- 뒤로 가기 버튼

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 7. 설정
