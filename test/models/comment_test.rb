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
    assert_includes comment.errors[:photo], "must exist"
  end

  test "should belong to user" do
    comment = Comment.new(photo: @photo, body: "테스트")
    assert_not comment.valid?
    assert_includes comment.errors[:user], "must exist"
  end

  test "should require body" do
    comment = Comment.new(photo: @photo, user: @user)
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "should allow multiple comments from same user on same photo" do
    Comment.create!(photo: @photo, user: @user, body: "첫 번째 댓글")
    second_comment = Comment.new(photo: @photo, user: @user, body: "두 번째 댓글")
    assert second_comment.valid?
  end
end
