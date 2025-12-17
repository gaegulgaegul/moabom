# Wave 3: Phase 3 - 로그인/온보딩

> 실행 순서: 3.1 → (3.2 ∥ 3.3 ∥ 3.4)
> 선행 조건: Wave 2 완료
> 병렬 실행: Phase 4, 5, 6, 7, 8과 병렬 가능 (단, 3.1과 Phase 4는 파일 충돌 주의)

---

## 3.1 홈 화면 - 비로그인 상태 (home/index.html.erb)

### 주의사항
**Phase 4 (대시보드)와 같은 파일을 수정하므로, Phase 4와 순차 진행 필요**

### 작업 내용
- [x] **RED**: 로그인 페이지 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: 디자인 시스템 적용한 로그인 페이지 구현 ✅ 2025-12-17

```erb
<% unless logged_in? %>
  <div class="min-h-screen bg-gradient-warm flex flex-col">
    <!-- 상단 여백 -->
    <div class="flex-1 flex flex-col items-center justify-center px-6 pt-20">
      <!-- 로고/일러스트 영역 -->
      <div class="w-32 h-32 mb-8 bg-primary-100 rounded-full flex items-center justify-center">
        <span class="text-6xl">🌸</span>
      </div>

      <!-- 타이틀 -->
      <h1 class="text-2xl font-bold text-warm-gray-800 text-center mb-2">
        우리 아이의 소중한 순간,
      </h1>
      <p class="text-lg text-warm-gray-600 text-center mb-12">
        가족과 함께 모아봄
      </p>
    </div>

    <!-- 로그인 버튼 영역 -->
    <div class="px-6 pb-12 space-y-3">
      <!-- Apple 로그인 -->
      <a href="#" class="flex items-center justify-center gap-3 w-full py-4
                         bg-black text-white rounded-2xl font-medium
                         opacity-50 cursor-not-allowed">
        Apple로 계속하기
      </a>

      <!-- 카카오 로그인 -->
      <%= link_to "/auth/kakao", class: "flex items-center justify-center gap-3 w-full py-4
                                          bg-[#FEE500] text-warm-gray-900 rounded-2xl font-medium
                                          hover:bg-yellow-400 transition-colors" do %>
        💬 카카오로 계속하기
      <% end %>

      <!-- Google 로그인 -->
      <a href="#" class="card-glass flex items-center justify-center gap-3 w-full py-4
                         rounded-2xl font-medium text-warm-gray-700
                         opacity-50 cursor-not-allowed">
        Google로 계속하기
      </a>

      <!-- 약관 -->
      <p class="text-xs text-warm-gray-400 text-center pt-4">
        로그인 시 <a href="#" class="underline">이용약관</a> 및
        <a href="#" class="underline">개인정보 처리방침</a>에 동의하게 됩니다.
      </p>

      <% if Rails.env.development? %>
        <div class="pt-4 border-t border-warm-gray-200">
          <%= button_to "🚀 개발 모드로 빠른 진입", dev_login_path, method: :post,
              class: "w-full bg-purple-600 text-white py-3 rounded-2xl font-medium hover:bg-purple-700" %>
        </div>
      <% end %>
    </div>
  </div>
<% else %>
  <!-- Phase 4에서 구현 -->
<% end %>
```

- [x] **REFACTOR**: 버튼 공통 스타일 추출 (.btn-kakao, .btn-apple, .btn-google) ✅ 2025-12-17

### 완료 기준
- bg-gradient-warm 배경
- rounded-2xl 버튼
- 카카오 노란색 (#FEE500)

---

## 3.2 온보딩 - 프로필 설정 (병렬 가능)

### 파일: `app/views/onboarding/profiles/show.html.erb`

### 작업 내용
- [x] **RED**: 프로필 폼 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: Fixed 전체 화면 레이아웃 구현 (z-[100]) ✅ 2025-12-17

```erb
<div class="min-h-screen bg-cream-50 flex flex-col">
  <!-- 헤더 -->
  <header class="flex items-center justify-between px-4 h-14">
    <button onclick="history.back()" class="p-2">
      <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
    </button>
    <span class="text-lg font-semibold text-warm-gray-800">모아봄</span>
    <div class="flex gap-1">
      <span class="w-2 h-2 rounded-full bg-primary-500"></span>
      <span class="w-2 h-2 rounded-full bg-warm-gray-300"></span>
      <span class="w-2 h-2 rounded-full bg-warm-gray-300"></span>
    </div>
  </header>

  <!-- 컨텐츠 -->
  <div class="flex-1 px-6 py-8">
    <div class="w-20 h-20 mx-auto mb-6 bg-primary-100 rounded-full flex items-center justify-center">
      <%= heroicon "user-circle", variant: :outline, options: { class: "w-10 h-10 text-primary-500" } %>
    </div>

    <h1 class="text-2xl font-bold text-warm-gray-800 text-center mb-2">
      프로필을 설정해주세요
    </h1>
    <p class="text-warm-gray-500 text-center mb-8">
      가족들에게 보여질 이름이에요
    </p>

    <%= form_with model: current_user, url: onboarding_profile_path, method: :patch, class: "space-y-4" do |form| %>
      <% if current_user.errors.any? %>
        <div class="alert-error">
          <% current_user.errors.full_messages.each do |message| %>
            <p class="text-sm"><%= message %></p>
          <% end %>
        </div>
      <% end %>

      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">닉네임</label>
        <%= form.text_field :nickname, placeholder: "예: 엄마, 아빠, 할머니", class: "input-text" %>
      </div>
    <% end %>
  </div>

  <!-- 하단 버튼 -->
  <div class="px-6 pb-8">
    <%= form.submit "다음", class: "btn-primary w-full" %>
  </div>
</div>
```

- [x] **REFACTOR**: 온보딩 공통 레이아웃 partial 추출 (app/views/onboarding/_header.html.erb) ✅ 2025-12-17

---

## 3.3 온보딩 - 아이 등록 (병렬 가능)

### 파일: `app/views/onboarding/children/show.html.erb`

### 작업 내용
- [x] **RED**: 아이 등록 폼 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: Fixed 전체 화면 레이아웃 구현 (z-[100], local: true 폼) ✅ 2025-12-17

```erb
<div class="min-h-screen bg-cream-50 flex flex-col">
  <!-- 헤더 (진행률 2/3) -->
  <header class="flex items-center justify-between px-4 h-14">
    <button onclick="history.back()" class="p-2">
      <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
    </button>
    <span class="text-lg font-semibold text-warm-gray-800">모아봄</span>
    <div class="flex gap-1">
      <span class="w-2 h-2 rounded-full bg-warm-gray-300"></span>
      <span class="w-2 h-2 rounded-full bg-primary-500"></span>
      <span class="w-2 h-2 rounded-full bg-warm-gray-300"></span>
    </div>
  </header>

  <div class="flex-1 px-6 py-8">
    <div class="w-20 h-20 mx-auto mb-6 bg-secondary-100 rounded-full flex items-center justify-center">
      <%= heroicon "face-smile", variant: :outline, options: { class: "w-10 h-10 text-secondary-500" } %>
    </div>

    <h1 class="text-2xl font-bold text-warm-gray-800 text-center mb-2">
      아이 정보를 등록해주세요
    </h1>
    <p class="text-warm-gray-500 text-center mb-8">
      성장 기록의 주인공이에요
    </p>

    <%= form_with model: @child, url: onboarding_child_path, method: :post, class: "space-y-4" do |form| %>
      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">이름</label>
        <%= form.text_field :name, placeholder: "아이 이름", class: "input-text" %>
      </div>

      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">생년월일</label>
        <%= form.date_field :birthdate, class: "input-text" %>
      </div>

      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">성별</label>
        <div class="flex gap-3">
          <button type="button" class="flex-1 py-3 rounded-xl border-2
                                        border-primary-500 bg-primary-50 text-primary-700 font-medium"
                  data-gender="female">
            여아
          </button>
          <button type="button" class="flex-1 py-3 rounded-xl border-2
                                        border-warm-gray-200 text-warm-gray-500 font-medium"
                  data-gender="male">
            남아
          </button>
        </div>
        <%= form.hidden_field :gender %>
      </div>
    <% end %>
  </div>

  <div class="px-6 pb-8 space-y-3">
    <%= form.submit "다음", class: "btn-primary w-full" %>
    <button type="button" class="text-warm-gray-400 text-sm w-full py-2">나중에 할게요</button>
  </div>
</div>
```

- [x] **REFACTOR**: 버튼 그룹은 단일 사용으로 컴포넌트화 불필요 (YAGNI 원칙) ✅ 2025-12-17

---

## 3.4 온보딩 - 가족 초대 (병렬 가능)

### 파일: `app/views/onboarding/invites/show.html.erb`

### 작업 내용
- [x] **RED**: 초대 페이지 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: Fixed 전체 화면 레이아웃 구현 (z-[100]) ✅ 2025-12-17

```erb
<div class="min-h-screen bg-cream-50 flex flex-col">
  <!-- 헤더 (진행률 3/3) -->
  <header class="flex items-center justify-between px-4 h-14">
    <button onclick="history.back()" class="p-2">
      <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
    </button>
    <span class="text-lg font-semibold text-warm-gray-800">모아봄</span>
    <div class="flex gap-1">
      <span class="w-2 h-2 rounded-full bg-warm-gray-300"></span>
      <span class="w-2 h-2 rounded-full bg-warm-gray-300"></span>
      <span class="w-2 h-2 rounded-full bg-primary-500"></span>
    </div>
  </header>

  <div class="flex-1 px-6 py-8">
    <div class="w-20 h-20 mx-auto mb-6 bg-accent-100 rounded-full flex items-center justify-center">
      <%= heroicon "user-group", variant: :outline, options: { class: "w-10 h-10 text-accent-500" } %>
    </div>

    <h1 class="text-2xl font-bold text-warm-gray-800 text-center mb-2">
      가족을 초대해보세요
    </h1>
    <p class="text-warm-gray-500 text-center mb-8">
      함께 추억을 공유할 수 있어요
    </p>

    <!-- 초대 링크 카드 -->
    <div class="card-glass">
      <p class="text-sm text-warm-gray-500 mb-3">초대 링크</p>
      <div class="flex items-center gap-2">
        <input type="text" value="moabom.app/i/<%= @invite_token %>" readonly
               class="input-text flex-1 text-sm">
        <button class="btn-primary btn-sm shrink-0" data-action="click->clipboard#copy">
          <%= heroicon "clipboard-document", variant: :outline, options: { class: "w-5 h-5" } %>
        </button>
      </div>
    </div>

    <!-- 공유 버튼들 -->
    <div class="flex justify-center gap-4 mt-6">
      <button class="flex flex-col items-center gap-2">
        <div class="w-12 h-12 bg-[#FEE500] rounded-full flex items-center justify-center">
          <span class="text-xl">💬</span>
        </div>
        <span class="text-xs text-warm-gray-500">카카오톡</span>
      </button>
      <button class="flex flex-col items-center gap-2">
        <div class="w-12 h-12 bg-warm-gray-200 rounded-full flex items-center justify-center">
          <%= heroicon "link", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-600" } %>
        </div>
        <span class="text-xs text-warm-gray-500">링크 복사</span>
      </button>
    </div>
  </div>

  <div class="px-6 pb-8 space-y-3">
    <%= link_to "시작하기", root_path, class: "btn-primary w-full text-center" %>
    <button type="button" class="text-warm-gray-400 text-sm w-full py-2">나중에 초대할게요</button>
  </div>
</div>
```

- [x] **REFACTOR**: 공유 버튼은 단일 사용으로 partial 추출 불필요 (YAGNI 원칙) ✅ 2025-12-17

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 2. 홈 화면, 3. 온보딩 플로우
