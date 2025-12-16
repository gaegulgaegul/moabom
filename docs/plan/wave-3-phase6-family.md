# Wave 3: Phase 6 - 가족 관리

> 선행 조건: Wave 2 완료
> 병렬 실행: 6.1 ∥ 6.2 (내부 병렬), Phase 3, 4, 5, 7, 8과도 병렬 가능

---

## 6.1 가족 구성원 목록 (병렬 가능)

### 파일: `app/views/families/members/index.html.erb`

### 작업 내용
- [ ] **RED**: 구성원 목록 UI 테스트
- [ ] **GREEN**:

```erb
<div class="px-4 py-6">
  <h1 class="text-xl font-bold text-warm-gray-800 mb-6">가족 구성원</h1>

  <!-- 구성원 목록 -->
  <div class="card-solid divide-y divide-warm-gray-100 mb-6">
    <% @memberships.each do |membership| %>
      <div class="flex items-center justify-between py-4">
        <div class="flex items-center gap-3">
          <div class="avatar bg-primary-100">
            <span class="text-primary-600 font-medium">
              <%= membership.user.nickname.first %>
            </span>
          </div>
          <div>
            <p class="font-medium text-warm-gray-800"><%= membership.user.nickname %></p>
            <p class="text-sm text-warm-gray-500"><%= membership.user.email %></p>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <span class="badge <%= membership.role == 'admin' ? 'badge-primary' : 'badge-secondary' %>">
            <%= membership.role == 'admin' ? '관리자' : '구성원' %>
          </span>
          <% if can_manage_members? && membership.user != current_user %>
            <button class="p-2 hover:bg-cream-100 rounded-full">
              <%= heroicon "ellipsis-vertical", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
            </button>
          <% end %>
        </div>
      </div>
    <% end %>
  </div>

  <!-- 가족 초대 버튼 -->
  <% if can_manage_members? %>
    <%= link_to "#", class: "btn-outline w-full" do %>
      <%= heroicon "user-plus", variant: :outline, options: { class: "w-5 h-5 mr-2" } %>
      가족 초대하기
    <% end %>
  <% end %>
</div>
```

- [ ] **REFACTOR**: 구성원 카드 partial (`_member.html.erb`)

### 완료 기준
- card-solid 카드
- avatar 컴포넌트
- badge 역할 표시
- btn-outline 초대 버튼

---

## 6.2 아이 목록 (병렬 가능)

### 파일: `app/views/families/children/index.html.erb`

### 작업 내용
- [ ] **RED**: 아이 목록 UI 테스트
- [ ] **GREEN**:

```erb
<div class="px-4 py-6">
  <h1 class="text-xl font-bold text-warm-gray-800 mb-6">우리 아이들</h1>

  <% if @children.any? %>
    <div class="space-y-4 mb-6">
      <% @children.each do |child| %>
        <%= link_to edit_family_child_path(@family, child), class: "card-glass block tap-highlight-none" do %>
          <div class="flex items-center gap-4">
            <!-- 프로필 영역 -->
            <div class="w-16 h-16 rounded-full bg-cream-200 flex items-center justify-center overflow-hidden">
              <% if child.profile_photo.attached? %>
                <%= image_tag child.profile_photo.variant(:thumbnail), class: "w-full h-full object-cover" %>
              <% else %>
                <%= heroicon "face-smile", variant: :outline, options: { class: "w-8 h-8 text-warm-gray-400" } %>
              <% end %>
            </div>

            <!-- 정보 -->
            <div class="flex-1">
              <p class="font-semibold text-warm-gray-800"><%= child.name %></p>
              <p class="text-sm text-warm-gray-500">
                <%= child.birthdate.strftime("%Y.%m.%d") %> (D+<%= child.days_since_birth %>)
              </p>
              <p class="text-xs text-warm-gray-400">사진 <%= child.photos.count %>장</p>
            </div>

            <!-- 화살표 -->
            <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
          </div>
        <% end %>
      <% end %>
    </div>
  <% else %>
    <div class="empty-state mb-6">
      <div class="w-16 h-16 bg-cream-100 rounded-full flex items-center justify-center mb-4">
        <%= heroicon "face-smile", variant: :outline, options: { class: "w-8 h-8 text-warm-gray-400" } %>
      </div>
      <h3 class="text-lg font-medium text-warm-gray-800 mb-2">등록된 아이가 없어요</h3>
      <p class="text-warm-gray-500">아이를 등록하고 성장 기록을 시작하세요</p>
    </div>
  <% end %>

  <!-- 아이 추가 버튼 -->
  <% if can_manage_members? %>
    <%= link_to new_family_child_path(@family), class: "btn-outline w-full" do %>
      <%= heroicon "plus", variant: :outline, options: { class: "w-5 h-5 mr-2" } %>
      아이 추가하기
    <% end %>
  <% end %>
</div>
```

- [ ] **REFACTOR**: 아이 카드 partial (`_child.html.erb`)

### 완료 기준
- card-glass 카드
- D+일 표시
- 사진 수 표시
- empty-state 디자인

---

## 참고
- [PAGE_LAYOUTS.md](../references/PAGE_LAYOUTS.md) - 6. 가족 관리
