# frozen_string_literal: true

require "test_helper"

module Onboarding
  class InvitesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      @family = families(:kim_family)
      post login_path, params: { user_id: @user.id }
    end

    test "should display invite page with link" do
      get onboarding_invite_path

      assert_response :success
      assert_select "h1", /초대/
    end

    test "should show invitation link" do
      get onboarding_invite_path

      assert_response :success
      # Should have an invitation link displayed
      assert_select "[data-invite-link]"
    end

    test "should create invitation when none exists" do
      # 기존 초대 삭제
      @family.invitations.destroy_all

      assert_difference "Invitation.count", 1 do
        get onboarding_invite_path
      end

      invitation = Invitation.last
      assert_equal @family, invitation.family
      assert_equal @user, invitation.inviter
    end

    test "should reuse active invitation" do
      # 기존 초대 삭제 후 활성 초대 생성
      @family.invitations.destroy_all
      existing_invitation = @family.invitations.create!(
        inviter: @user,
        role: :member,
        expires_at: 7.days.from_now
      )

      assert_no_difference "Invitation.count" do
        get onboarding_invite_path
      end

      assert_select "input[value*='#{existing_invitation.token}']"
    end

    test "should create new invitation when only expired exists" do
      # 기존 초대 삭제 후 만료된 초대만 생성
      @family.invitations.destroy_all
      @family.invitations.create!(
        inviter: @user,
        role: :member,
        expires_at: 1.day.ago
      )

      assert_difference "Invitation.count", 1 do
        get onboarding_invite_path
      end

      new_invitation = Invitation.last
      assert new_invitation.expires_at > Time.current
    end

    test "should require authentication" do
      delete logout_path
      get onboarding_invite_path

      assert_redirected_to root_path
    end
  end
end
