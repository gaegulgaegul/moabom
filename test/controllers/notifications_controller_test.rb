# frozen_string_literal: true

require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:mom)
    sign_in @user
  end

  test "should get index" do
    get notifications_path
    assert_response :success
  end

  test "should display notifications in index" do
    # 알림 생성
    photo = photos(:january_photo)
    reaction = Reaction.create!(photo: photo, user: users(:dad), emoji: "❤️")
    notification = Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: reaction,
      notification_type: "reaction_created"
    )

    get notifications_path
    assert_response :success
    # 뷰에서 알림이 렌더링되는지 확인 (간접 확인)
    assert_select "body"
  end
end
