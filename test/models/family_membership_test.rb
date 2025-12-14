# frozen_string_literal: true

require "test_helper"

class FamilyMembershipTest < ActiveSupport::TestCase
  setup do
    @user = users(:mom)
    @family = families(:lee_family)  # Use lee_family to avoid fixture conflicts
  end

  test "should be valid with user and family" do
    membership = FamilyMembership.new(user: @user, family: @family, role: :member)
    assert membership.valid?
  end

  test "should require user" do
    membership = FamilyMembership.new(family: @family, role: :member)
    assert_not membership.valid?
    assert_includes membership.errors[:user], "must exist"
  end

  test "should require family" do
    membership = FamilyMembership.new(user: @user, role: :member)
    assert_not membership.valid?
    assert_includes membership.errors[:family], "must exist"
  end

  test "should have role enum with correct values" do
    assert_equal({ "viewer" => 0, "member" => 1, "admin" => 2, "owner" => 3 }, FamilyMembership.roles)
  end

  test "should default role to viewer" do
    membership = FamilyMembership.new(user: @user, family: @family)
    assert_equal "viewer", membership.role
  end

  test "should enforce unique user and family combination" do
    # Use existing fixture relationship
    duplicate = FamilyMembership.new(user: users(:mom), family: families(:kim_family), role: :member)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow same user in different families" do
    # mom is already in kim_family via fixture, test she can join lee_family
    membership = FamilyMembership.new(user: @user, family: @family, role: :member)
    assert membership.valid?
  end

  test "should respond to role prefix methods" do
    membership = FamilyMembership.new(role: :admin)
    assert membership.role_admin?
    assert_not membership.role_owner?
  end
end
