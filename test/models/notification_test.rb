# frozen_string_literal: true

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @user = users(:mom)
    @photo = photos(:baby_first_step)
    @reaction = reactions(:dad_thumbsup)
  end

  test "should be valid with required attributes" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert notification.valid?
  end

  test "should require recipient" do
    notification = Notification.new(
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_not notification.valid?
    assert notification.errors[:recipient].any?
  end

  test "should require actor" do
    notification = Notification.new(
      recipient: @user,
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_not notification.valid?
    assert notification.errors[:actor].any?
  end

  test "should require notifiable" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notification_type: "reaction_created"
    )
    assert_not notification.valid?
    assert notification.errors[:notifiable].any?
  end

  test "should require notification_type" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction
    )
    assert_not notification.valid?
    assert notification.errors[:notification_type].any?
  end

  test "should default to unread" do
    notification = Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_not notification.read?
  end

  test "should scope unread notifications" do
    read_notification = notifications(:read_notification)
    unread_notification = notifications(:unread_notification)

    unread = Notification.unread
    assert_includes unread, unread_notification
    assert_not_includes unread, read_notification
  end

  test "should scope recent notifications" do
    recent = Notification.recent
    assert_equal Notification.order(created_at: :desc).to_a, recent.to_a
  end

  test "should mark as read" do
    notification = notifications(:unread_notification)
    assert_not notification.read?

    notification.mark_as_read!
    assert notification.read?
    assert_not_nil notification.read_at
  end

  test "should generate message for reaction_created" do
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: @reaction,
      notification_type: "reaction_created"
    )
    assert_match(/반응을 남겼습니다/, notification.message)
  end

  test "should generate message for comment_created" do
    comment = comments(:dad_comment)
    notification = Notification.new(
      recipient: @user,
      actor: users(:dad),
      notifiable: comment,
      notification_type: "comment_created"
    )
    assert_match(/댓글을 남겼습니다/, notification.message)
  end
end
