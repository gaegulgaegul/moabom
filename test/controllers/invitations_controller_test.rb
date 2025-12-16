# frozen_string_literal: true

require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @active_invite = invitations(:active_invite)
    @expired_invite = invitations(:expired_invite)
    @new_user = users(:incomplete_onboarding_user)
    @existing_member = users(:mom)
  end

  # 초대 페이지 표시 테스트
  test "should show invitation page with valid token" do
    get accept_invitation_path(@active_invite.token)

    assert_response :success
    assert_select "h1", /가족에 초대되었습니다/
  end

  test "should show error for expired invitation" do
    get accept_invitation_path(@expired_invite.token)

    assert_redirected_to root_path
    assert_equal "만료된 초대입니다.", flash[:alert]
  end

  test "should show error for invalid token" do
    get accept_invitation_path("invalid_token_xyz")

    assert_redirected_to root_path
    assert_equal "유효하지 않은 초대입니다.", flash[:alert]
  end

  # 로그인 상태에서 초대 수락 테스트
  test "logged in user should accept invitation and join family" do
    post login_path, params: { user_id: @new_user.id }

    assert_difference "FamilyMembership.count", 1 do
      post accept_invitation_path(@active_invite.token)
    end

    assert_redirected_to dashboard_path
    assert_equal "가족에 참여했습니다!", flash[:notice]

    # 온보딩 완료 확인
    @new_user.reload
    assert @new_user.onboarding_completed?

    # 가족 멤버십 확인
    membership = @new_user.family_memberships.find_by(family: @active_invite.family)
    assert membership.present?
    assert_equal @active_invite.role, membership.role
  end

  test "logged in user already in family should see error" do
    post login_path, params: { user_id: @existing_member.id }

    assert_no_difference "FamilyMembership.count" do
      post accept_invitation_path(@active_invite.token)
    end

    assert_redirected_to dashboard_path
    assert_equal "이미 가족 구성원입니다.", flash[:alert]
  end

  # 비로그인 상태에서 초대 수락 테스트
  test "guest user should store pending invitation and redirect to login" do
    post accept_invitation_path(@active_invite.token)

    assert_redirected_to root_path
    assert_equal "로그인 후 가족에 참여할 수 있습니다.", flash[:notice]
    assert_equal @active_invite.token, session[:pending_invitation_token]
  end

  test "should not accept expired invitation" do
    post login_path, params: { user_id: @new_user.id }

    assert_no_difference "FamilyMembership.count" do
      post accept_invitation_path(@expired_invite.token)
    end

    assert_redirected_to root_path
    assert_equal "만료된 초대입니다.", flash[:alert]
  end
end
