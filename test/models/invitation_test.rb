# frozen_string_literal: true

require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @family = families(:kim_family)
    @user = users(:mom)
  end

  test "should be valid with required attributes" do
    invitation = Invitation.new(
      family: @family,
      inviter: @user,
      role: :member
    )
    assert invitation.valid?
  end

  test "should belong to family" do
    invitation = Invitation.new(inviter: @user, role: :member)
    assert_not invitation.valid?
    assert_includes invitation.errors[:family], "must exist"
  end

  test "should belong to inviter" do
    invitation = Invitation.new(family: @family, role: :member)
    assert_not invitation.valid?
    assert_includes invitation.errors[:inviter], "must exist"
  end

  test "should auto-generate token before create" do
    invitation = Invitation.create!(
      family: @family,
      inviter: @user,
      role: :member
    )
    assert_not_nil invitation.token
    assert_equal 32, invitation.token.length
  end

  test "should set default expires_at to 7 days from now" do
    freeze_time do
      invitation = Invitation.create!(
        family: @family,
        inviter: @user,
        role: :member
      )
      assert_equal 7.days.from_now.to_date, invitation.expires_at.to_date
    end
  end

  test "should have role enum with correct values" do
    assert_equal({ "viewer" => 0, "member" => 1, "admin" => 2 }, Invitation.roles)
  end

  test "should generate unique tokens" do
    invitation1 = Invitation.create!(family: @family, inviter: @user, role: :member)
    invitation2 = Invitation.create!(family: @family, inviter: @user, role: :viewer)
    assert_not_equal invitation1.token, invitation2.token
  end

  test "should identify expired invitation" do
    expired = invitations(:expired_invite)
    active = invitations(:active_invite)

    assert expired.expired?
    assert_not active.expired?
  end

  test "should scope active invitations" do
    active = invitations(:active_invite)
    expired = invitations(:expired_invite)

    assert_includes Invitation.active, active
    assert_not_includes Invitation.active, expired
  end
end
