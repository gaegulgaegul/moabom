# frozen_string_literal: true

require "application_system_test_case"

class TabbarNavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:mom)
    @family = families(:kim_family)
    sign_in @user
  end

  test "should navigate to photo upload when clicking upload button" do
    # 탭바가 표시되는 페이지(설정)로 이동
    visit settings_profile_path

    # 탭바의 업로드 버튼 클릭
    find('a[aria-label="사진 업로드"]').click

    # 사진 업로드 화면으로 이동 확인
    assert_current_path new_family_photo_path(@family)
  end
end
