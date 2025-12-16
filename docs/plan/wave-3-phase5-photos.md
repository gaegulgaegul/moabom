# Wave 3: Phase 5 - 사진 기능

> 선행 조건: Wave 2 완료
> 병렬 실행: 5.1 ∥ 5.2 ∥ 5.3 (내부 병렬), Phase 3, 4, 6, 7, 8과도 병렬 가능

---

## 5.1 사진 타임라인 (병렬 가능)

### 파일: `app/views/families/photos/index.html.erb`

### 작업 내용
- [ ] **RED**: 타임라인 UI 테스트
- [ ] **GREEN**:

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

- [ ] **REFACTOR**: 사진 그리드 partial 추출

### 완료 기준
- pill 스타일 필터 탭
- 3열 그리드 (gap-1, rounded-lg)
- 월별 그룹핑
- empty-state 디자인

---

## 5.2 사진 상세 (병렬 가능)

### 파일: `app/views/families/photos/show.html.erb`

### 작업 내용
- [ ] **RED**: 사진 상세 UI 테스트
- [ ] **GREEN**:

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
      <%= form_with url: photo_comments_path(@photo), class: "flex items-center gap-3" do |form| %>
        <%= form.text_field :content, placeholder: "댓글 작성...", class: "input-text flex-1" %>
        <%= form.submit "전송", class: "btn-primary btn-sm" %>
      <% end %>
    </div>
  </div>
</div>
```

- [ ] **REFACTOR**: 반응/댓글 컴포넌트 분리

### 완료 기준
- 투명 헤더 (bg-black/30 backdrop-blur-sm)
- rounded-t-3xl 정보 카드
- 고정 댓글 입력창

---

## 5.3 사진 업로드 (병렬 가능)

### 파일: `app/views/families/photos/new.html.erb`, `_form.html.erb`

### 작업 내용
- [ ] **RED**: 업로드 폼 UI 테스트
- [ ] **GREEN**:

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

- [ ] **REFACTOR**: 파일 업로드 Stimulus 컨트롤러 (`image_preview_controller.js`)

### 완료 기준
- 취소/완료 헤더
- 이미지 미리보기
- pill 버튼 아이 태그
- input-text, input-textarea 스타일

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 4. 사진 타임라인, 5. 사진 상세/업로드
