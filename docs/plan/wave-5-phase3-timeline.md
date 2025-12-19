# Wave 5: Phase 3 - 타임라인 구현

> 선행 조건: Wave 4 완료
> 병렬 실행: Phase 1 ∥ Phase 2 ∥ Phase 3

---

## 문제 정의

대시보드 메인 화면에 일자별 사진 타임라인 구현

**현재 상태:**
- 대시보드에 타임라인 없음
- 사진을 일자별로 그룹화하여 표시하는 기능 부재

**목표:**
1. 사진을 촬영 날짜(`taken_at`) 기준으로 그룹화
2. 날짜별 헤더와 함께 타임라인 형식으로 표시
3. 무한 스크롤 또는 페이지네이션 지원
4. 빈 상태 처리 (사진 없을 때)
5. 로딩 상태 표시

**UI 컨셉:**
```
┌─────────────────────────────────┐
│  2025년 1월 15일 (수)            │
│  ┌───┬───┬───┐                  │
│  │   │   │   │ 3열 그리드       │
│  └───┴───┴───┘                  │
├─────────────────────────────────┤
│  2025년 1월 14일 (화)            │
│  ┌───┬───┬───┐                  │
│  │   │   │   │                  │
│  └───┴───┴───┘                  │
└─────────────────────────────────┘
```

---

## TDD 작업 순서

### 5.3.1 모델: 날짜별 그룹화

#### RED: 테스트 작성

- [ ] **RED**: 사진 날짜별 그룹화 테스트

```ruby
# test/models/photo_test.rb
test "should group photos by date" do
  family = families(:kim_family)

  # 오늘 사진 2장
  today_photo1 = create_photo(family, taken_at: Time.current)
  today_photo2 = create_photo(family, taken_at: Time.current)

  # 어제 사진 1장
  yesterday_photo = create_photo(family, taken_at: 1.day.ago)

  # 그룹화
  grouped = Photo.for_family(family).group_by_date

  assert_equal 2, grouped.keys.size
  assert_equal 2, grouped[Date.current].size
  assert_equal 1, grouped[Date.yesterday].size
end

test "should order grouped photos by date descending" do
  family = families(:kim_family)

  old_photo = create_photo(family, taken_at: 1.week.ago)
  recent_photo = create_photo(family, taken_at: Time.current)

  grouped = Photo.for_family(family).group_by_date

  # 최신 날짜가 먼저
  assert_equal Date.current, grouped.keys.first
end

test "should scope photos by month" do
  family = families(:kim_family)

  # 1월 사진
  jan_photo = create_photo(family, taken_at: Date.new(2025, 1, 15))

  # 2월 사진
  feb_photo = create_photo(family, taken_at: Date.new(2025, 2, 10))

  jan_photos = Photo.for_family(family).by_month(2025, 1)

  assert_includes jan_photos, jan_photo
  assert_not_includes jan_photos, feb_photo
end

private

def create_photo(family, taken_at:)
  family.photos.create!(
    uploader: users(:mom),
    taken_at: taken_at,
    image: fixture_file_upload("photo.jpg", "image/jpeg")
  )
end
```

#### GREEN: 모델 메서드 구현

- [ ] **GREEN**: Photo 모델에 그룹화 메서드 추가

```ruby
# app/models/photo.rb
class Photo < ApplicationRecord
  # ...

  scope :for_family, ->(family) { where(family: family) }
  scope :recent, -> { order(taken_at: :desc) }
  scope :by_month, ->(year, month) {
    date = Date.new(year, month)
    where(taken_at: date.beginning_of_month..date.end_of_month)
  }

  # 날짜별 그룹화
  def self.group_by_date
    recent.group_by { |photo| photo.taken_at.to_date }
  end

  # 타임라인용 (날짜 헤더 + 사진)
  def self.timeline
    group_by_date.map do |date, photos|
      {
        date: date,
        photos: photos,
        count: photos.size
      }
    end
  end
end
```

#### REFACTOR: 쿼리 최적화

- [ ] **REFACTOR**: N+1 방지 및 쿼리 최적화

```ruby
# app/models/photo.rb
class Photo < ApplicationRecord
  # ...

  # 타임라인용 최적화 쿼리
  scope :timeline_for, ->(family, page: 1, per_page: 50) {
    for_family(family)
      .recent
      .includes(:uploader, :child, image_attachment: :blob)
      .limit(per_page)
      .offset((page - 1) * per_page)
  }

  # 날짜별 그룹화 (효율적)
  def self.group_by_date
    # 이미 정렬된 상태에서 그룹화
    all.group_by { |photo| photo.taken_at.to_date }
  end
end
```

---

### 5.3.2 컨트롤러: 타임라인 데이터 제공

#### RED: 테스트 작성

- [ ] **RED**: 홈 컨트롤러 타임라인 테스트

```ruby
# test/controllers/home_controller_test.rb
require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  test "should get index with timeline" do
    get root_path

    assert_response :success
    assert_not_nil assigns(:timeline)
    assert_kind_of Array, assigns(:timeline)
  end

  test "should group photos by date in timeline" do
    # 오늘 사진
    today_photo = create_photo(@family, taken_at: Time.current)

    # 어제 사진
    yesterday_photo = create_photo(@family, taken_at: 1.day.ago)

    get root_path

    timeline = assigns(:timeline)
    assert_equal 2, timeline.size

    # 최신 날짜가 먼저
    assert_equal Date.current, timeline.first[:date]
    assert_equal Date.yesterday, timeline.second[:date]
  end

  test "should show empty state when no photos" do
    @family.photos.destroy_all

    get root_path

    assert_response :success
    assert_select ".empty-state", text: /아직 사진이 없어요/
  end

  private

  def create_photo(family, taken_at:)
    family.photos.create!(
      uploader: @user,
      taken_at: taken_at,
      image: fixture_file_upload("photo.jpg", "image/jpeg")
    )
  end
end
```

#### GREEN: 컨트롤러 구현

- [ ] **GREEN**: 홈 컨트롤러에 타임라인 로직 추가

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  layout "dashboard"

  def index
    @family = current_family
    @photos = @family.photos.timeline_for(@family, page: params[:page] || 1)
    @timeline = @photos.group_by_date
  end
end
```

#### REFACTOR: 서비스 객체 분리

- [ ] **REFACTOR**: 타임라인 로직을 서비스로 분리

```ruby
# app/services/timeline_service.rb
class TimelineService
  def initialize(family, page: 1, per_page: 50)
    @family = family
    @page = page
    @per_page = per_page
  end

  def call
    photos = fetch_photos
    timeline = build_timeline(photos)

    Result.new(
      timeline: timeline,
      total_count: @family.photos.count,
      current_page: @page,
      has_more: has_more_photos?(photos)
    )
  end

  private

  Result = Data.define(:timeline, :total_count, :current_page, :has_more)

  def fetch_photos
    @family.photos.timeline_for(@family, page: @page, per_page: @per_page)
  end

  def build_timeline(photos)
    photos.group_by_date.map do |date, date_photos|
      {
        date: date,
        date_label: format_date(date),
        photos: date_photos,
        count: date_photos.size
      }
    end
  end

  def format_date(date)
    if date == Date.current
      "오늘"
    elsif date == Date.yesterday
      "어제"
    else
      I18n.l(date, format: :long) # "2025년 1월 15일 (수)"
    end
  end

  def has_more_photos?(photos)
    photos.size == @per_page
  end
end

# app/controllers/home_controller.rb
class HomeController < ApplicationController
  layout "dashboard"

  def index
    @family = current_family
    result = TimelineService.new(@family, page: params[:page] || 1).call
    @timeline = result.timeline
    @has_more = result.has_more
  end
end
```

---

### 5.3.3 뷰: 타임라인 UI

#### RED: 시스템 테스트 작성

- [ ] **RED**: 타임라인 UI 시스템 테스트

```ruby
# test/system/timeline_test.rb
require "application_system_test_case"

class TimelineTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  test "displays timeline with grouped photos" do
    # 오늘 사진 3장
    3.times { create_photo(@family, taken_at: Time.current) }

    # 어제 사진 2장
    2.times { create_photo(@family, taken_at: 1.day.ago) }

    visit root_path

    # 날짜 헤더
    assert_text "오늘"
    assert_text "어제"

    # 사진 개수
    assert_selector ".timeline-date:first-child .photo-grid .photo-item", count: 3
    assert_selector ".timeline-date:nth-child(2) .photo-grid .photo-item", count: 2
  end

  test "shows empty state when no photos" do
    @family.photos.destroy_all

    visit root_path

    assert_selector ".empty-state"
    assert_text "아직 사진이 없어요"
    assert_link "첫 사진 업로드"
  end

  test "clicking photo opens detail view" do
    photo = create_photo(@family, taken_at: Time.current, caption: "첫 걸음마")

    visit root_path

    click_on "첫 걸음마"

    assert_current_path family_photo_path(@family, photo)
  end

  private

  def create_photo(family, taken_at:, caption: "테스트 사진")
    family.photos.create!(
      uploader: @user,
      taken_at: taken_at,
      caption: caption,
      image: fixture_file_upload("photo.jpg", "image/jpeg")
    )
  end
end
```

#### GREEN: 타임라인 뷰 구현

- [ ] **GREEN**: 타임라인 뷰 작성

```erb
<%# app/views/home/index.html.erb %>
<div class="pb-6">
  <%# 빠른 메뉴 %>
  <%= render "quick_actions" %>

  <%# 타임라인 %>
  <% if @timeline.present? %>
    <%= render "timeline" %>
  <% else %>
    <%= render "empty_state" %>
  <% end %>
</div>

<%# app/views/home/_timeline.html.erb %>
<div class="space-y-6">
  <% @timeline.each do |group| %>
    <section class="timeline-date">
      <%# 날짜 헤더 %>
      <div class="flex items-center justify-between px-4 mb-3">
        <h2 class="text-lg font-semibold text-warm-gray-800">
          <%= group[:date_label] %>
        </h2>
        <span class="text-sm text-warm-gray-500">
          <%= group[:count] %>장
        </span>
      </div>

      <%# 사진 그리드 (3열) %>
      <div class="photo-grid grid grid-cols-3 gap-0.5">
        <% group[:photos].each do |photo| %>
          <%= link_to family_photo_path(current_family, photo),
                      class: "photo-item block aspect-square overflow-hidden
                              bg-cream-200 hover:opacity-90 transition-opacity" do %>
            <%= image_tag photo.thumbnail_url,
                          loading: "lazy",
                          alt: photo.caption || "사진",
                          class: "w-full h-full object-cover" %>
          <% end %>
        <% end %>
      </div>
    </section>
  <% end %>

  <%# 더보기 버튼 (무한 스크롤 대신) %>
  <% if @has_more %>
    <div class="text-center py-4">
      <%= link_to "더 보기",
                  root_path(page: (params[:page] || 1).to_i + 1),
                  class: "text-primary-600 font-medium hover:text-primary-700" %>
    </div>
  <% end %>
</div>

<%# app/views/home/_empty_state.html.erb %>
<div class="empty-state flex flex-col items-center justify-center py-16 px-4 text-center">
  <%= heroicon "photo", variant: :outline,
      options: { class: "w-16 h-16 text-warm-gray-300" } %>

  <h3 class="mt-4 text-lg font-medium text-warm-gray-800">
    아직 사진이 없어요
  </h3>

  <p class="mt-2 text-sm text-warm-gray-500">
    소중한 순간을 가족과 공유해보세요.
  </p>

  <%= link_to "첫 사진 업로드",
              new_family_photo_path(current_family),
              class: "mt-6 bg-primary-500 text-white py-3 px-6 rounded-2xl
                      font-semibold hover:bg-primary-600 transition-colors" %>
</div>
```

#### REFACTOR: 컴포넌트 분리

- [ ] **REFACTOR**: 타임라인 컴포넌트 분리

```erb
<%# app/views/home/_timeline.html.erb %>
<div class="space-y-6">
  <% @timeline.each do |group| %>
    <%= render "timeline_date_section", group: group %>
  <% end %>

  <%= render "timeline_load_more" if @has_more %>
</div>

<%# app/views/home/_timeline_date_section.html.erb %>
<section class="timeline-date" data-date="<%= group[:date] %>">
  <%= render "timeline_date_header", group: group %>
  <%= render "timeline_photo_grid", photos: group[:photos] %>
</section>

<%# app/views/home/_timeline_date_header.html.erb %>
<div class="flex items-center justify-between px-4 mb-3">
  <h2 class="text-lg font-semibold text-warm-gray-800">
    <%= group[:date_label] %>
  </h2>
  <span class="text-sm text-warm-gray-500">
    <%= group[:count] %>장
  </span>
</div>

<%# app/views/home/_timeline_photo_grid.html.erb %>
<div class="photo-grid grid grid-cols-3 gap-0.5">
  <% photos.each do |photo| %>
    <%= render "photo_thumbnail", photo: photo %>
  <% end %>
</div>

<%# app/views/home/_photo_thumbnail.html.erb %>
<%= link_to family_photo_path(current_family, photo),
            class: "photo-item block aspect-square overflow-hidden
                    bg-cream-200 hover:opacity-90 transition-opacity",
            data: { turbo_frame: "photo_modal" } do %>
  <%= image_tag photo.thumbnail_url,
                loading: "lazy",
                alt: photo.caption || "사진",
                class: "w-full h-full object-cover" %>
<% end %>

<%# app/views/home/_timeline_load_more.html.erb %>
<div class="text-center py-4">
  <%= link_to "더 보기",
              root_path(page: (params[:page] || 1).to_i + 1),
              data: { turbo_frame: "timeline" },
              class: "text-primary-600 font-medium hover:text-primary-700" %>
</div>
```

---

### 5.3.4 무한 스크롤 (선택 사항)

#### RED: 테스트 작성

- [ ] **RED**: 무한 스크롤 테스트

```ruby
# test/system/infinite_scroll_test.rb
require "application_system_test_case"

class InfiniteScrollTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user

    # 100장의 사진 생성 (50장씩 2페이지)
    100.times do |i|
      create_photo(@family, taken_at: i.days.ago)
    end
  end

  test "loads more photos on scroll" do
    visit root_path

    # 첫 페이지 50장
    assert_selector ".photo-item", count: 50

    # 스크롤 다운
    scroll_to_bottom

    # 2페이지 로딩 대기
    assert_selector ".photo-item", count: 100, wait: 5
  end

  private

  def scroll_to_bottom
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
  end

  def create_photo(family, taken_at:)
    family.photos.create!(
      uploader: @user,
      taken_at: taken_at,
      image: fixture_file_upload("photo.jpg", "image/jpeg")
    )
  end
end
```

#### GREEN: 무한 스크롤 구현

- [ ] **GREEN**: Stimulus 무한 스크롤 컨트롤러

```javascript
// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    hasMore: { type: Boolean, default: true }
  }

  connect() {
    this.observer = new IntersectionObserver(
      entries => this.handleIntersect(entries),
      { threshold: 0.1 }
    )

    if (this.hasPaginationTarget && this.hasMoreValue) {
      this.observer.observe(this.paginationTarget)
    }
  }

  disconnect() {
    this.observer.disconnect()
  }

  async handleIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && this.hasMoreValue) {
        this.loadMore()
      }
    })
  }

  async loadMore() {
    if (!this.hasMoreValue) return

    this.pageValue += 1

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("page", this.pageValue)

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Failed to load more:", error)
    }
  }
}
```

```erb
<%# app/views/home/index.html.erb %>
<div data-controller="infinite-scroll"
     data-infinite-scroll-url-value="<%= root_path %>"
     data-infinite-scroll-has-more-value="<%= @has_more %>">

  <div data-infinite-scroll-target="entries">
    <%= render "timeline" %>
  </div>

  <% if @has_more %>
    <div data-infinite-scroll-target="pagination"
         class="h-20 flex items-center justify-center">
      <div class="animate-spin w-6 h-6 border-2 border-primary-500
                  border-t-transparent rounded-full"></div>
    </div>
  <% end %>
</div>
```

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  layout "dashboard"

  def index
    @family = current_family
    result = TimelineService.new(@family, page: params[:page] || 1).call
    @timeline = result.timeline
    @has_more = result.has_more

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "entries",
          partial: "timeline",
          locals: { timeline: @timeline }
        )
      end
    end
  end
end
```

#### REFACTOR: 성능 최적화

- [ ] **REFACTOR**: 이미지 로딩 최적화

```erb
<%# Intersection Observer로 lazy loading %>
<%= image_tag photo.thumbnail_url,
              loading: "lazy",
              decoding: "async",
              alt: photo.caption || "사진",
              class: "w-full h-full object-cover" %>

<%# 또는 native lazy loading %>
<img src="<%= photo.thumbnail_url %>"
     loading="lazy"
     decoding="async"
     alt="<%= photo.caption || '사진' %>"
     class="w-full h-full object-cover">
```

---

## 로케일 설정

```yaml
# config/locales/ko.yml
ko:
  date:
    formats:
      long: "%Y년 %m월 %d일 (%a)"
  time:
    formats:
      short: "%m/%d %H:%M"
```

---

## 테스트 실행

```bash
# 모델 테스트
rails test test/models/photo_test.rb

# 컨트롤러 테스트
rails test test/controllers/home_controller_test.rb

# 시스템 테스트
rails test:system test/system/timeline_test.rb
rails test:system test/system/infinite_scroll_test.rb

# 전체 테스트
rails test
```

---

## 커밋 가이드

```bash
# RED 커밋
git add test/
git commit -m "test(timeline): 타임라인 날짜별 그룹화 및 UI 테스트 추가 (RED)"

# GREEN 커밋 (모델)
git add app/models
git commit -m "feat(timeline): Photo 모델에 날짜별 그룹화 메서드 추가 (GREEN)"

# GREEN 커밋 (컨트롤러)
git add app/controllers
git commit -m "feat(timeline): 홈 컨트롤러에 타임라인 로직 추가 (GREEN)"

# GREEN 커밋 (뷰)
git add app/views
git commit -m "feat(timeline): 타임라인 UI 구현 (GREEN)"

# GREEN 커밋 (무한 스크롤)
git add app/javascript
git commit -m "feat(timeline): 무한 스크롤 기능 추가 (GREEN)"

# REFACTOR 커밋
git add app/services app/helpers
git commit -m "refactor(timeline): 타임라인 로직 서비스로 분리 및 컴포넌트 정리"
```

---

## 최종 체크리스트

- [ ] 사진이 날짜별로 그룹화되어 표시됨
- [ ] 날짜 헤더 표시 (오늘, 어제, 날짜)
- [ ] 3열 사진 그리드
- [ ] 빈 상태 처리
- [ ] 무한 스크롤 또는 페이지네이션 동작
- [ ] 사진 클릭 시 상세 페이지 이동
- [ ] Lazy loading 적용
- [ ] 모든 테스트 통과
- [ ] Rubocop 통과
- [ ] N+1 쿼리 없음
- [ ] 반응형 레이아웃 확인
