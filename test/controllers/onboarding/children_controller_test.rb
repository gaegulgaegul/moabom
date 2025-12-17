# frozen_string_literal: true

require "test_helper"

module Onboarding
  class ChildrenControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:mom)
      post login_path, params: { user_id: @user.id }
    end

    test "should display child registration form" do
      get onboarding_child_path

      assert_response :success
      assert_select "form[action=?]", onboarding_child_path
      assert_select "input[name=?]", "child[name]"
      assert_select "input[name=?]", "child[birthdate]"
      assert_select "input[type=?]", "hidden", with: { name: "child[gender]" }
    end

    test "should create child and family then redirect to invite step" do
      assert_difference "Child.count", 1 do
        assert_difference "Family.count", 1 do
          post onboarding_child_path, params: {
            child: {
              name: "우리아기",
              birthdate: "2023-05-15",
              gender: "male"
            }
          }
        end
      end

      assert_redirected_to onboarding_invite_path

      # Family created with name based on user
      family = Family.last
      assert_equal "#{@user.nickname}의 가족", family.name

      # User is owner of the family
      membership = @user.family_memberships.find_by(family: family)
      assert membership.role_owner?

      # Child belongs to the family
      child = Child.last
      assert_equal family, child.family
      assert_equal "우리아기", child.name
    end

    test "should show error when child name is blank" do
      post onboarding_child_path, params: {
        child: {
          name: "",
          birthdate: "2023-05-15",
          gender: "male"
        }
      }

      assert_response :unprocessable_entity
      assert_select ".alert-error", /이름/
    end

    test "should show error when birthdate is blank" do
      post onboarding_child_path, params: {
        child: {
          name: "우리아기",
          birthdate: "",
          gender: "male"
        }
      }

      assert_response :unprocessable_entity
      assert_select ".alert-error", /생년월일/
    end

    test "should require authentication" do
      delete logout_path
      get onboarding_child_path

      assert_redirected_to root_path
    end
  end
end
