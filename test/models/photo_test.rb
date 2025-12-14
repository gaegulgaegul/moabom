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
    assert_includes photo.errors[:family], "must exist"
  end

  test "should belong to uploader" do
    photo = Photo.new(family: @family, taken_at: Time.current)
    assert_not photo.valid?
    assert_includes photo.errors[:uploader], "must exist"
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
    assert_includes photo.errors[:taken_at], "can't be blank"
  end

  test "should require image" do
    photo = Photo.new(family: @family, uploader: @user, taken_at: Time.current)
    assert_not photo.valid?
    assert_includes photo.errors[:image], "can't be blank"
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
end
