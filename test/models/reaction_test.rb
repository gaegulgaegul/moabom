# frozen_string_literal: true

require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  setup do
    @photo = photos(:january_photo)
    @user = users(:mom)
  end

  test "should be valid with required attributes" do
    reaction = Reaction.new(
      photo: @photo,
      user: @user,
      emoji: "heart"
    )
    assert reaction.valid?
  end

  test "should belong to photo" do
    reaction = Reaction.new(user: @user, emoji: "heart")
    assert_not reaction.valid?
    assert_includes reaction.errors[:photo], "must exist"
  end

  test "should belong to user" do
    reaction = Reaction.new(photo: @photo, emoji: "heart")
    assert_not reaction.valid?
    assert_includes reaction.errors[:user], "must exist"
  end

  test "should require emoji" do
    reaction = Reaction.new(photo: @photo, user: @user)
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "can't be blank"
  end

  test "should enforce unique user per photo" do
    # Use existing fixture
    existing = reactions(:mom_heart)

    duplicate = Reaction.new(
      photo: existing.photo,
      user: existing.user,
      emoji: "thumbsup"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow same user to react to different photos" do
    user = users(:mom)
    photo1 = photos(:january_photo)
    photo2 = photos(:february_photo)

    reaction1 = Reaction.new(photo: photo1, user: user, emoji: "heart")
    reaction2 = Reaction.new(photo: photo2, user: user, emoji: "heart")

    assert reaction1.valid?
    assert reaction2.valid?
  end
end
