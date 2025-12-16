# Wave 3: Phase 4 - 대시보드

> 선행 조건: Wave 2 완료, Phase 3.1 완료 (파일 충돌 방지)
> 병렬 실행: Phase 5, 6, 7, 8과 병렬 가능

---

## 4.1 대시보드 (로그인 상태)

### 파일: `app/views/home/index.html.erb` (로그인 상태 부분)

### 주의사항
**Phase 3.1과 같은 파일을 수정하므로, Phase 3.1 완료 후 진행**

### 작업 내용
- [ ] **RED**: 대시보드 UI 테스트
- [ ] **GREEN**:

```erb
<% if logged_in? %>
  <div class="px-4 py-6 space-y-6">
    <!-- 인사 -->
    <div>
      <h1 class="text-xl font-bold text-warm-gray-800">
        안녕하세요, <%= current_user.nickname %>님! 👋
      </h1>
    </div>

    <!-- 아이 카드 -->
    <% if @child.present? %>
      <div class="card-glass">
        <div class="flex items-center gap-4">
          <div class="avatar avatar-lg bg-primary-100">
            <%= heroicon "face-smile", variant: :outline, options: { class: "w-8 h-8 text-primary-500" } %>
          </div>
          <div>
            <p class="font-semibold text-warm-gray-800">
              <%= @child.name %>의 D+<%= @child.days_since_birth %>
            </p>
            <p class="text-sm text-warm-gray-500">오늘도 예쁜 하루 보내세요</p>
          </div>
        </div>
      </div>
    <% end %>

    <!-- 최근 사진 -->
    <% if @recent_photos.present? %>
      <section>
        <h2 class="text-lg font-semibold text-warm-gray-800 mb-3">최근 사진</h2>
        <div class="flex gap-3 overflow-x-auto scrollbar-hide -mx-4 px-4">
          <% @recent_photos.each do |photo| %>
            <%= link_to family_photo_path(@family, photo), class: "shrink-0" do %>
              <div class="w-24 h-24 rounded-xl overflow-hidden">
                <%= image_tag photo.image.variant(:thumbnail),
                    class: "w-full h-full object-cover",
                    loading: "lazy" %>
              </div>
            <% end %>
          <% end %>
        </div>
      </section>
    <% end %>

    <!-- 빠른 메뉴 (Bento Grid) -->
    <section>
      <h2 class="text-lg font-semibold text-warm-gray-800 mb-3">빠른 메뉴</h2>
      <div class="grid grid-cols-2 gap-3">
        <%= link_to new_family_photo_path(@family),
            class: "card-flat flex flex-col items-center justify-center py-6 tap-highlight-none" do %>
          <%= heroicon "camera", variant: :outline, options: { class: "w-8 h-8 text-primary-500 mb-2" } %>
          <span class="text-sm font-medium text-warm-gray-700">사진 업로드</span>
        <% end %>

        <%= link_to family_members_path(@family),
            class: "card-flat flex flex-col items-center justify-center py-6 tap-highlight-none" do %>
          <%= heroicon "user-group", variant: :outline, options: { class: "w-8 h-8 text-secondary-500 mb-2" } %>
          <span class="text-sm font-medium text-warm-gray-700">가족 관리</span>
        <% end %>

        <%= link_to family_photos_path(@family),
            class: "card-flat flex flex-col items-center justify-center py-6 tap-highlight-none" do %>
          <%= heroicon "calendar-days", variant: :outline, options: { class: "w-8 h-8 text-accent-500 mb-2" } %>
          <span class="text-sm font-medium text-warm-gray-700">앨범 보기</span>
        <% end %>

        <%= link_to family_children_path(@family),
            class: "card-flat flex flex-col items-center justify-center py-6 tap-highlight-none" do %>
          <%= heroicon "face-smile", variant: :outline, options: { class: "w-8 h-8 text-primary-500 mb-2" } %>
          <span class="text-sm font-medium text-warm-gray-700">아이 프로필</span>
        <% end %>
      </div>
    </section>
  </div>
<% end %>
```

- [ ] **REFACTOR**: 섹션별 partial 분리
  - `_child_card.html.erb`
  - `_recent_photos.html.erb`
  - `_quick_menu.html.erb`

### 완료 기준
- card-glass 아이 카드
- 가로 스크롤 최근 사진
- Bento Grid 빠른 메뉴
- heroicon 아이콘 적용

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 2.2 로그인 상태 (대시보드)
