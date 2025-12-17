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

---

# Wave 3: Phase 5 - 사진 기능

> 선행 조건: Wave 2 완료
> 병렬 실행: 5.1 ∥ 5.2 ∥ 5.3 (내부 병렬), Phase 3, 4, 6, 7, 8과도 병렬 가능

---

## 5.1 사진 타임라인 (병렬 가능)

### 파일: `app/views/families/photos/index.html.erb`

### 작업 내용
- [x] **RED**: 타임라인 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: ✅ 2025-12-17

```erb
<div class="px-4 py-6">
  <!-- 헤더 -->
  <h1 class="text-xl font-bold text-warm-gray-800 mb-4">사진 타임라인</h1>

  <!-- 필터 탭 -->
  <div class="flex gap-2 mb-6 overflow-x-auto scrollbar-hide -mx-4 px-4">
    <%= link_to family_photos_path(@family),
        class: "shrink-0 px-4 py-2 rounded-full text-sm font-medium
                #{params[:child_id].blank? ? 'bg-primary-500 text-white' : 'bg-cream-100 text-warm-gray-600'}" do %>
      전체
    <% end %>
    <% @family.children.each do |child| %>
      <%= link_to family_photos_path(@family, child_id: child.id),
          class: "shrink-0 px-4 py-2 rounded-full text-sm font-medium
                  #{params[:child_id].to_s == child.id.to_s ? 'bg-primary-500 text-white' : 'bg-cream-100 text-warm-gray-600'}" do %>
        <%= child.name %>
      <% end %>
    <% end %>
  </div>

  <% if @photos.any? %>
    <!-- 월별 그룹 -->
    <% @photos.group_by { |p| p.taken_at.strftime("%Y년 %m월") }.each do |month, photos| %>
      <section class="mb-8">
        <h2 class="text-sm font-semibold text-warm-gray-500 mb-3"><%= month %></h2>

        <!-- 사진 그리드 -->
        <div class="grid grid-cols-3 gap-1">
          <% photos.each do |photo| %>
            <%= link_to family_photo_path(@family, photo),
                class: "aspect-square overflow-hidden rounded-lg" do %>
              <%= image_tag photo.image.variant(:thumbnail),
                  class: "w-full h-full object-cover",
                  loading: "lazy",
                  alt: photo.caption %>
            <% end %>
          <% end %>
        </div>
      </section>
    <% end %>
  <% else %>
    <!-- 빈 상태 -->
    <div class="empty-state">
      <div class="w-20 h-20 bg-cream-100 rounded-full flex items-center justify-center mb-4">
        <%= heroicon "photo", variant: :outline, options: { class: "w-10 h-10 text-warm-gray-400" } %>
      </div>
      <h3 class="text-lg font-medium text-warm-gray-800 mb-2">아직 사진이 없어요</h3>
      <p class="text-warm-gray-500 mb-6">소중한 순간을 가족과 공유해보세요</p>
      <%= link_to new_family_photo_path(@family), class: "btn-primary" do %>
        <%= heroicon "plus", variant: :solid, options: { class: "w-5 h-5 mr-2" } %>
        첫 사진 업로드
      <% end %>
    </div>
  <% end %>
</div>
```

- [x] **REFACTOR**: 사진 그리드 partial 추출 ✅ 2025-12-17

### 완료 기준
- pill 스타일 필터 탭
- 3열 그리드 (gap-1, rounded-lg)
- 월별 그룹핑
- empty-state 디자인

---

## 5.2 사진 상세 (병렬 가능)

### 파일: `app/views/families/photos/show.html.erb`

### 작업 내용
- [x] **RED**: 사진 상세 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: ✅ 2025-12-17

```erb
<div class="min-h-screen bg-warm-gray-900">
  <!-- 투명 헤더 -->
  <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-4 h-14 safe-area-inset-top">
    <button onclick="history.back()" class="p-2 bg-black/30 rounded-full backdrop-blur-sm">
      <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-white" } %>
    </button>
    <button class="p-2 bg-black/30 rounded-full backdrop-blur-sm">
      <%= heroicon "ellipsis-horizontal", variant: :outline, options: { class: "w-6 h-6 text-white" } %>
    </button>
  </header>

  <!-- 사진 -->
  <div class="w-full aspect-square pt-14">
    <% if @photo.image.attached? %>
      <%= image_tag @photo.image, class: "w-full h-full object-contain bg-black", alt: @photo.caption %>
    <% end %>
  </div>

  <!-- 정보 영역 -->
  <div class="bg-white rounded-t-3xl -mt-6 relative z-10 min-h-[50vh]">
    <div class="px-4 py-6">
      <!-- 반응 & 날짜 -->
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-4">
          <%= turbo_frame_tag dom_id(@photo, :reactions) do %>
            <%= render "photos/reactions/reactions", photo: @photo %>
          <% end %>
        </div>
        <span class="text-sm text-warm-gray-400">
          <%= l @photo.taken_at, format: :short if @photo.taken_at %>
        </span>
      </div>

      <!-- 캡션 -->
      <% if @photo.caption.present? %>
        <p class="text-warm-gray-800 mb-6"><%= @photo.caption %></p>
      <% end %>

      <!-- 메타 정보 -->
      <div class="text-sm text-warm-gray-500 mb-6">
        <p>업로드: <%= @photo.uploader.nickname %></p>
        <% if @photo.child %>
          <p>아이: <%= @photo.child.name %></p>
        <% end %>
      </div>

      <!-- 댓글 -->
      <div class="space-y-4">
        <% @photo.comments.each do |comment| %>
          <%= render "photos/comments/comment", comment: comment %>
        <% end %>
      </div>
    </div>

    <!-- 댓글 입력 -->
    <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-warm-gray-100 px-4 py-3 safe-area-inset-bottom">
      <%= form_with url: family_photo_comments_path(@family, @photo), class: "flex items-center gap-3" do |form| %>
        <%= form.text_field :content, placeholder: "댓글 작성...", class: "input-text flex-1" %>
        <%= form.submit "전송", class: "btn-primary btn-sm" %>
      <% end %>
    </div>
  </div>
</div>
```

- [x] **REFACTOR**: 반응/댓글 컴포넌트 분리 ✅ 2025-12-17

### 완료 기준
- 투명 헤더 (bg-black/30 backdrop-blur-sm)
- rounded-t-3xl 정보 카드
- 고정 댓글 입력창

---

## 5.3 사진 업로드 (병렬 가능)

### 파일: `app/views/families/photos/new.html.erb`, `_form.html.erb`

### 작업 내용
- [x] **RED**: 업로드 폼 UI 테스트 ✅ 2025-12-17
- [x] **GREEN**: ✅ 2025-12-17

```erb
<%# new.html.erb %>
<div class="min-h-screen bg-cream-50">
  <!-- 헤더 -->
  <header class="flex items-center justify-between px-4 h-14 bg-white border-b border-warm-gray-100">
    <%= link_to family_photos_path(@family), class: "text-warm-gray-600" do %>
      취소
    <% end %>
    <span class="font-semibold text-warm-gray-800">사진 업로드</span>
    <button form="photo_form" type="submit" class="text-primary-500 font-semibold">완료</button>
  </header>

  <%= render partial: "form", locals: { photo: @photo } %>
</div>
```

```erb
<%# _form.html.erb %>
<%= form_with model: [@family, photo], id: "photo_form", class: "px-4 py-6 space-y-6" do |form| %>
  <% if photo.errors.any? %>
    <div class="alert-error">
      <% photo.errors.full_messages.each do |message| %>
        <p class="text-sm"><%= message %></p>
      <% end %>
    </div>
  <% end %>

  <!-- 미리보기 -->
  <div class="aspect-square bg-warm-gray-100 rounded-2xl overflow-hidden flex items-center justify-center"
       data-controller="image-preview">
    <div class="text-center" data-image-preview-target="placeholder">
      <%= heroicon "photo", variant: :outline, options: { class: "w-16 h-16 text-warm-gray-300 mx-auto mb-2" } %>
      <p class="text-sm text-warm-gray-400">사진을 선택해주세요</p>
    </div>
    <img class="w-full h-full object-cover hidden" data-image-preview-target="preview">
  </div>

  <!-- 파일 선택 -->
  <div class="flex gap-2 overflow-x-auto scrollbar-hide">
    <label class="shrink-0 w-16 h-16 bg-cream-100 rounded-xl flex items-center justify-center
                  cursor-pointer border-2 border-dashed border-warm-gray-300
                  hover:border-primary-400 transition-colors">
      <%= heroicon "plus", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-400" } %>
      <%= form.file_field :image, accept: "image/*", class: "hidden",
          data: { action: "change->image-preview#preview" } %>
    </label>
  </div>

  <!-- 캡션 -->
  <div>
    <%= form.text_area :caption, placeholder: "이 순간에 대해 적어보세요...",
        class: "input-textarea h-24", rows: 3 %>
  </div>

  <!-- 아이 태그 -->
  <div>
    <label class="block text-sm font-medium text-warm-gray-700 mb-2">아이 태그</label>
    <div class="flex gap-2 flex-wrap">
      <button type="button" class="px-4 py-2 rounded-full bg-primary-500 text-white text-sm font-medium"
              data-child-id="">
        전체
      </button>
      <% @family.children.each do |child| %>
        <button type="button" class="px-4 py-2 rounded-full bg-cream-100 text-warm-gray-600 text-sm font-medium"
                data-child-id="<%= child.id %>">
          <%= child.name %>
        </button>
      <% end %>
    </div>
    <%= form.hidden_field :child_id %>
  </div>

  <!-- 촬영일 -->
  <div>
    <label class="block text-sm font-medium text-warm-gray-700 mb-2">촬영일</label>
    <%= form.date_field :taken_at, class: "input-text", value: Date.today %>
  </div>
<% end %>
```

- [x] **REFACTOR**: 파일 업로드 Stimulus 컨트롤러 (`image_preview_controller.js`) ✅ 2025-12-17

### 완료 기준
- 취소/완료 헤더
- 이미지 미리보기
- pill 버튼 아이 태그
- input-text, input-textarea 스타일

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 4. 사진 타임라인, 5. 사진 상세/업로드
