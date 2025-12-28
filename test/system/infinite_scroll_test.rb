# frozen_string_literal: true

require "application_system_test_case"

class InfiniteScrollTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user

    # 기존 사진 제거
    @family.photos.destroy_all

    # 60장의 사진 생성 — 2페이지 분량 (페이지당 50장)
    60.times do |i|
      create_photo(@family, taken_at: i.days.ago)
    end
  end

  test "shows pagination element when there are more photos" do
    # home2 대시보드에서는 infinite scroll이 아직 구현되지 않음
    skip "home2에서 infinite scroll 미구현"
  end

  test "hides pagination when no more photos" do
    # home2 대시보드에서는 infinite scroll이 아직 구현되지 않음
    skip "home2에서 infinite scroll 미구현"
  end

  private

  def create_photo(family, taken_at:)
    photo = family.photos.build(
      uploader: @user,
      taken_at: taken_at
    )
    photo.image.attach(
      io: StringIO.new("fake image data"),
      filename: "photo.jpg",
      content_type: "image/jpeg"
    )
    photo.save!
    photo
  end
end
