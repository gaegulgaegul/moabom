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

  test "should require image" do
    photo = Photo.new(family: @family, uploader: @user, taken_at: Time.current)
    assert_not photo.valid?
    assert_includes photo.errors[:image], "을(를) 입력해주세요"
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
end
