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

    test "should create invitation for user's family" do
      assert_difference "Invitation.count", 1 do
        get onboarding_invite_path
      end

      invitation = Invitation.last
      assert_equal @family, invitation.family
      assert_equal @user, invitation.inviter
    end

    test "should require authentication" do
      delete logout_path
      get onboarding_invite_path

      assert_redirected_to root_path
    end
  end
end
