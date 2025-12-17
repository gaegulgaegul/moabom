# frozen_string_literal: true

require "application_system_test_case"

class Families::PhotosTest < ApplicationSystemTestCase
  setup do
    @family = families(:kim_family)
    @user = users(:mom)
    sign_in @user
  end

  test "사진 타임라인 페이지 방문" do
    visit family_photos_path(@family)

    assert_selector "h1", text: "사진 타임라인"
  end

  test "필터 탭이 표시됨" do
    visit family_photos_path(@family)

    assert_link "전체"
  end

  test "사진이 없을 때 빈 상태 표시" do
    @family.photos.destroy_all

    visit family_photos_path(@family)

    assert_text "아직 사진이 없어요"
    assert_text "소중한 순간을 가족과 공유해보세요"
    assert_link "첫 사진 업로드"
  end

  test "사진 그리드가 3열로 표시됨" do
    # fixture의 사진 사용
    visit family_photos_path(@family)

    assert_selector ".grid.grid-cols-3"
  end

  test "월별로 그룹핑되어 표시됨" do
    # fixture에 january_photo, february_photo가 이미 있음
    visit family_photos_path(@family)

    assert_text "2025년 01월"
    assert_text "2025년 02월"
  end

  test "아이별 필터링" do
    child = @family.children.first

    visit family_photos_path(@family, child_id: child.id)

    # 아이 이름으로 된 링크가 활성화 상태
    assert_selector "a.bg-primary-500", text: child.name
  end

  test "사진 클릭 시 상세 페이지로 이동" do
    photo = @family.photos.first

    visit family_photos_path(@family)

    click_link href: family_photo_path(@family, photo)

    assert_current_path family_photo_path(@family, photo)
  end
end
