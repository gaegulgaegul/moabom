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
    assert_includes reaction.errors[:photo], "은(는) 필수입니다"
  end

  test "should belong to user" do
    reaction = Reaction.new(photo: @photo, emoji: "heart")
    assert_not reaction.valid?
    assert_includes reaction.errors[:user], "은(는) 필수입니다"
  end

  test "should require emoji" do
    reaction = Reaction.new(photo: @photo, user: @user)
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "을(를) 입력해주세요"
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
    assert_includes duplicate.errors[:user_id], "은(는) 이미 사용 중입니다"
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

  # 6.5.1: 이모지 유효성 검증
  test "should accept allowed emoji" do
    reaction = Reaction.new(photo: @photo, user: @user, emoji: "❤️")
    assert reaction.valid?, "허용된 이모지는 저장 가능해야 함"
  end

  test "should reject emoji not in allowed list" do
    reaction = Reaction.new(photo: @photo, user: @user, emoji: "🚫")
    assert_not reaction.valid?, "허용되지 않은 이모지는 거부되어야 함"
    assert_includes reaction.errors[:emoji], "은(는) 목록에 포함되어 있지 않습니다"
  end

  test "should reject plain text as emoji" do
    reaction = Reaction.new(photo: @photo, user: @user, emoji: "heart")
    assert_not reaction.valid?, "일반 텍스트는 이모지로 허용되지 않아야 함"
    assert_includes reaction.errors[:emoji], "은(는) 목록에 포함되어 있지 않습니다"
  end

  test "should reject empty emoji" do
    reaction = Reaction.new(photo: @photo, user: @user, emoji: "")
    assert_not reaction.valid?, "빈 이모지는 거부되어야 함"
    assert_includes reaction.errors[:emoji], "을(를) 입력해주세요"
  end
end
