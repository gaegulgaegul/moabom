# frozen_string_literal: true

require "test_helper"

class NotificationServiceTest < ActiveSupport::TestCase
  setup do
    @photo = photos(:january_photo)
    @uploader = @photo.uploader
    @actor = users(:mom)
  end

  test "should create notification for reaction" do
    reaction = Reaction.create!(
      photo: @photo,
      user: @actor,
      emoji: "❤️"
    )

    assert_difference "Notification.count", 1 do
      NotificationService.notify_reaction_created(reaction)
    end

    notification = Notification.last
    assert_equal @uploader, notification.recipient
    assert_equal @actor, notification.actor
    assert_equal reaction, notification.notifiable
    assert_equal "reaction_created", notification.notification_type
  end

  test "should create notification for comment" do
    comment = Comment.create!(
      photo: @photo,
      user: @actor,
      body: "귀여워요!"
    )

    assert_difference "Notification.count", 1 do
      NotificationService.notify_comment_created(comment)
    end

    notification = Notification.last
    assert_equal @uploader, notification.recipient
    assert_equal @actor, notification.actor
    assert_equal comment, notification.notifiable
    assert_equal "comment_created", notification.notification_type
  end

  test "should not create notification if actor is photo uploader" do
    reaction = Reaction.create!(
      photo: @photo,
      user: @uploader, # 본인이 반응
      emoji: "❤️"
    )

    assert_no_difference "Notification.count" do
      NotificationService.notify_reaction_created(reaction)
    end
  end

  test "should not create duplicate notification for same reaction update" do
    reaction = Reaction.create!(
      photo: @photo,
      user: @actor,
      emoji: "❤️"
    )

    # 첫 번째 알림 생성
    NotificationService.notify_reaction_created(reaction)

    # 같은 반응 업데이트 시 중복 알림 생성 안 함
    reaction.update!(emoji: "👍")

    assert_no_difference "Notification.count" do
      NotificationService.notify_reaction_created(reaction)
    end
  end
end
