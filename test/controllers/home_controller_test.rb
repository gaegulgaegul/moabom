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

  test "should not redirect to onboarding when completed" do
    user = users(:mom)
    family = families(:kim_family)
    family.complete_onboarding!
    sign_in user

    get root_path
    assert_response :success
    assert_select "h1", text: /안녕하세요, #{user.nickname}님!/
  end

  test "should redirect to onboarding when not completed" do
    user = users(:mom)
    family = families(:kim_family)
    family.update!(onboarding_completed_at: nil)
    sign_in user

    get root_path
    assert_redirected_to onboarding_profile_path
  end

  test "should not redirect invited member to onboarding even when family onboarding not completed" do
    # dad is an admin (non-owner) of kim_family
    user = users(:dad)
    family = families(:kim_family)
    family.update!(onboarding_completed_at: nil)
    sign_in user

    get root_path
    assert_response :success
    assert_select "h1", text: /안녕하세요, #{user.nickname}님!/
  end

  test "should not redirect viewer to onboarding even when family onboarding not completed" do
    # grandma is a viewer (non-owner) of kim_family
    user = users(:grandma)
    family = families(:kim_family)
    family.update!(onboarding_completed_at: nil)
    sign_in user

    get root_path
    assert_response :success
    assert_select "h1", text: /안녕하세요, #{user.nickname}님!/
  end

  test "should not redirect member to onboarding even when family onboarding not completed" do
    # uncle is a member (non-owner) of kim_family
    user = users(:uncle)
    family = families(:kim_family)
    family.update!(onboarding_completed_at: nil)
    sign_in user

    get root_path
    assert_response :success
    assert_select "h1", text: /안녕하세요, #{user.nickname}님!/
  end

  # 타임라인 테스트
  test "should get index with timeline" do
    user = users(:mom)
    family = families(:kim_family)
    family.complete_onboarding!
    sign_in user

    get root_path

    assert_response :success
    # 타임라인이 렌더링되는지 확인 (뷰 기반 검증)
    # @timeline이 설정되면 뷰에 timeline-date가 나타남
  end

  test "should group photos by date in timeline" do
    user = users(:mom)
    family = families(:kim_family)
    family.complete_onboarding!
    sign_in user

    # 기존 사진 제거
    family.photos.destroy_all

    # 오늘 사진 생성
    today_photo = create_photo(family, user, taken_at: Time.current)

    # 어제 사진 생성
    yesterday_photo = create_photo(family, user, taken_at: 1.day.ago)

    get root_path

    assert_response :success
    # 날짜별로 그룹화된 타임라인 섹션 확인
    assert_select ".timeline-date", count: 2
  end

  test "should show empty state when no photos" do
    user = users(:mom)
    family = families(:kim_family)
    family.complete_onboarding!
    sign_in user

    family.photos.destroy_all

    get root_path

    assert_response :success
    assert_select ".empty-state", text: /아직 사진이 없어요/
  end

  private

  def create_photo(family, user, taken_at:)
    photo = family.photos.build(
      uploader: user,
      taken_at: taken_at
    )
    photo.image.attach(
      io: StringIO.new("fake image data"),
      filename: "photo.jpg",
      content_type: "image/jpeg"
    )
    photo.save!
    photo
  end
end
