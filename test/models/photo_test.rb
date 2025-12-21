# frozen_string_literal: true

require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  setup do
    @family = families(:kim_family)
    @user = users(:mom)
    @child = children(:baby_kim)
  end

  test "should be valid with required attributes" do
    photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: Time.current
    )
    photo.image.attach(
      io: StringIO.new("fake image data"),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    assert photo.valid?
  end

  test "should belong to family" do
    photo = Photo.new(uploader: @user, taken_at: Time.current)
    assert_not photo.valid?
    assert_includes photo.errors[:family], "은(는) 필수입니다"
  end

  test "should belong to uploader" do
    photo = Photo.new(family: @family, taken_at: Time.current)
    assert_not photo.valid?
    assert_includes photo.errors[:uploader], "은(는) 필수입니다"
  end

  test "should optionally belong to child" do
    photo = Photo.new(
      family: @family,
      uploader: @user,
      child: @child,
      taken_at: Time.current
    )
    photo.image.attach(
      io: StringIO.new("fake image data"),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    assert photo.valid?
    assert_equal @child, photo.child
  end

  test "should allow nil child" do
    photo = Photo.new(
      family: @family,
      uploader: @user,
      child: nil,
      taken_at: Time.current
    )
    photo.image.attach(
      io: StringIO.new("fake image data"),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    assert photo.valid?
  end

  test "should require taken_at" do
    photo = Photo.new(family: @family, uploader: @user)
    assert_not photo.valid?
    assert_includes photo.errors[:taken_at], "을(를) 입력해주세요"
  end

  test "should require image in production" do
    # 테스트 환경에서는 검증이 스킵되므로, 프로덕션 동작을 검증하기 위해
    # 이미지가 없는 상태에서 수동으로 acceptable_image 검증 실행
    photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: Time.current
    )

    # 프로덕션에서는 이미지 presence 검증이 실행됨을 테스트
    # 검증 조건을 우회하여 테스트
    original_env = Rails.env
    Rails.env = ActiveSupport::StringInquirer.new("production")

    assert_not photo.valid?, "Image should be required in production"
    assert_includes photo.errors[:image], "을(를) 입력해주세요"
  ensure
    Rails.env = original_env
  end

  test "should scope recent in descending order" do
    # Create photos with different taken_at times
    old_photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: 2.days.ago
    )
    old_photo.image.attach(io: StringIO.new("data"), filename: "old.jpg", content_type: "image/jpeg")
    old_photo.save!

    new_photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: 1.day.ago
    )
    new_photo.image.attach(io: StringIO.new("data"), filename: "new.jpg", content_type: "image/jpeg")
    new_photo.save!

    result = Photo.recent
    assert_equal new_photo, result.first
  end

  test "should scope by_month to filter photos" do
    jan_photo = photos(:january_photo)
    feb_photo = photos(:february_photo)

    result = Photo.by_month(2025, 1)

    assert_includes result, jan_photo
    assert_not_includes result, feb_photo
  end

  # 파일 검증 테스트
  test "should accept jpeg images" do
    photo = build_photo_with_content_type("image/jpeg", "test.jpg")
    assert photo.valid?, "JPEG should be accepted"
  end

  test "should accept png images" do
    photo = build_photo_with_content_type("image/png", "test.png")
    assert photo.valid?, "PNG should be accepted"
  end

  test "should accept heic images" do
    photo = build_photo_with_content_type("image/heic", "test.heic")
    assert photo.valid?, "HEIC should be accepted"
  end

  test "should accept webp images" do
    photo = build_photo_with_content_type("image/webp", "test.webp")
    assert photo.valid?, "WebP should be accepted"
  end

  test "should reject non-image files" do
    photo = build_photo_with_content_type("application/pdf", "test.pdf")
    assert_not photo.valid?
    assert photo.errors[:image].any? { |e| e.include?("허용되지 않는") || e.include?("not allowed") }
  end

  test "should reject text files" do
    photo = build_photo_with_content_type("text/plain", "test.txt")
    assert_not photo.valid?
    assert photo.errors[:image].any? { |e| e.include?("허용되지 않는") || e.include?("not allowed") }
  end

  test "should reject files larger than 50MB" do
    photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: Time.current
    )
    # 50MB + 1byte를 시뮬레이션
    large_data = "x" * (50.megabytes + 1)
    photo.image.attach(
      io: StringIO.new(large_data),
      filename: "large.jpg",
      content_type: "image/jpeg"
    )
    assert_not photo.valid?
    assert photo.errors[:image].any? { |e| e.include?("50MB") || e.include?("too large") || e.include?("크기") }
  end

  test "should accept files under 50MB" do
    photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: Time.current
    )
    # 1MB 파일
    small_data = "x" * 1.megabyte
    photo.image.attach(
      io: StringIO.new(small_data),
      filename: "small.jpg",
      content_type: "image/jpeg"
    )
    assert photo.valid?
  end

  # 타임라인 그룹화 테스트
  test "should group photos by date" do
    family = families(:kim_family)
    # 기존 사진 제거
    family.photos.destroy_all

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
    # 기존 사진 제거
    family.photos.destroy_all

    old_photo = create_photo(family, taken_at: 1.week.ago)
    recent_photo = create_photo(family, taken_at: Time.current)

    grouped = Photo.for_family(family).group_by_date

    # 최신 날짜가 먼저
    assert_equal Date.current, grouped.keys.first
  end

  test "should scope photos by month for timeline" do
    family = families(:kim_family)
    # 기존 사진 제거
    family.photos.destroy_all

    # 1월 사진
    jan_photo = create_photo(family, taken_at: Date.new(2025, 1, 15))

    # 2월 사진
    feb_photo = create_photo(family, taken_at: Date.new(2025, 2, 10))

    jan_photos = Photo.for_family(family).by_month(2025, 1)

    assert_includes jan_photos, jan_photo
    assert_not_includes jan_photos, feb_photo
  end

  private

  def build_photo_with_content_type(content_type, filename)
    photo = Photo.new(
      family: @family,
      uploader: @user,
      taken_at: Time.current
    )
    photo.image.attach(
      io: StringIO.new("fake image data"),
      filename: filename,
      content_type: content_type
    )
    photo
  end

  def create_photo(family, taken_at:)
    photo = family.photos.build(
      uploader: users(:mom),
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
