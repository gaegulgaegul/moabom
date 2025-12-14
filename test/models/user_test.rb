# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    user = User.new(
      email: "test@example.com",
      nickname: "테스트",
      provider: "kakao",
      uid: "12345"
    )
    assert user.valid?
  end

  test "should require email" do
    user = User.new(
      nickname: "테스트",
      provider: "kakao",
      uid: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "을(를) 입력해주세요"
  end

  test "should require nickname" do
    user = User.new(
      email: "test@example.com",
      provider: "kakao",
      uid: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:nickname], "을(를) 입력해주세요"
  end

  test "should require unique provider and uid combination" do
    User.create!(
      email: "first@example.com",
      nickname: "첫번째",
      provider: "kakao",
      uid: "12345"
    )

    duplicate = User.new(
      email: "second@example.com",
      nickname: "두번째",
      provider: "kakao",
      uid: "12345"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "은(는) 이미 사용 중입니다"
  end

  test "should allow same uid with different provider" do
    User.create!(
      email: "kakao@example.com",
      nickname: "카카오유저",
      provider: "kakao",
      uid: "12345"
    )

    apple_user = User.new(
      email: "apple@example.com",
      nickname: "애플유저",
      provider: "apple",
      uid: "12345"
    )
    assert apple_user.valid?
  end

  # 온보딩 완료 추적 테스트
  test "should have onboarding_completed_at attribute" do
    user = users(:mom)
    assert_respond_to user, :onboarding_completed_at
  end

  test "onboarding_completed? should return false when onboarding_completed_at is nil" do
    user = User.new(
      email: "test@example.com",
      nickname: "테스트",
      provider: "kakao",
      uid: "99999"
    )
    assert_not user.onboarding_completed?
  end

  test "onboarding_completed? should return true when onboarding_completed_at is set" do
    user = users(:mom)
    user.onboarding_completed_at = Time.current
    assert user.onboarding_completed?
  end

  test "complete_onboarding! should set onboarding_completed_at" do
    user = users(:mom)
    user.onboarding_completed_at = nil
    user.save!

    assert_nil user.onboarding_completed_at
    user.complete_onboarding!
    assert_not_nil user.onboarding_completed_at
  end
end
