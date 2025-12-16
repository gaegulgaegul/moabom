# frozen_string_literal: true

require "test_helper"

class FamilyTest < ActiveSupport::TestCase
  test "should be valid with name" do
    family = Family.new(name: "김씨 가족")
    assert family.valid?
  end

  test "should require name" do
    family = Family.new
    assert_not family.valid?
    assert_includes family.errors[:name], "을(를) 입력해주세요"
  end

  test "should have many users through family_memberships" do
    family = Family.new(name: "테스트 가족")
    assert_respond_to family, :users
    assert_respond_to family, :family_memberships
  end
end
