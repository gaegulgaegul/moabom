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

    # 60장의 사진 생성 (50장 + 10장 = 2페이지)
    60.times do |i|
      create_photo(@family, taken_at: i.days.ago)
    end
  end

  test "shows pagination element when there are more photos" do
    visit root_path

    # 페이지네이션 요소 확인
    assert_selector "[data-infinite-scroll-target='pagination']"
  end

  test "hides pagination when no more photos" do
    # 사진을 30장만 남김
    @family.photos.destroy_all
    30.times { |i| create_photo(@family, taken_at: i.days.ago) }

    visit root_path

    # 페이지네이션 요소가 없어야 함 (50장 미만)
    assert_no_selector "[data-infinite-scroll-target='pagination']"
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
