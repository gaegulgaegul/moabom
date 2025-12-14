# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile
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

  # 닉네임 검증 강화 (7.5.2)
  test "should reject nickname shorter than 2 characters" do
    user = User.new(
      email: "test@example.com",
      nickname: "a",
      provider: "kakao",
      uid: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:nickname], "이(가) 너무 짧습니다 (최소 2자)"
  end

  test "should reject nickname longer than 20 characters" do
    user = User.new(
      email: "test@example.com",
      nickname: "a" * 21,
      provider: "kakao",
      uid: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:nickname], "이(가) 너무 깁니다 (최대 20자)"
  end

  test "should accept nickname with valid characters (Korean, English, numbers, underscore)" do
    valid_nicknames = [ "엄마", "Mom", "엄마123", "mom_123", "엄마_Mom" ]
    valid_nicknames.each do |nickname|
      user = User.new(
        email: "test@example.com",
        nickname: nickname,
        provider: "kakao",
        uid: "unique_#{nickname}"
      )
      assert user.valid?, "Nickname '#{nickname}' should be valid"
    end
  end

  test "should reject nickname with invalid characters" do
    invalid_nicknames = [ "엄마!", "mom@", "테스트#", "user$", "닉네임%" ]
    invalid_nicknames.each do |nickname|
      user = User.new(
        email: "test@example.com",
        nickname: nickname,
        provider: "kakao",
        uid: "unique_#{nickname}"
      )
      assert_not user.valid?, "Nickname '#{nickname}' should be invalid"
      assert_includes user.errors[:nickname], "이(가) 올바르지 않습니다"
    end
  end

  test "should reject nickname with forbidden words" do
    forbidden_nicknames = [ "관리자", "admin", "운영자", "moderator" ]
    forbidden_nicknames.each do |nickname|
      user = User.new(
        email: "test@example.com",
        nickname: nickname,
        provider: "kakao",
        uid: "unique_#{nickname}"
      )
      assert_not user.valid?, "Nickname '#{nickname}' should be rejected as forbidden"
      assert_includes user.errors[:nickname], "사용할 수 없는 닉네임입니다"
    end
  end

  # 닉네임 보안 검증 (7.5.5)
  test "should reject nickname with HTML tags (XSS prevention)" do
    malicious_nicknames = [ "<script>alert('xss')</script>", "<img src=x>", "<a href='#'>link</a>" ]
    malicious_nicknames.each do |nickname|
      user = User.new(
        email: "test@example.com",
        nickname: nickname,
        provider: "kakao",
        uid: "unique_#{nickname}"
      )
      assert_not user.valid?, "Nickname '#{nickname}' should be rejected (XSS)"
      assert_includes user.errors[:nickname], "이(가) 올바르지 않습니다"
    end
  end

  test "should reject nickname with SQL injection patterns" do
    sql_nicknames = [ "admin'--", "1' OR '1'='1", "'; DROP TABLE users;--" ]
    sql_nicknames.each do |nickname|
      user = User.new(
        email: "test@example.com",
        nickname: nickname,
        provider: "kakao",
        uid: "unique_#{nickname}"
      )
      assert_not user.valid?, "Nickname '#{nickname}' should be rejected (SQL injection)"
      assert_includes user.errors[:nickname], "이(가) 올바르지 않습니다"
    end
  end

  # 아바타 파일 검증 (7.5.6)
  test "should accept valid avatar image types" do
    user = users(:mom)
    valid_types = %w[image/jpeg image/png image/webp]

    valid_types.each do |type|
      file = fixture_file_upload("test_image.jpg", type)
      user.avatar.attach(file)
      assert user.valid?, "Avatar with type '#{type}' should be valid"
      user.avatar.purge
    end
  end

  test "should reject invalid avatar file types" do
    user = users(:mom)
    invalid_types = %w[image/gif image/bmp application/pdf text/plain]

    invalid_types.each do |type|
      file = fixture_file_upload("test_image.jpg", type)
      user.avatar.attach(file)
      assert_not user.valid?, "Avatar with type '#{type}' should be rejected"
      assert_includes user.errors[:avatar], "허용되지 않는 파일 형식입니다"
      user.avatar.purge
    end
  end

  test "should reject avatar larger than 5MB" do
    user = users(:mom)
    file = fixture_file_upload("test_image.jpg", "image/jpeg")
    user.avatar.attach(file)

    # Simulate large file by stubbing byte_size
    user.avatar.blob.stub(:byte_size, 6.megabytes) do
      assert_not user.valid?
      assert_includes user.errors[:avatar], "파일 크기가 5MB를 초과합니다"
    end
  end

  test "should accept avatar within 5MB limit" do
    user = users(:mom)
    file = fixture_file_upload("test_image.jpg", "image/jpeg")
    user.avatar.attach(file)

    # Simulate small file by stubbing byte_size
    user.avatar.blob.stub(:byte_size, 4.megabytes) do
      assert user.valid?
    end
  end
end
