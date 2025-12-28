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
      # Should have an invitation link displayed in readonly input
      assert_select "input[readonly]"
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

      assert_redirected_to login_path
    end

    test "should redirect when user has no family" do
      # 사용자의 모든 가족 멤버십 삭제
      @user.family_memberships.destroy_all

      get onboarding_invite_path

      assert_redirected_to root_path
      assert_equal "가족을 찾을 수 없습니다. 먼저 프로필을 완성해주세요.", flash[:alert]
    end

    test "POST #complete should mark family onboarding as completed" do
      # 온보딩 미완료 상태로 설정
      @family.update_column(:onboarding_completed_at, nil)
      @user.update_column(:onboarding_completed_at, nil)
      assert_not @family.onboarding_completed?
      assert_not @user.onboarding_completed?

      post complete_onboarding_invite_path

      assert_redirected_to root_path
      assert @family.reload.onboarding_completed?
      assert @user.reload.onboarding_completed?
    end

    test "POST #complete should redirect to root with success message" do
      # 온보딩 미완료 상태로 설정
      @family.update_column(:onboarding_completed_at, nil)

      post complete_onboarding_invite_path

      assert_redirected_to root_path
      follow_redirect!
      assert_select ".sketch-alert", text: /온보딩이 완료되었습니다/
    end
  end
end
