require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    @family.complete_onboarding!
    sign_in @user
  end

  test "should display notifications in list" do
    # 알림 생성
    photo = photos(:january_photo)
    reaction = Reaction.create!(photo: photo, user: users(:dad), emoji: "❤️")
    notification = Notification.create!(
      recipient: @user,
      actor: users(:dad),
      notifiable: reaction,
      notification_type: "reaction_created"
    )

    visit notifications_path

    assert_text "아빠님이 사진에 반응을 남겼습니다"
    assert_no_text "알림이 없습니다"
  end

  test "should show empty state when no notifications" do
    # Switch to a user without notifications
    sign_out
    @uncle = users(:uncle)
    sign_in @uncle

    visit notifications_path

    assert_text "알림이 없습니다"
    assert_text "새로운 소식이 있으면 알려드릴게요"
  end
end
