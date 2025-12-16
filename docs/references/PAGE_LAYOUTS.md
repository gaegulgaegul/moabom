# 모아봄 페이지 레이아웃 가이드

> 각 페이지별 레이아웃 구조 및 디자인 명세
> 버전: 1.0
> 최종 수정: 2025-12-16

---

## 목차

1. [공통 레이아웃](#1-공통-레이아웃)
2. [홈 화면](#2-홈-화면)
3. [온보딩 플로우](#3-온보딩-플로우)
4. [사진 타임라인](#4-사진-타임라인)
5. [사진 상세/업로드](#5-사진-상세업로드)
6. [가족 관리](#6-가족-관리)
7. [설정](#7-설정)
8. [에러 페이지](#8-에러-페이지)

---

## 1. 공통 레이아웃

### 1.1 전체 구조

```
┌─────────────────────────────────────┐
│            Header (56px)            │  ← fixed top, glass
├─────────────────────────────────────┤
│                                     │
│                                     │
│            Main Content             │  ← pt-14 pb-20, bg-cream-50
│         (스크롤 영역)                │
│                                     │
│                                     │
├─────────────────────────────────────┤
│            Tab Bar (64px)           │  ← fixed bottom, glass
└─────────────────────────────────────┘
```

### 1.2 Header 디자인

```html
<header class="fixed top-0 left-0 right-0 z-50 glass safe-area-inset-top">
  <div class="flex items-center justify-between px-4 h-14">
    <!-- 로고 -->
    <a href="/" class="flex items-center gap-2">
      <span class="text-gradient-primary text-xl font-bold">모아봄</span>
    </a>

    <!-- 우측 액션 -->
    <div class="flex items-center gap-3">
      <!-- 알림 아이콘 (뱃지 포함) -->
      <button class="relative p-2 tap-highlight-none">
        <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-700" } %>
        <span class="absolute top-1 right-1 w-2 h-2 bg-accent-500 rounded-full"></span>
      </button>
    </div>
  </div>
</header>
```

### 1.3 Tab Bar 디자인

```html
<nav class="fixed bottom-0 left-0 right-0 z-50 glass safe-area-inset-bottom">
  <div class="flex items-center justify-around h-16">
    <!-- 홈 -->
    <a href="/" class="flex flex-col items-center justify-center flex-1 py-2 tap-highlight-none">
      <%= heroicon "home", variant: :solid, options: { class: "w-6 h-6 text-primary-500" } %>
      <span class="text-xs mt-1 text-primary-500 font-medium">홈</span>
    </a>

    <!-- 앨범 -->
    <a href="/albums" class="flex flex-col items-center justify-center flex-1 py-2 tap-highlight-none">
      <%= heroicon "photo", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-400" } %>
      <span class="text-xs mt-1 text-warm-gray-400">앨범</span>
    </a>

    <!-- 업로드 (FAB 스타일) -->
    <a href="/photos/new" class="flex items-center justify-center -mt-4 tap-highlight-none">
      <div class="w-14 h-14 bg-primary-500 rounded-full flex items-center justify-center shadow-lg">
        <%= heroicon "plus", variant: :solid, options: { class: "w-7 h-7 text-white" } %>
      </div>
    </a>

    <!-- 알림 -->
    <a href="/notifications" class="flex flex-col items-center justify-center flex-1 py-2 tap-highlight-none">
      <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-400" } %>
      <span class="text-xs mt-1 text-warm-gray-400">알림</span>
    </a>

    <!-- 설정 -->
    <a href="/settings" class="flex flex-col items-center justify-center flex-1 py-2 tap-highlight-none">
      <%= heroicon "cog-6-tooth", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-400" } %>
      <span class="text-xs mt-1 text-warm-gray-400">설정</span>
    </a>
  </div>
</nav>
```

### 1.4 Flash 메시지

```html
<!-- 성공 -->
<div class="alert-success flex items-center gap-3 mx-4 mt-4">
  <%= heroicon "check-circle", variant: :solid, options: { class: "w-5 h-5 text-green-600 shrink-0" } %>
  <p class="text-sm"><%= flash[:notice] %></p>
</div>

<!-- 에러 -->
<div class="alert-error flex items-center gap-3 mx-4 mt-4">
  <%= heroicon "exclamation-circle", variant: :solid, options: { class: "w-5 h-5 text-red-600 shrink-0" } %>
  <p class="text-sm"><%= flash[:alert] %></p>
</div>
```

---

## 2. 홈 화면

### 2.1 비로그인 상태 (로그인 페이지)

```
┌─────────────────────────────────────┐
│            Header                   │
├─────────────────────────────────────┤
│                                     │
│     ┌───────────────────────┐       │
│     │                       │       │
│     │    🌸 일러스트/로고    │       │
│     │                       │       │
│     └───────────────────────┘       │
│                                     │
│     우리 아이의 소중한 순간,         │
│       가족과 함께 모아봄             │
│                                     │
│     ┌───────────────────────┐       │
│     │   Apple로 계속하기     │ glass │
│     └───────────────────────┘       │
│     ┌───────────────────────┐       │
│     │   카카오로 계속하기    │ 노랑  │
│     └───────────────────────┘       │
│     ┌───────────────────────┐       │
│     │   Google로 계속하기   │ glass │
│     └───────────────────────┘       │
│                                     │
│     이용약관 | 개인정보 처리방침      │
│                                     │
└─────────────────────────────────────┘
```

**구현 코드**

```html
<div class="min-h-screen bg-gradient-warm flex flex-col">
  <!-- 상단 여백 -->
  <div class="flex-1 flex flex-col items-center justify-center px-6 pt-20">
    <!-- 로고/일러스트 영역 -->
    <div class="w-32 h-32 mb-8">
      <!-- 일러스트 또는 로고 이미지 -->
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
    <a href="/auth/apple" class="flex items-center justify-center gap-3 w-full py-4 bg-black text-white rounded-2xl font-medium">
      <%= heroicon "apple", options: { class: "w-5 h-5" } %>
      Apple로 계속하기
    </a>

    <!-- 카카오 로그인 -->
    <a href="/auth/kakao" class="flex items-center justify-center gap-3 w-full py-4 bg-yellow-400 text-warm-gray-900 rounded-2xl font-medium">
      카카오로 계속하기
    </a>

    <!-- Google 로그인 -->
    <a href="/auth/google" class="card-glass flex items-center justify-center gap-3 w-full py-4 rounded-2xl font-medium text-warm-gray-700">
      Google로 계속하기
    </a>

    <!-- 약관 -->
    <p class="text-xs text-warm-gray-400 text-center pt-4">
      로그인 시 <a href="#" class="underline">이용약관</a> 및
      <a href="#" class="underline">개인정보 처리방침</a>에 동의하게 됩니다.
    </p>
  </div>
</div>
```

### 2.2 로그인 상태 (대시보드)

```
┌─────────────────────────────────────┐
│            Header                   │
├─────────────────────────────────────┤
│  안녕하세요, [닉네임]님! 👋          │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  [아이이름]의 D+365          │    │  ← card-glass
│  │  오늘도 예쁜 하루 보내세요    │    │
│  └─────────────────────────────┘    │
│                                     │
│  최근 사진                           │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │     │ │     │ │     │ │     │   │  ← 가로 스크롤
│  └─────┘ └─────┘ └─────┘ └─────┘   │
│                                     │
│  빠른 메뉴                           │
│  ┌─────────┐  ┌─────────┐          │
│  │ 📷 사진  │  │ 👨‍👩‍👧 가족 │          │  ← Bento Grid
│  │  업로드  │  │  관리   │          │
│  └─────────┘  └─────────┘          │
│  ┌─────────┐  ┌─────────┐          │
│  │ 📅 앨범  │  │ 👶 아이  │          │
│  │  보기   │  │  프로필  │          │
│  └─────────┘  └─────────┘          │
│                                     │
├─────────────────────────────────────┤
│            Tab Bar                  │
└─────────────────────────────────────┘
```

**구현 코드**

```html
<div class="px-4 py-6 space-y-6">
  <!-- 인사 -->
  <div>
    <h1 class="text-xl font-bold text-warm-gray-800">
      안녕하세요, <%= current_user.nickname %>님!
    </h1>
  </div>

  <!-- 아이 카드 -->
  <div class="card-glass">
    <div class="flex items-center gap-4">
      <div class="avatar avatar-lg bg-primary-100">
        <%= heroicon "face-smile", variant: :outline, options: { class: "w-8 h-8 text-primary-500" } %>
      </div>
      <div>
        <p class="font-semibold text-warm-gray-800"><%= @child.name %>의 D+<%= @child.days_since_birth %></p>
        <p class="text-sm text-warm-gray-500">오늘도 예쁜 하루 보내세요</p>
      </div>
    </div>
  </div>

  <!-- 최근 사진 -->
  <section>
    <h2 class="text-lg font-semibold text-warm-gray-800 mb-3">최근 사진</h2>
    <div class="flex gap-3 overflow-x-auto scrollbar-hide -mx-4 px-4">
      <% @recent_photos.each do |photo| %>
        <div class="shrink-0 w-24 h-24 rounded-xl overflow-hidden">
          <%= image_tag photo.image.variant(:thumbnail), class: "w-full h-full object-cover" %>
        </div>
      <% end %>
    </div>
  </section>

  <!-- 빠른 메뉴 (Bento Grid) -->
  <section>
    <h2 class="text-lg font-semibold text-warm-gray-800 mb-3">빠른 메뉴</h2>
    <div class="grid grid-cols-2 gap-3">
      <a href="/photos/new" class="card-flat flex flex-col items-center justify-center py-6 tap-highlight-none">
        <%= heroicon "camera", variant: :outline, options: { class: "w-8 h-8 text-primary-500 mb-2" } %>
        <span class="text-sm font-medium text-warm-gray-700">사진 업로드</span>
      </a>
      <a href="/families" class="card-flat flex flex-col items-center justify-center py-6 tap-highlight-none">
        <%= heroicon "user-group", variant: :outline, options: { class: "w-8 h-8 text-secondary-500 mb-2" } %>
        <span class="text-sm font-medium text-warm-gray-700">가족 관리</span>
      </a>
      <a href="/albums" class="card-flat flex flex-col items-center justify-center py-6 tap-highlight-none">
        <%= heroicon "calendar-days", variant: :outline, options: { class: "w-8 h-8 text-accent-500 mb-2" } %>
        <span class="text-sm font-medium text-warm-gray-700">앨범 보기</span>
      </a>
      <a href="/children" class="card-flat flex flex-col items-center justify-center py-6 tap-highlight-none">
        <%= heroicon "face-smile", variant: :outline, options: { class: "w-8 h-8 text-primary-500 mb-2" } %>
        <span class="text-sm font-medium text-warm-gray-700">아이 프로필</span>
      </a>
    </div>
  </section>
</div>
```

---

## 3. 온보딩 플로우

### 3.1 흐름

```
[로그인] → [프로필 설정] → [아이 등록] → [가족 초대] → [홈]
              Step 1          Step 2        Step 3
```

### 3.2 공통 온보딩 레이아웃

```
┌─────────────────────────────────────┐
│  ← 뒤로    모아봄     1/3 ●○○      │  ← 진행률 표시
├─────────────────────────────────────┤
│                                     │
│     ┌───────────────────────┐       │
│     │     일러스트/아이콘    │       │
│     └───────────────────────┘       │
│                                     │
│     Step Title                      │
│     Step Description                │
│                                     │
│     ┌───────────────────────┐       │
│     │     Form Fields       │       │
│     └───────────────────────┘       │
│                                     │
│                                     │
├─────────────────────────────────────┤
│     ┌───────────────────────┐       │
│     │      다음 버튼         │       │  ← btn-primary
│     └───────────────────────┘       │
│            건너뛰기                  │  ← text link
└─────────────────────────────────────┘
```

### 3.3 Step 1: 프로필 설정

```html
<div class="min-h-screen bg-cream-50 flex flex-col">
  <!-- 헤더 -->
  <header class="flex items-center justify-between px-4 h-14">
    <button class="p-2">
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
    <!-- 아이콘 -->
    <div class="w-20 h-20 mx-auto mb-6 bg-primary-100 rounded-full flex items-center justify-center">
      <%= heroicon "user-circle", variant: :outline, options: { class: "w-10 h-10 text-primary-500" } %>
    </div>

    <!-- 타이틀 -->
    <h1 class="text-2xl font-bold text-warm-gray-800 text-center mb-2">
      프로필을 설정해주세요
    </h1>
    <p class="text-warm-gray-500 text-center mb-8">
      가족들에게 보여질 이름이에요
    </p>

    <!-- 폼 -->
    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">닉네임</label>
        <input type="text" placeholder="예: 엄마, 아빠, 할머니" class="input-text">
      </div>
    </div>
  </div>

  <!-- 하단 버튼 -->
  <div class="px-6 pb-8 space-y-3">
    <button class="btn-primary w-full">다음</button>
  </div>
</div>
```

### 3.4 Step 2: 아이 등록

```html
<div class="min-h-screen bg-cream-50 flex flex-col">
  <!-- 헤더 (진행률 2/3) -->

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

    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">이름</label>
        <input type="text" placeholder="아이 이름" class="input-text">
      </div>
      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">생년월일</label>
        <input type="date" class="input-text">
      </div>
      <div>
        <label class="block text-sm font-medium text-warm-gray-700 mb-2">성별</label>
        <div class="flex gap-3">
          <button class="flex-1 py-3 rounded-xl border-2 border-primary-500 bg-primary-50 text-primary-700 font-medium">
            여아
          </button>
          <button class="flex-1 py-3 rounded-xl border-2 border-warm-gray-200 text-warm-gray-500 font-medium">
            남아
          </button>
        </div>
      </div>
    </div>
  </div>

  <div class="px-6 pb-8 space-y-3">
    <button class="btn-primary w-full">다음</button>
    <button class="text-warm-gray-400 text-sm w-full py-2">나중에 할게요</button>
  </div>
</div>
```

### 3.5 Step 3: 가족 초대

```html
<div class="min-h-screen bg-cream-50 flex flex-col">
  <!-- 헤더 (진행률 3/3) -->

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
        <input type="text" value="moabom.app/i/abc123" readonly class="input-text flex-1 text-sm">
        <button class="btn-primary btn-sm shrink-0">
          <%= heroicon "clipboard-document", variant: :outline, options: { class: "w-5 h-5" } %>
        </button>
      </div>
    </div>

    <!-- 공유 버튼들 -->
    <div class="flex justify-center gap-4 mt-6">
      <button class="flex flex-col items-center gap-2">
        <div class="w-12 h-12 bg-yellow-400 rounded-full flex items-center justify-center">
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
    <button class="btn-primary w-full">시작하기</button>
    <button class="text-warm-gray-400 text-sm w-full py-2">나중에 초대할게요</button>
  </div>
</div>
```

---

## 4. 사진 타임라인

### 4.1 타임라인 레이아웃

```
┌─────────────────────────────────────┐
│            Header                   │
├─────────────────────────────────────┤
│  사진 타임라인                       │
│                                     │
│  [전체] [아이1] [아이2]    ← 필터    │
│                                     │
│  2025년 1월                          │
│  ┌─────┬─────┬─────┐               │
│  │     │     │     │               │
│  ├─────┼─────┼─────┤               │  ← Bento Grid
│  │     │     │     │               │
│  │     │     ├─────┤               │
│  │     │     │     │               │
│  └─────┴─────┴─────┘               │
│                                     │
│  2024년 12월                         │
│  ┌─────┬─────┬─────┐               │
│  │     │     │     │               │
│  ...                                │
│                                     │
├─────────────────────────────────────┤
│            Tab Bar                  │
└─────────────────────────────────────┘
```

**구현 코드**

```html
<div class="px-4 py-6">
  <!-- 헤더 -->
  <h1 class="text-xl font-bold text-warm-gray-800 mb-4">사진 타임라인</h1>

  <!-- 필터 탭 -->
  <div class="flex gap-2 mb-6 overflow-x-auto scrollbar-hide -mx-4 px-4">
    <button class="shrink-0 px-4 py-2 rounded-full bg-primary-500 text-white text-sm font-medium">
      전체
    </button>
    <% @children.each do |child| %>
      <button class="shrink-0 px-4 py-2 rounded-full bg-cream-100 text-warm-gray-600 text-sm font-medium">
        <%= child.name %>
      </button>
    <% end %>
  </div>

  <!-- 월별 그룹 -->
  <% @photos_by_month.each do |month, photos| %>
    <section class="mb-8">
      <h2 class="text-sm font-semibold text-warm-gray-500 mb-3"><%= month %></h2>

      <!-- 사진 그리드 -->
      <div class="grid grid-cols-3 gap-1">
        <% photos.each do |photo| %>
          <a href="<%= photo_path(photo) %>" class="aspect-square overflow-hidden rounded-lg">
            <%= image_tag photo.image.variant(:thumbnail),
                class: "w-full h-full object-cover",
                loading: "lazy" %>
          </a>
        <% end %>
      </div>
    </section>
  <% end %>

  <!-- 빈 상태 -->
  <% if @photos.empty? %>
    <div class="empty-state">
      <div class="w-20 h-20 bg-cream-100 rounded-full flex items-center justify-center mb-4">
        <%= heroicon "photo", variant: :outline, options: { class: "w-10 h-10 text-warm-gray-400" } %>
      </div>
      <h3 class="text-lg font-medium text-warm-gray-800 mb-2">아직 사진이 없어요</h3>
      <p class="text-warm-gray-500 mb-6">소중한 순간을 가족과 공유해보세요</p>
      <a href="/photos/new" class="btn-primary">
        <%= heroicon "plus", variant: :solid, options: { class: "w-5 h-5 mr-2" } %>
        첫 사진 업로드
      </a>
    </div>
  <% end %>
</div>
```

---

## 5. 사진 상세/업로드

### 5.1 사진 상세

```
┌─────────────────────────────────────┐
│  ←                           ⋮     │  ← 투명 헤더
├─────────────────────────────────────┤
│                                     │
│                                     │
│          [사진 이미지]               │  ← 전체 너비, 스와이프 가능
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ❤️ 5   💬 2           2025.01.15  │  ← 반응 & 날짜
│                                     │
│  첫 걸음마를 뗐어요!                  │  ← 캡션
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 댓글 영역                    │    │
│  │ 엄마: 너무 예뻐!             │    │
│  │ 아빠: 우리 딸!               │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌────────────────────────┐ 전송   │  ← 댓글 입력
└─────────────────────────────────────┘
```

**구현 코드**

```html
<div class="min-h-screen bg-warm-gray-900">
  <!-- 투명 헤더 -->
  <header class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-4 h-14">
    <button onclick="history.back()" class="p-2 bg-black/30 rounded-full backdrop-blur-sm">
      <%= heroicon "arrow-left", variant: :outline, options: { class: "w-6 h-6 text-white" } %>
    </button>
    <button class="p-2 bg-black/30 rounded-full backdrop-blur-sm">
      <%= heroicon "ellipsis-horizontal", variant: :outline, options: { class: "w-6 h-6 text-white" } %>
    </button>
  </header>

  <!-- 사진 -->
  <div class="w-full aspect-square">
    <%= image_tag @photo.image, class: "w-full h-full object-contain bg-black" %>
  </div>

  <!-- 정보 영역 -->
  <div class="bg-white rounded-t-3xl -mt-6 relative z-10 min-h-[50vh]">
    <div class="px-4 py-6">
      <!-- 반응 & 날짜 -->
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-4">
          <button class="flex items-center gap-1 text-warm-gray-600">
            <%= heroicon "heart", variant: :solid, options: { class: "w-6 h-6 text-accent-500" } %>
            <span><%= @photo.reactions_count %></span>
          </button>
          <button class="flex items-center gap-1 text-warm-gray-600">
            <%= heroicon "chat-bubble-oval-left", variant: :outline, options: { class: "w-6 h-6" } %>
            <span><%= @photo.comments_count %></span>
          </button>
        </div>
        <span class="text-sm text-warm-gray-400"><%= l @photo.taken_at, format: :short %></span>
      </div>

      <!-- 캡션 -->
      <% if @photo.caption.present? %>
        <p class="text-warm-gray-800 mb-6"><%= @photo.caption %></p>
      <% end %>

      <!-- 댓글 -->
      <div class="space-y-4">
        <% @photo.comments.each do |comment| %>
          <div class="flex gap-3">
            <div class="avatar avatar-sm">
              <span class="text-xs"><%= comment.user.nickname.first %></span>
            </div>
            <div>
              <span class="font-medium text-warm-gray-800"><%= comment.user.nickname %></span>
              <p class="text-warm-gray-600"><%= comment.content %></p>
            </div>
          </div>
        <% end %>
      </div>
    </div>

    <!-- 댓글 입력 -->
    <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-warm-gray-100 px-4 py-3 safe-area-inset-bottom">
      <div class="flex items-center gap-3">
        <input type="text" placeholder="댓글 작성..." class="input-text flex-1">
        <button class="btn-primary btn-sm">전송</button>
      </div>
    </div>
  </div>
</div>
```

### 5.2 사진 업로드

```
┌─────────────────────────────────────┐
│  ← 취소      사진 업로드      완료   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │      선택된 사진 미리보기     │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  [+] [📷] [📷] [📷]    ← 추가 선택  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  캡션 입력...                │    │
│  └─────────────────────────────┘    │
│                                     │
│  아이 태그                           │
│  [전체] [○ 아이1] [○ 아이2]         │
│                                     │
│  촬영일                              │
│  [2025년 1월 15일]                   │
│                                     │
└─────────────────────────────────────┘
```

**구현 코드**

```html
<div class="min-h-screen bg-cream-50">
  <!-- 헤더 -->
  <header class="flex items-center justify-between px-4 h-14 bg-white border-b border-warm-gray-100">
    <button class="text-warm-gray-600">취소</button>
    <span class="font-semibold text-warm-gray-800">사진 업로드</span>
    <button class="text-primary-500 font-semibold">완료</button>
  </header>

  <div class="px-4 py-6 space-y-6">
    <!-- 미리보기 -->
    <div class="aspect-square bg-warm-gray-100 rounded-2xl overflow-hidden">
      <img src="" class="w-full h-full object-cover" id="preview">
    </div>

    <!-- 추가 선택 -->
    <div class="flex gap-2 overflow-x-auto scrollbar-hide">
      <label class="shrink-0 w-16 h-16 bg-cream-100 rounded-xl flex items-center justify-center cursor-pointer border-2 border-dashed border-warm-gray-300">
        <%= heroicon "plus", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-400" } %>
        <input type="file" class="hidden" multiple accept="image/*">
      </label>
    </div>

    <!-- 캡션 -->
    <div>
      <textarea placeholder="이 순간에 대해 적어보세요..."
                class="input-textarea h-24"
                rows="3"></textarea>
    </div>

    <!-- 아이 태그 -->
    <div>
      <label class="block text-sm font-medium text-warm-gray-700 mb-2">아이 태그</label>
      <div class="flex gap-2 flex-wrap">
        <button class="px-4 py-2 rounded-full bg-primary-500 text-white text-sm font-medium">
          전체
        </button>
        <% @children.each do |child| %>
          <button class="px-4 py-2 rounded-full bg-cream-100 text-warm-gray-600 text-sm font-medium">
            <%= child.name %>
          </button>
        <% end %>
      </div>
    </div>

    <!-- 촬영일 -->
    <div>
      <label class="block text-sm font-medium text-warm-gray-700 mb-2">촬영일</label>
      <input type="date" class="input-text">
    </div>
  </div>
</div>
```

---

## 6. 가족 관리

### 6.1 가족 구성원 목록

```
┌─────────────────────────────────────┐
│            Header                   │
├─────────────────────────────────────┤
│  가족 구성원                         │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👩 엄마              관리자  │    │  ← card-solid
│  │    mom@email.com            │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 👨 아빠              구성원  │    │
│  │    dad@email.com            │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 👵 할머니            구성원  │    │
│  │    grandma@email.com        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  + 가족 초대하기             │    │  ← btn-outline
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│            Tab Bar                  │
└─────────────────────────────────────┘
```

### 6.2 아이 목록

```
┌─────────────────────────────────────┐
│            Header                   │
├─────────────────────────────────────┤
│  우리 아이들                         │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  [사진]  하은                │    │
│  │         2024.03.15 (D+300)  │    │  ← card-glass
│  │         사진 52장            │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  + 아이 추가하기             │    │  ← btn-outline
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│            Tab Bar                  │
└─────────────────────────────────────┘
```

---

## 7. 설정

### 7.1 설정 메인

```
┌─────────────────────────────────────┐
│            Header                   │
├─────────────────────────────────────┤
│  설정                                │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 프로필 설정           >  │    │
│  ├─────────────────────────────┤    │
│  │ 🔔 알림 설정             >  │    │  ← 그룹 카드
│  ├─────────────────────────────┤    │
│  │ 🌙 다크 모드           [○] │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 📄 이용약관              >  │    │
│  ├─────────────────────────────┤    │
│  │ 🔒 개인정보 처리방침     >  │    │
│  ├─────────────────────────────┤    │
│  │ ℹ️ 앱 정보               >  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🚪 로그아웃                 │    │  ← text-red
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│            Tab Bar                  │
└─────────────────────────────────────┘
```

**구현 코드**

```html
<div class="px-4 py-6 space-y-6">
  <h1 class="text-xl font-bold text-warm-gray-800">설정</h1>

  <!-- 계정 설정 -->
  <div class="card-solid divide-y divide-warm-gray-100">
    <a href="/settings/profile" class="flex items-center justify-between py-4 tap-highlight-none">
      <div class="flex items-center gap-3">
        <%= heroicon "user-circle", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">프로필 설정</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    </a>
    <a href="/settings/notifications" class="flex items-center justify-between py-4 tap-highlight-none">
      <div class="flex items-center gap-3">
        <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">알림 설정</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    </a>
    <div class="flex items-center justify-between py-4">
      <div class="flex items-center gap-3">
        <%= heroicon "moon", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">다크 모드</span>
      </div>
      <!-- Toggle Switch -->
      <button class="w-12 h-7 bg-warm-gray-200 rounded-full relative">
        <span class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full shadow transition-transform"></span>
      </button>
    </div>
  </div>

  <!-- 정보 -->
  <div class="card-solid divide-y divide-warm-gray-100">
    <a href="/terms" class="flex items-center justify-between py-4 tap-highlight-none">
      <div class="flex items-center gap-3">
        <%= heroicon "document-text", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">이용약관</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    </a>
    <a href="/privacy" class="flex items-center justify-between py-4 tap-highlight-none">
      <div class="flex items-center gap-3">
        <%= heroicon "shield-check", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">개인정보 처리방침</span>
      </div>
      <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
    </a>
    <a href="/about" class="flex items-center justify-between py-4 tap-highlight-none">
      <div class="flex items-center gap-3">
        <%= heroicon "information-circle", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-500" } %>
        <span class="text-warm-gray-800">앱 정보</span>
      </div>
      <span class="text-sm text-warm-gray-400">v1.0.0</span>
    </a>
  </div>

  <!-- 로그아웃 -->
  <div class="card-solid">
    <button class="flex items-center gap-3 py-4 w-full tap-highlight-none">
      <%= heroicon "arrow-right-on-rectangle", variant: :outline, options: { class: "w-6 h-6 text-red-500" } %>
      <span class="text-red-500">로그아웃</span>
    </button>
  </div>
</div>
```

---

## 8. 에러 페이지

### 8.1 404 Not Found

```html
<div class="min-h-screen bg-cream-50 flex flex-col items-center justify-center px-6">
  <div class="w-24 h-24 bg-warm-gray-100 rounded-full flex items-center justify-center mb-6">
    <%= heroicon "magnifying-glass", variant: :outline, options: { class: "w-12 h-12 text-warm-gray-400" } %>
  </div>
  <h1 class="text-2xl font-bold text-warm-gray-800 mb-2">페이지를 찾을 수 없어요</h1>
  <p class="text-warm-gray-500 text-center mb-8">
    요청하신 페이지가 존재하지 않거나<br>이동되었을 수 있어요.
  </p>
  <a href="/" class="btn-primary">홈으로 돌아가기</a>
</div>
```

### 8.2 500 Server Error

```html
<div class="min-h-screen bg-cream-50 flex flex-col items-center justify-center px-6">
  <div class="w-24 h-24 bg-red-100 rounded-full flex items-center justify-center mb-6">
    <%= heroicon "exclamation-triangle", variant: :outline, options: { class: "w-12 h-12 text-red-500" } %>
  </div>
  <h1 class="text-2xl font-bold text-warm-gray-800 mb-2">문제가 발생했어요</h1>
  <p class="text-warm-gray-500 text-center mb-8">
    잠시 후 다시 시도해주세요.<br>문제가 계속되면 고객센터로 연락해주세요.
  </p>
  <a href="/" class="btn-primary">홈으로 돌아가기</a>
</div>
```

---

## 참고

- 디자인 토큰/컴포넌트: [DESIGN_GUIDE.md](./DESIGN_GUIDE.md)
- 2025 모바일 트렌드: [MOBILE_DESIGN_TRENDS_2025.md](./MOBILE_DESIGN_TRENDS_2025.md)
- 아이콘: [Heroicons](https://heroicons.com/)
