# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return unless logged_in?

    @family = current_user.families.first
    return unless @family

    @child = @family.children.order(birthdate: :desc).first
    @photos = @family.photos.timeline_for(@family, page: params[:page] || 1)
    @timeline = build_timeline(@photos)
  end

  private

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
end
