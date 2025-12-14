# frozen_string_literal: true

require "test_helper"

module Families
  class ChildrenControllerTest < ActionDispatch::IntegrationTest
    setup do
      @family = families(:kim_family)
      @owner = users(:mom)
      @admin = users(:dad)
      @viewer = users(:grandma)
      @child = children(:baby_kim)
    end

    # index 테스트
    test "owner should see children list" do
      post login_path, params: { user_id: @owner.id }

      get family_children_path(@family)

      assert_response :success
      assert_select ".child", count: 2
    end

    test "viewer should see children list" do
      post login_path, params: { user_id: @viewer.id }

      get family_children_path(@family)

      assert_response :success
    end

    test "non-member should not access children list" do
      other_user = users(:other_family_user)
      post login_path, params: { user_id: other_user.id }

      get family_children_path(@family)

      assert_redirected_to root_path
    end

    # new 테스트
    test "owner should see new child form" do
      post login_path, params: { user_id: @owner.id }

      get new_family_child_path(@family)

      assert_response :success
      assert_select "form"
    end

    test "viewer should not see new child form" do
      post login_path, params: { user_id: @viewer.id }

      get new_family_child_path(@family)

      assert_redirected_to family_children_path(@family)
      assert_equal "권한이 없습니다.", flash[:alert]
    end

    # create 테스트
    test "owner should create child" do
      post login_path, params: { user_id: @owner.id }

      assert_difference "Child.count", 1 do
        post family_children_path(@family), params: {
          child: { name: "새 아기", birthdate: 1.year.ago.to_date, gender: "male" }
        }
      end

      assert_redirected_to family_children_path(@family)
      assert_equal "아이가 등록되었습니다.", flash[:notice]
    end

    test "admin should create child" do
      post login_path, params: { user_id: @admin.id }

      assert_difference "Child.count", 1 do
        post family_children_path(@family), params: {
          child: { name: "새 아기", birthdate: 1.year.ago.to_date, gender: "female" }
        }
      end

      assert_redirected_to family_children_path(@family)
    end

    test "viewer should not create child" do
      post login_path, params: { user_id: @viewer.id }

      assert_no_difference "Child.count" do
        post family_children_path(@family), params: {
          child: { name: "새 아기", birthdate: 1.year.ago.to_date }
        }
      end

      assert_redirected_to family_children_path(@family)
      assert_equal "권한이 없습니다.", flash[:alert]
    end

    test "create with invalid params should re-render form" do
      post login_path, params: { user_id: @owner.id }

      assert_no_difference "Child.count" do
        post family_children_path(@family), params: {
          child: { name: "", birthdate: nil }
        }
      end

      assert_response :unprocessable_entity
    end

    # edit 테스트
    test "owner should see edit form" do
      post login_path, params: { user_id: @owner.id }

      get edit_family_child_path(@family, @child)

      assert_response :success
    end

    test "viewer should not see edit form" do
      post login_path, params: { user_id: @viewer.id }

      get edit_family_child_path(@family, @child)

      assert_redirected_to family_children_path(@family)
      assert_equal "권한이 없습니다.", flash[:alert]
    end

    # update 테스트
    test "owner should update child" do
      post login_path, params: { user_id: @owner.id }

      patch family_child_path(@family, @child), params: {
        child: { name: "수정된 이름" }
      }

      assert_redirected_to family_children_path(@family)
      assert_equal "아이 정보가 수정되었습니다.", flash[:notice]

      @child.reload
      assert_equal "수정된 이름", @child.name
    end

    test "viewer should not update child" do
      post login_path, params: { user_id: @viewer.id }

      patch family_child_path(@family, @child), params: {
        child: { name: "수정 시도" }
      }

      assert_redirected_to family_children_path(@family)
      assert_equal "권한이 없습니다.", flash[:alert]

      @child.reload
      assert_equal "김아기", @child.name
    end

    # destroy 테스트
    test "owner should delete child" do
      post login_path, params: { user_id: @owner.id }

      assert_difference "Child.count", -1 do
        delete family_child_path(@family, @child)
      end

      assert_redirected_to family_children_path(@family)
      assert_equal "아이가 삭제되었습니다.", flash[:notice]
    end

    test "admin should delete child" do
      post login_path, params: { user_id: @admin.id }

      assert_difference "Child.count", -1 do
        delete family_child_path(@family, @child)
      end

      assert_redirected_to family_children_path(@family)
    end

    test "viewer should not delete child" do
      post login_path, params: { user_id: @viewer.id }

      assert_no_difference "Child.count" do
        delete family_child_path(@family, @child)
      end

      assert_redirected_to family_children_path(@family)
      assert_equal "권한이 없습니다.", flash[:alert]
    end
  end
end
