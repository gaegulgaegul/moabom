# frozen_string_literal: true

class TimelineService
  Result = Data.define(:timeline, :total_count, :current_page, :has_more)

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

  attr_reader :family, :page, :per_page

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
