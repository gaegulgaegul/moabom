# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index when not logged in" do
    get root_path
    assert_response :success
    assert_select "h1", text: /우리 아이의 소중한 순간/
  end

  test "should show dashboard when logged in without family" do
    user = users(:mom)
    sign_in user

    get root_path
    assert_response :success
  end

  test "should show dashboard with greeting when logged in" do
    user = users(:mom)
    family = families(:kim_family)
    sign_in user

    get root_path
    assert_response :success
    assert_select "h1", text: /안녕하세요, #{user.nickname}님!/
  end

  test "should show child card when child exists" do
    user = users(:mom)
    family = families(:kim_family)
    child = children(:baby_kim)
    sign_in user

    get root_path
    assert_response :success
    assert_select ".card-glass" do
      assert_select "p", text: /#{child.name}의 D\+/
    end
  end

  test "should not show recent photos section when no photos" do
    user = users(:mom)
    family = families(:kim_family)
    sign_in user

    # Delete all photos to test empty state
    Photo.destroy_all

    get root_path
    assert_response :success
    assert_select "h2", { text: "최근 사진", count: 0 }
  end

  test "should show quick menu with bento grid" do
    user = users(:mom)
    family = families(:kim_family)
    sign_in user

    get root_path
    assert_response :success
    assert_select "section" do
      assert_select "h2", text: "빠른 메뉴"
      assert_select ".grid.grid-cols-2"
    end
  end

  test "should display correct quick menu items" do
    user = users(:mom)
    family = families(:kim_family)
    sign_in user

    get root_path
    assert_response :success
    assert_select "a[href=?]", new_family_photo_path(family), text: /사진 업로드/
    assert_select "a[href=?]", family_members_path(family), text: /가족 관리/
    assert_select "a[href=?]", family_photos_path(family), text: /앨범 보기/
    assert_select "a[href=?]", family_children_path(family), text: /아이 프로필/
  end
end
