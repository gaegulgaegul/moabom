# 모아봄 디자인 가이드

> 모아봄 앱 디자인 시스템 문서
> 버전: 1.0
> 최종 수정: 2025-12-16

---

## 목차

1. [디자인 원칙](#1-디자인-원칙)
2. [색상 시스템](#2-색상-시스템)
3. [타이포그래피](#3-타이포그래피)
4. [간격 시스템](#4-간격-시스템)
5. [아이콘 시스템](#5-아이콘-시스템)
6. [컴포넌트 라이브러리](#6-컴포넌트-라이브러리)
7. [레이아웃 패턴](#7-레이아웃-패턴)
8. [다크 모드](#8-다크-모드)
9. [접근성 가이드](#9-접근성-가이드)
10. [TailwindCSS 설정](#10-tailwindcss-설정)

---

## 1. 디자인 원칙

### 1.1 핵심 가치

| 원칙 | 설명 |
|------|------|
| **따뜻함** | 가족과 아이를 위한 포근하고 부드러운 느낌 |
| **단순함** | 복잡하지 않고 직관적인 사용 경험 |
| **접근성** | 모든 가족 구성원이 쉽게 사용 가능 |
| **사진 중심** | 사진이 주인공이 되는 레이아웃 |

### 1.2 비주얼 컨셉

**"따뜻한 파스텔 + Glassmorphism"**

- 살구색/연분홍 파스텔 톤의 따뜻한 색감
- 반투명 유리 효과로 현대적이고 세련된 느낌
- 부드러운 곡선과 넉넉한 여백
- 사진이 돋보이는 중립적 배경

### 1.3 모바일 우선 (Mobile First)

- 터치 타겟 최소 48px
- 엄지 도달 범위 고려한 하단 네비게이션
- iOS Safe Area 대응
- 반응형 그리드 시스템

---

## 2. 색상 시스템

### 2.1 Primary (브랜드 - 살구/연분홍)

주요 액션, 브랜드 아이덴티티에 사용

| 단계 | HEX | 용도 |
|------|-----|------|
| `primary-50` | `#FFF5F0` | 가장 밝은 배경 |
| `primary-100` | `#FFEBE0` | 섹션 배경 |
| `primary-200` | `#FFD5C2` | 카드 배경, 호버 |
| `primary-300` | `#FFBFA3` | 보조 강조 |
| `primary-400` | `#FFA885` | 아이콘 |
| `primary-500` | `#FF8B66` | **메인 액션 버튼** |
| `primary-600` | `#E67350` | 호버 상태 |
| `primary-700` | `#CC5A3A` | 눌린 상태 |
| `primary-800` | `#B34425` | 텍스트 강조 |
| `primary-900` | `#992E10` | 가장 어두운 |

### 2.2 Secondary (민트/청록)

보조 액션, 성공 상태에 사용

| 단계 | HEX | 용도 |
|------|-----|------|
| `secondary-50` | `#F0FFFC` | 밝은 배경 |
| `secondary-100` | `#CCFFF5` | 카드 배경 |
| `secondary-200` | `#99FFEB` | 호버 |
| `secondary-500` | `#4ECDC4` | **메인 색상** |
| `secondary-600` | `#3DB5AD` | 호버 |
| `secondary-700` | `#2D9E97` | 눌린 상태 |

### 2.3 Accent (따뜻한 핑크)

특별 강조, 알림에 사용

| 단계 | HEX | 용도 |
|------|-----|------|
| `accent-100` | `#FFE0E6` | 밝은 배경 |
| `accent-500` | `#FF6B9D` | **강조 색상** |
| `accent-600` | `#E65585` | 호버 |

### 2.4 Neutral - Cream (크림/아이보리)

배경, 표면에 사용

| 단계 | HEX | 용도 |
|------|-----|------|
| `cream-50` | `#FFFDFB` | **페이지 배경** |
| `cream-100` | `#FFF9F5` | 카드 배경 |
| `cream-200` | `#FFF3EB` | 입력 필드 배경 |
| `cream-300` | `#FFEDE0` | 비활성 상태 |

### 2.5 Neutral - Warm Gray (웜 그레이)

텍스트, 테두리에 사용

| 단계 | HEX | 용도 |
|------|-----|------|
| `warm-gray-50` | `#FAFAF9` | 밝은 배경 |
| `warm-gray-100` | `#F5F5F4` | 구분선 배경 |
| `warm-gray-200` | `#E7E5E4` | 테두리 |
| `warm-gray-300` | `#D6D3D1` | 비활성 테두리 |
| `warm-gray-400` | `#A8A29E` | 플레이스홀더 |
| `warm-gray-500` | `#78716C` | **보조 텍스트** |
| `warm-gray-600` | `#57534E` | 부제목 |
| `warm-gray-700` | `#44403C` | **본문 텍스트** |
| `warm-gray-800` | `#292524` | **제목 텍스트** |
| `warm-gray-900` | `#1C1917` | 가장 어두운 |

### 2.6 Semantic (의미론적 색상)

| 용도 | HEX | TailwindCSS |
|------|-----|-------------|
| 성공 | `#10B981` | `emerald-500` |
| 경고 | `#F59E0B` | `amber-500` |
| 에러 | `#EF4444` | `red-500` |
| 정보 | `#3B82F6` | `blue-500` |

### 2.7 특수 색상

| 용도 | HEX | 설명 |
|------|-----|------|
| 카카오 로그인 | `#FEE500` | 카카오 브랜드 색상 |
| Apple 로그인 | `#000000` | Apple 브랜드 색상 |

---

## 3. 타이포그래피

### 3.1 폰트 패밀리

```css
/* 시스템 폰트 스택 */
font-family:
  -apple-system,           /* iOS, macOS */
  BlinkMacSystemFont,      /* macOS Chrome */
  'Segoe UI',              /* Windows */
  Roboto,                  /* Android */
  'Helvetica Neue',
  Arial,
  'Noto Sans KR',          /* 한글 폴백 */
  sans-serif;
```

### 3.2 크기 스케일

| 클래스 | 크기 | 행간 | 용도 |
|--------|------|------|------|
| `text-xs` | 12px | 1rem | 캡션, 힌트 |
| `text-sm` | 14px | 1.25rem | 보조 텍스트, 라벨 |
| `text-base` | 16px | 1.5rem | **본문 기본** |
| `text-lg` | 18px | 1.75rem | 강조 본문 |
| `text-xl` | 20px | 1.75rem | 소제목 |
| `text-2xl` | 24px | 2rem | 섹션 제목 |
| `text-3xl` | 30px | 2.25rem | 페이지 제목 |
| `text-4xl` | 36px | 2.5rem | 히어로 제목 |

### 3.3 폰트 가중치

| 클래스 | 가중치 | 용도 |
|--------|--------|------|
| `font-normal` | 400 | 본문 텍스트 |
| `font-medium` | 500 | 강조 본문, 라벨 |
| `font-semibold` | 600 | 소제목, 버튼 |
| `font-bold` | 700 | 제목 |

### 3.4 사용 예시

```html
<!-- 페이지 제목 -->
<h1 class="text-3xl font-bold text-warm-gray-800">모아봄</h1>

<!-- 섹션 제목 -->
<h2 class="text-2xl font-semibold text-warm-gray-800">사진 타임라인</h2>

<!-- 본문 -->
<p class="text-base text-warm-gray-700">가족 아기 사진첩</p>

<!-- 보조 텍스트 -->
<span class="text-sm text-warm-gray-500">3일 전</span>

<!-- 캡션 -->
<span class="text-xs text-warm-gray-400">JPG, 최대 50MB</span>
```

---

## 4. 간격 시스템

### 4.1 간격 스케일

| 클래스 | 크기 | 용도 |
|--------|------|------|
| `0.5` | 2px | 미세 간격 |
| `1` | 4px | 아이콘 내부 |
| `2` | 8px | 요소 간격 (밀착) |
| `3` | 12px | 요소 간격 (기본) |
| `4` | 16px | 컴포넌트 간격 |
| `5` | 20px | 섹션 내 간격 |
| `6` | 24px | 섹션 간격 |
| `8` | 32px | 페이지 패딩 |
| `10` | 40px | 큰 섹션 간격 |
| `12` | 48px | 페이지 섹션 |
| `16` | 64px | 히어로 섹션 |

### 4.2 모바일 기준 간격

| 요소 | 간격 | 클래스 |
|------|------|--------|
| 페이지 좌우 패딩 | 16px | `px-4` |
| 카드 내부 패딩 | 16-24px | `p-4` ~ `p-6` |
| 버튼 패딩 | 12x16px | `py-3 px-4` |
| 입력 필드 패딩 | 12x16px | `py-3 px-4` |
| 리스트 아이템 | 12x16px | `py-3 px-4` |
| 사진 그리드 간격 | 2-8px | `gap-0.5` ~ `gap-2` |
| 카드 간격 | 16px | `gap-4` |

---

## 5. 아이콘 시스템

### 5.1 Heroicons

Tailwind 공식 아이콘 라이브러리 사용

**설치:**
```ruby
# Gemfile
gem "heroicon", "~> 1.0"
```

**사용법:**
```erb
<%# Outline (라인) - 기본 %>
<%= heroicon "home", variant: :outline, options: { class: "w-6 h-6" } %>

<%# Solid (채움) - 활성 상태 %>
<%= heroicon "home", variant: :solid, options: { class: "w-6 h-6" } %>

<%# Mini (20x20) - 작은 크기 %>
<%= heroicon "home", variant: :mini, options: { class: "w-5 h-5" } %>
```

### 5.2 아이콘 크기

| 용도 | 크기 | 클래스 |
|------|------|--------|
| 인라인 텍스트 | 16px | `w-4 h-4` |
| 작은 버튼 | 20px | `w-5 h-5` |
| 기본 | 24px | `w-6 h-6` |
| 탭바 | 24px | `w-6 h-6` |
| 큰 아이콘 | 32px | `w-8 h-8` |
| 빈 상태 | 48px | `w-12 h-12` |

### 5.3 아이콘 매핑

| 기능 | Heroicon 이름 | 변형 |
|------|--------------|------|
| 홈 | `home` | outline/solid |
| 앨범/갤러리 | `photo` | outline/solid |
| 업로드/추가 | `plus-circle` | outline/solid |
| 알림 | `bell` | outline/solid |
| 설정 | `cog-6-tooth` | outline/solid |
| 검색 | `magnifying-glass` | outline |
| 뒤로 가기 | `arrow-left` | outline |
| 닫기 | `x-mark` | outline |
| 좋아요 | `heart` | outline/solid |
| 댓글 | `chat-bubble-oval-left` | outline/solid |
| 공유 | `share` | outline |
| 삭제 | `trash` | outline |
| 편집 | `pencil` | outline |
| 카메라 | `camera` | outline/solid |
| 사용자 | `user` | outline/solid |
| 가족/그룹 | `user-group` | outline/solid |
| 아이 | `face-smile` | outline/solid |
| 캘린더 | `calendar` | outline/solid |
| 체크 | `check` | outline |
| 정보 | `information-circle` | outline |
| 경고 | `exclamation-triangle` | outline |

### 5.4 탭바 아이콘 예시

```erb
<nav class="tabbar">
  <%= link_to root_path, class: "tab-item #{active ? 'active' : ''}" do %>
    <%= heroicon "home",
        variant: active ? :solid : :outline,
        options: { class: "w-6 h-6" } %>
    <span class="text-xs mt-1">홈</span>
  <% end %>
</nav>
```

---

## 6. 컴포넌트 라이브러리

### 6.1 버튼 (Buttons)

#### Primary Button
주요 액션에 사용

```html
<button class="w-full bg-primary-500 text-white
               py-3 px-6 rounded-2xl font-semibold
               hover:bg-primary-600 active:bg-primary-700
               transition-colors duration-200">
  사진 업로드
</button>
```

#### Secondary Button (Glass)
보조 액션에 사용

```html
<button class="bg-white/60 backdrop-blur-sm
               border border-primary-200 text-primary-700
               py-3 px-6 rounded-2xl font-semibold
               hover:bg-white/80 active:bg-white/90
               transition-colors duration-200">
  취소
</button>
```

#### Ghost Button
텍스트 버튼

```html
<button class="text-primary-600 py-2 px-4 rounded-xl font-medium
               hover:bg-primary-50 active:bg-primary-100
               transition-colors duration-200">
  더보기
</button>
```

#### Icon Button
아이콘만 있는 버튼

```html
<button class="p-3 rounded-full
               bg-white/60 backdrop-blur-sm
               hover:bg-white/80 active:bg-white/90
               transition-all duration-200">
  <%= heroicon "heart", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-600" } %>
</button>
```

#### 버튼 상태

```html
<!-- 비활성 -->
<button class="... opacity-50 cursor-not-allowed" disabled>
  비활성
</button>

<!-- 로딩 -->
<button class="... cursor-wait" disabled>
  <svg class="animate-spin w-5 h-5 mr-2">...</svg>
  처리 중...
</button>
```

### 6.2 카드 (Cards)

#### Glass Card
Glassmorphism 효과 카드

```html
<div class="bg-white/70 backdrop-blur-md
            border border-white/20
            rounded-2xl shadow-lg p-4">
  <!-- 콘텐츠 -->
</div>
```

#### Elevated Card
그림자가 있는 카드

```html
<div class="bg-cream-100 rounded-3xl
            shadow-[0_4px_20px_rgba(255,139,102,0.12)]
            p-5">
  <!-- 콘텐츠 -->
</div>
```

#### Flat Card
플랫 스타일 카드

```html
<div class="bg-cream-50 rounded-2xl
            border border-cream-300 p-4">
  <!-- 콘텐츠 -->
</div>
```

#### Photo Card
사진 카드

```html
<article class="bg-white rounded-2xl shadow-md overflow-hidden">
  <img src="..." class="w-full aspect-square object-cover" alt="...">
  <div class="p-3">
    <p class="text-sm text-warm-gray-700 truncate">첫 걸음마</p>
    <p class="text-xs text-warm-gray-500 mt-1">3일 전</p>
  </div>
</article>
```

### 6.3 입력 필드 (Inputs)

#### Text Input
기본 텍스트 입력

```html
<div>
  <label class="block text-sm font-medium text-warm-gray-700 mb-1">
    닉네임
  </label>
  <input type="text"
         class="w-full px-4 py-3
                bg-cream-100 border border-cream-300 rounded-xl
                text-warm-gray-800 placeholder:text-warm-gray-400
                focus:outline-none focus:border-primary-400
                focus:ring-2 focus:ring-primary-200
                transition-all duration-200"
         placeholder="닉네임을 입력하세요">
</div>
```

#### Glass Input
유리 효과 입력

```html
<input type="text"
       class="w-full px-4 py-3
              bg-white/60 backdrop-blur-sm border border-white/30 rounded-xl
              text-warm-gray-800 placeholder:text-warm-gray-400
              focus:bg-white/80 focus:border-primary-400
              transition-all duration-200"
       placeholder="검색...">
```

#### File Input
파일 업로드

```html
<input type="file"
       class="block w-full text-sm text-warm-gray-500
              file:mr-4 file:py-2 file:px-4
              file:rounded-full file:border-0
              file:text-sm file:font-semibold
              file:bg-primary-50 file:text-primary-700
              hover:file:bg-primary-100
              cursor-pointer">
```

#### Select
선택 입력

```html
<select class="w-full px-4 py-3
               bg-cream-100 border border-cream-300 rounded-xl
               text-warm-gray-800
               focus:outline-none focus:border-primary-400
               focus:ring-2 focus:ring-primary-200">
  <option value="">선택하세요</option>
  <option value="1">옵션 1</option>
</select>
```

### 6.4 알림/메시지 (Alerts)

#### Success
```html
<div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4">
  <div class="flex items-center gap-3">
    <%= heroicon "check-circle", variant: :solid, options: { class: "w-5 h-5 text-emerald-500" } %>
    <p class="text-emerald-800 text-sm font-medium">성공적으로 저장되었습니다.</p>
  </div>
</div>
```

#### Error
```html
<div class="bg-red-50 border border-red-200 rounded-xl p-4">
  <div class="flex items-center gap-3">
    <%= heroicon "exclamation-circle", variant: :solid, options: { class: "w-5 h-5 text-red-500" } %>
    <p class="text-red-800 text-sm font-medium">오류가 발생했습니다.</p>
  </div>
</div>
```

#### Warning
```html
<div class="bg-amber-50 border border-amber-200 rounded-xl p-4">
  <div class="flex items-center gap-3">
    <%= heroicon "exclamation-triangle", variant: :solid, options: { class: "w-5 h-5 text-amber-500" } %>
    <p class="text-amber-800 text-sm font-medium">주의가 필요합니다.</p>
  </div>
</div>
```

#### Info
```html
<div class="bg-blue-50 border border-blue-200 rounded-xl p-4">
  <div class="flex items-center gap-3">
    <%= heroicon "information-circle", variant: :solid, options: { class: "w-5 h-5 text-blue-500" } %>
    <p class="text-blue-800 text-sm font-medium">안내 메시지입니다.</p>
  </div>
</div>
```

### 6.5 네비게이션 (Navigation)

#### Header
```html
<header class="fixed top-0 left-0 right-0 z-50
               bg-white/80 backdrop-blur-md
               border-b border-cream-200">
  <div class="flex items-center justify-between px-4 h-14">
    <!-- 로고 -->
    <a href="/" class="flex items-center gap-2">
      <span class="text-2xl">🌸</span>
      <span class="text-lg font-bold text-warm-gray-800">모아봄</span>
    </a>
    <!-- 액션 -->
    <button class="p-2 rounded-full hover:bg-cream-100">
      <%= heroicon "bell", variant: :outline, options: { class: "w-6 h-6 text-warm-gray-600" } %>
    </button>
  </div>
</header>
```

#### Tab Bar
```html
<nav class="fixed bottom-0 left-0 right-0 z-50
            bg-white/90 backdrop-blur-md
            border-t border-cream-200
            safe-area-inset-bottom">
  <div class="flex items-center justify-around h-16">
    <!-- Tab Item -->
    <a href="/" class="flex flex-col items-center justify-center py-2 px-4
                       text-warm-gray-500 hover:text-primary-500
                       transition-colors duration-200">
      <%= heroicon "home", variant: :outline, options: { class: "w-6 h-6" } %>
      <span class="text-xs mt-1">홈</span>
    </a>

    <!-- Active Tab -->
    <a href="/photos" class="flex flex-col items-center justify-center py-2 px-4
                             text-primary-500">
      <%= heroicon "photo", variant: :solid, options: { class: "w-6 h-6" } %>
      <span class="text-xs mt-1 font-medium">앨범</span>
    </a>

    <!-- Center Action Button -->
    <button class="flex items-center justify-center
                   w-14 h-14 -mt-4
                   bg-primary-500 text-white rounded-full
                   shadow-lg shadow-primary-500/30
                   hover:bg-primary-600 active:bg-primary-700
                   transition-colors duration-200">
      <%= heroicon "plus", variant: :solid, options: { class: "w-7 h-7" } %>
    </button>

    <!-- More tabs... -->
  </div>
</nav>
```

### 6.6 빈 상태 (Empty States)

```html
<div class="flex flex-col items-center justify-center py-16 px-4 text-center">
  <%= heroicon "photo", variant: :outline, options: { class: "w-16 h-16 text-warm-gray-300" } %>
  <h3 class="mt-4 text-lg font-medium text-warm-gray-800">아직 사진이 없어요</h3>
  <p class="mt-2 text-sm text-warm-gray-500">소중한 순간을 가족과 공유해보세요.</p>
  <button class="mt-6 bg-primary-500 text-white py-3 px-6 rounded-2xl font-semibold
                 hover:bg-primary-600 transition-colors duration-200">
    첫 사진 업로드
  </button>
</div>
```

---

## 7. 레이아웃 패턴

### 7.1 페이지 구조

```html
<body class="bg-cream-50 dark:bg-warm-gray-900">
  <!-- 고정 헤더 (56px) -->
  <header class="fixed top-0 h-14 ...">...</header>

  <!-- 메인 콘텐츠 -->
  <main class="pt-14 pb-20 min-h-screen">
    <div class="px-4 py-6">
      <!-- 페이지 콘텐츠 -->
    </div>
  </main>

  <!-- 고정 탭바 (64px + Safe Area) -->
  <nav class="fixed bottom-0 h-16 safe-area-inset-bottom ...">...</nav>
</body>
```

### 7.2 사진 그리드

#### 3열 그리드 (Instagram 스타일)
```html
<div class="grid grid-cols-3 gap-0.5">
  <div class="aspect-square bg-cream-200 overflow-hidden">
    <img src="..." class="w-full h-full object-cover">
  </div>
  <!-- 더 많은 사진... -->
</div>
```

#### 2열 카드 그리드
```html
<div class="grid grid-cols-2 gap-4 px-4">
  <article class="bg-white rounded-2xl shadow overflow-hidden">
    <img src="..." class="w-full aspect-square object-cover">
    <div class="p-3">...</div>
  </article>
  <!-- 더 많은 카드... -->
</div>
```

#### Bento 그리드
```html
<div class="grid grid-cols-2 gap-2 px-4">
  <div class="col-span-2 aspect-video bg-cream-200 rounded-2xl overflow-hidden">
    <!-- 큰 사진 -->
  </div>
  <div class="aspect-square bg-cream-200 rounded-xl overflow-hidden">
    <!-- 작은 사진 1 -->
  </div>
  <div class="aspect-square bg-cream-200 rounded-xl overflow-hidden">
    <!-- 작은 사진 2 -->
  </div>
</div>
```

### 7.3 리스트 레이아웃

```html
<ul class="divide-y divide-cream-200">
  <li class="flex items-center gap-4 py-4 px-4">
    <div class="w-12 h-12 bg-cream-200 rounded-full"></div>
    <div class="flex-1 min-w-0">
      <p class="text-warm-gray-800 font-medium truncate">제목</p>
      <p class="text-sm text-warm-gray-500 truncate">설명</p>
    </div>
    <%= heroicon "chevron-right", variant: :outline, options: { class: "w-5 h-5 text-warm-gray-400" } %>
  </li>
</ul>
```

### 7.4 폼 레이아웃

```html
<form class="space-y-6 px-4 py-6 max-w-lg mx-auto">
  <!-- 입력 필드들 -->
  <div class="space-y-4">
    <div>
      <label>...</label>
      <input>
    </div>
    <div>
      <label>...</label>
      <input>
    </div>
  </div>

  <!-- 제출 버튼 -->
  <button type="submit" class="w-full ...">저장</button>
</form>
```

### 7.5 반응형 브레이크포인트

| 브레이크포인트 | 크기 | 용도 |
|---------------|------|------|
| (기본) | < 640px | 모바일 |
| `sm:` | >= 640px | 큰 모바일 |
| `md:` | >= 768px | 태블릿 |
| `lg:` | >= 1024px | 데스크톱 |

```html
<!-- 반응형 그리드 예시 -->
<div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
  <!-- 콘텐츠 -->
</div>
```

---

## 8. 다크 모드

### 8.1 다크 모드 색상

| 요소 | 라이트 | 다크 |
|------|--------|------|
| 페이지 배경 | `cream-50` | `warm-gray-900` |
| 카드 배경 | `white` / `cream-100` | `warm-gray-800` |
| 팝업 배경 | `white` | `warm-gray-700` |
| 테두리 | `cream-200` | `warm-gray-700` |
| 주요 텍스트 | `warm-gray-800` | `warm-gray-100` |
| 보조 텍스트 | `warm-gray-500` | `warm-gray-400` |

### 8.2 다크 모드 적용

```html
<!-- 시스템 설정 따르기 -->
<body class="bg-cream-50 dark:bg-warm-gray-900
             text-warm-gray-800 dark:text-warm-gray-100">
```

```html
<!-- Glass 카드 - 다크 모드 -->
<div class="bg-white/70 dark:bg-warm-gray-800/70
            backdrop-blur-md
            border border-white/20 dark:border-warm-gray-700/30">
```

### 8.3 다크 모드 토글

```html
<!-- 수동 토글 버튼 -->
<button onclick="document.documentElement.classList.toggle('dark')"
        class="p-2 rounded-full hover:bg-cream-100 dark:hover:bg-warm-gray-800">
  <!-- 라이트 모드일 때 -->
  <span class="dark:hidden">
    <%= heroicon "moon", variant: :outline, options: { class: "w-6 h-6" } %>
  </span>
  <!-- 다크 모드일 때 -->
  <span class="hidden dark:block">
    <%= heroicon "sun", variant: :outline, options: { class: "w-6 h-6" } %>
  </span>
</button>
```

### 8.4 시스템 설정 연동 (JavaScript)

```javascript
// 시스템 설정 감지 및 적용
if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.documentElement.classList.add('dark');
}

// 변경 감지
window.matchMedia('(prefers-color-scheme: dark)')
  .addEventListener('change', e => {
    document.documentElement.classList.toggle('dark', e.matches);
  });
```

---

## 9. 접근성 가이드

### 9.1 색상 대비

| 항목 | 최소 기준 | 권장 |
|------|----------|------|
| 일반 텍스트 | 4.5:1 | 7:1 |
| 큰 텍스트 (18px+) | 3:1 | 4.5:1 |
| UI 컴포넌트 | 3:1 | 4.5:1 |

### 9.2 터치 타겟

- **최소 크기**: 44x44px (iOS), 48x48dp (Android)
- **권장 크기**: 48x48px
- **간격**: 최소 8px

```html
<!-- Good: 충분한 터치 영역 -->
<button class="p-3 min-w-[48px] min-h-[48px]">
  <%= heroicon "heart", options: { class: "w-6 h-6" } %>
</button>
```

### 9.3 포커스 상태

```html
<!-- 명확한 포커스 링 -->
<button class="... focus:outline-none focus:ring-2
               focus:ring-primary-500 focus:ring-offset-2">
```

### 9.4 스크린 리더 지원

```html
<!-- ARIA 라벨 -->
<button aria-label="사진 업로드">
  <%= heroicon "plus", options: { class: "w-6 h-6" } %>
</button>

<!-- 숨김 텍스트 -->
<span class="sr-only">새 알림 3개</span>
```

### 9.5 모션 감소

```css
/* prefers-reduced-motion 지원 */
@media (prefers-reduced-motion: reduce) {
  *, ::before, ::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### 9.6 체크리스트

- [ ] 색상 대비 4.5:1 이상
- [ ] 터치 타겟 48px 이상
- [ ] 폰트 크기 16px 이상 (본문)
- [ ] 포커스 상태 명확히 표시
- [ ] 색상만으로 정보 전달하지 않기
- [ ] ARIA 라벨 적절히 사용
- [ ] 시맨틱 HTML 사용
- [ ] `prefers-reduced-motion` 지원
- [ ] 키보드 네비게이션 가능

---

## 10. TailwindCSS 설정

### 10.1 커스텀 색상 설정

`app/assets/tailwind/application.css`에 추가:

```css
@import "tailwindcss";

@theme {
  /* Primary - 살구/연분홍 */
  --color-primary-50: #FFF5F0;
  --color-primary-100: #FFEBE0;
  --color-primary-200: #FFD5C2;
  --color-primary-300: #FFBFA3;
  --color-primary-400: #FFA885;
  --color-primary-500: #FF8B66;
  --color-primary-600: #E67350;
  --color-primary-700: #CC5A3A;
  --color-primary-800: #B34425;
  --color-primary-900: #992E10;

  /* Secondary - 민트 */
  --color-secondary-50: #F0FFFC;
  --color-secondary-100: #CCFFF5;
  --color-secondary-200: #99FFEB;
  --color-secondary-500: #4ECDC4;
  --color-secondary-600: #3DB5AD;
  --color-secondary-700: #2D9E97;

  /* Accent - 핑크 */
  --color-accent-100: #FFE0E6;
  --color-accent-500: #FF6B9D;
  --color-accent-600: #E65585;

  /* Cream - 배경 */
  --color-cream-50: #FFFDFB;
  --color-cream-100: #FFF9F5;
  --color-cream-200: #FFF3EB;
  --color-cream-300: #FFEDE0;

  /* Warm Gray - 텍스트/테두리 */
  --color-warm-gray-50: #FAFAF9;
  --color-warm-gray-100: #F5F5F4;
  --color-warm-gray-200: #E7E5E4;
  --color-warm-gray-300: #D6D3D1;
  --color-warm-gray-400: #A8A29E;
  --color-warm-gray-500: #78716C;
  --color-warm-gray-600: #57534E;
  --color-warm-gray-700: #44403C;
  --color-warm-gray-800: #292524;
  --color-warm-gray-900: #1C1917;
}
```

### 10.2 컴포넌트 클래스

```css
@layer components {
  /* Glass Effect */
  .glass {
    @apply bg-white/70 backdrop-blur-md border border-white/20 shadow-lg;
  }

  .glass-dark {
    @apply bg-warm-gray-800/70 backdrop-blur-md border border-warm-gray-700/30;
  }

  /* Buttons */
  .btn-primary {
    @apply bg-primary-500 text-white py-3 px-6 rounded-2xl font-semibold
           hover:bg-primary-600 active:bg-primary-700
           transition-colors duration-200
           focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2;
  }

  .btn-secondary {
    @apply bg-white/60 backdrop-blur-sm border border-primary-200
           text-primary-700 py-3 px-6 rounded-2xl font-semibold
           hover:bg-white/80 active:bg-white/90
           transition-colors duration-200;
  }

  .btn-ghost {
    @apply text-primary-600 py-2 px-4 rounded-xl font-medium
           hover:bg-primary-50 active:bg-primary-100
           transition-colors duration-200;
  }

  /* Cards */
  .card-glass {
    @apply bg-white/70 backdrop-blur-md border border-white/20
           rounded-2xl shadow-lg p-4;
  }

  .card-elevated {
    @apply bg-cream-100 rounded-3xl
           shadow-[0_4px_20px_rgba(255,139,102,0.12)] p-5;
  }

  /* Inputs */
  .input-text {
    @apply w-full px-4 py-3
           bg-cream-100 border border-cream-300 rounded-xl
           text-warm-gray-800 placeholder:text-warm-gray-400
           focus:outline-none focus:border-primary-400
           focus:ring-2 focus:ring-primary-200
           transition-all duration-200;
  }

  /* Navigation */
  .tab-item {
    @apply flex flex-col items-center justify-center py-2 px-4
           text-warm-gray-500 hover:text-primary-500
           transition-colors duration-200;
  }

  .tab-item-active {
    @apply text-primary-500;
  }
}
```

### 10.3 유틸리티 클래스

```css
@layer utilities {
  /* Safe Area */
  .safe-area-inset-bottom {
    padding-bottom: env(safe-area-inset-bottom);
  }

  .safe-area-inset-top {
    padding-top: env(safe-area-inset-top);
  }

  /* Custom Shadows */
  .shadow-warm {
    box-shadow: 0 4px 20px rgba(255, 139, 102, 0.12);
  }

  .shadow-glass {
    box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
  }
}
```

---

## 부록: 빠른 참조

### 자주 쓰는 클래스 조합

```html
<!-- 페이지 배경 -->
class="bg-cream-50 dark:bg-warm-gray-900 min-h-screen"

<!-- 헤더 -->
class="fixed top-0 inset-x-0 h-14 bg-white/80 dark:bg-warm-gray-900/80 backdrop-blur-md border-b border-cream-200 dark:border-warm-gray-800 z-50"

<!-- 탭바 -->
class="fixed bottom-0 inset-x-0 h-16 bg-white/90 dark:bg-warm-gray-900/90 backdrop-blur-md border-t border-cream-200 dark:border-warm-gray-800 safe-area-inset-bottom z-50"

<!-- 메인 콘텐츠 -->
class="pt-14 pb-20 px-4"

<!-- Glass 카드 -->
class="bg-white/70 dark:bg-warm-gray-800/70 backdrop-blur-md border border-white/20 dark:border-warm-gray-700/30 rounded-2xl shadow-lg p-4"

<!-- Primary 버튼 -->
class="w-full bg-primary-500 text-white py-3 px-6 rounded-2xl font-semibold hover:bg-primary-600 transition-colors"

<!-- 입력 필드 -->
class="w-full px-4 py-3 bg-cream-100 dark:bg-warm-gray-800 border border-cream-300 dark:border-warm-gray-700 rounded-xl focus:border-primary-400 focus:ring-2 focus:ring-primary-200"

<!-- 텍스트 -->
class="text-warm-gray-800 dark:text-warm-gray-100"        /* 제목 */
class="text-warm-gray-700 dark:text-warm-gray-200"        /* 본문 */
class="text-warm-gray-500 dark:text-warm-gray-400"        /* 보조 */
```

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2025-12-16 | 초기 버전 작성 |
