# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @photo = photos(:january_photo)
    @user = users(:mom)
  end

  test "should be valid with required attributes" do
    comment = Comment.new(
      photo: @photo,
      user: @user,
      body: "좋은 사진이네요!"
    )
    assert comment.valid?
  end

  test "should belong to photo" do
    comment = Comment.new(user: @user, body: "테스트")
    assert_not comment.valid?
    assert_includes comment.errors[:photo], "은(는) 필수입니다"
  end

  test "should belong to user" do
    comment = Comment.new(photo: @photo, body: "테스트")
    assert_not comment.valid?
    assert_includes comment.errors[:user], "은(는) 필수입니다"
  end

  test "should require body" do
    comment = Comment.new(photo: @photo, user: @user)
    assert_not comment.valid?
    assert_includes comment.errors[:body], "을(를) 입력해주세요"
  end

  test "should allow multiple comments from same user on same photo" do
    Comment.create!(photo: @photo, user: @user, body: "첫 번째 댓글")
    second_comment = Comment.new(photo: @photo, user: @user, body: "두 번째 댓글")
    assert second_comment.valid?
  end

  # 6.5.2: 댓글 길이 제한
  test "should accept comment within length limit" do
    comment = Comment.new(photo: @photo, user: @user, body: "좋은 사진이에요!" * 50)
    assert comment.valid?, "1000자 이하 댓글은 저장 가능해야 함"
  end

  test "should reject comment exceeding 1000 characters" do
    long_body = "가" * 1001
    comment = Comment.new(photo: @photo, user: @user, body: long_body)
    assert_not comment.valid?, "1000자 초과 댓글은 거부되어야 함"
    assert comment.errors[:body].present?, "body 에러가 있어야 함"
  end

  test "should accept comment at exactly 1000 characters" do
    exact_body = "가" * 1000
    comment = Comment.new(photo: @photo, user: @user, body: exact_body)
    assert comment.valid?, "정확히 1000자 댓글은 허용되어야 함"
  end
end
