# frozen_string_literal: true

require "ostruct"

class Home2Controller < ApplicationController
  before_action :authenticate_user!
  before_action :set_family

  def index
    @children = @family.children.order(:birthdate)
    @selected_child_id = params[:child_id].presence&.to_i

    # 개발환경에서 ?demo=true로 임시 데이터 표시
    if Rails.env.development? && params[:demo].present?
      @photos_by_date = demo_photos_by_date
      @has_photos = true
    else
      photos_scope = @family.photos.includes(:child, image_attachment: :blob).recent

      if @selected_child_id.present?
        photos_scope = photos_scope.where(child_id: @selected_child_id)
      end

      @photos_by_date = photos_scope.group_by { |photo| photo.taken_at.to_date }
      @has_photos = @family.photos.exists?
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_family
    @family = current_user.families.first
    redirect_to onboarding_profile_path, alert: "가족 설정이 필요합니다." unless @family
  end

  # 개발용 임시 사진 데이터 (picsum.photos 사용)
  def demo_photos_by_date
    today = Date.current
    child = @children.first

    {
      today => 5.times.map { |i| demo_photo(i, today, i.even? ? child : nil) },
      today - 1.day => 3.times.map { |i| demo_photo(i + 10, today - 1.day, child) },
      today - 2.days => 6.times.map { |i| demo_photo(i + 20, today - 2.days, i % 3 == 0 ? child : nil) },
      today - 4.days => 4.times.map { |i| demo_photo(i + 30, today - 4.days, nil) },
      today - 5.days => 7.times.map { |i| demo_photo(i + 40, today - 5.days, child) },
      today - 1.week => 9.times.map { |i| demo_photo(i + 50, today - 1.week, i.odd? ? child : nil) }
    }
  end

  def demo_photo(id, date, child)
    # picsum.photos - 무료 placeholder 이미지 서비스
    image_id = 100 + id
    OpenStruct.new(
      id: id,
      taken_at: date.to_time,
      caption: nil,
      child: child,
      demo_image_url: "https://picsum.photos/seed/#{image_id}/300/300"
    )
  end
end
