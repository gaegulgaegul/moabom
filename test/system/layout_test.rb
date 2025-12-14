# frozen_string_literal: true

require "application_system_test_case"

class LayoutTest < ApplicationSystemTestCase
  test "비로그인 사용자는 헤더만 표시" do
    visit root_path

    # 헤더 확인
    assert_selector "header", count: 1
    assert_text "모아봄"
    assert_text "로그인"

    # 탭바 미표시 확인
    assert_no_selector "nav", text: "홈"
    assert_no_selector "nav", text: "설정"
  end

  test "로그인 사용자는 헤더와 탭바 모두 표시" do
    user = users(:mom)
    sign_in user

    visit root_path

    # 헤더 확인
    assert_selector "header", count: 1
    assert_text "모아봄"
    assert_button "로그아웃"

    # 탭바 확인
    assert_selector "nav", count: 1
    assert_text "홈"
    assert_text "앨범"
    assert_text "알림"
    assert_text "설정"
  end

  test "탭바의 현재 페이지 하이라이트" do
    user = users(:mom)
    sign_in user

    visit root_path

    # 홈 탭 활성화 확인
    within "nav" do
      home_link = find("a[href='#{root_path}']")
      assert home_link[:class].include?("text-pink-500")
    end

    # 설정으로 이동
    click_on "설정"

    # 설정 탭 활성화 확인
    within "nav" do
      settings_link = find("a[href='#{settings_profile_path}']")
      assert settings_link[:class].include?("text-pink-500")
    end
  end

  test "플래시 메시지 표시" do
    visit root_path

    # 성공 메시지 확인 (쿼리 파라미터로 전달)
    visit "/?notice=성공했습니다"
    assert_selector ".bg-green-100", text: "성공했습니다"

    # 경고 메시지 확인
    visit "/?alert=오류가 발생했습니다"
    assert_selector ".bg-red-100", text: "오류가 발생했습니다"
  end

  private

  def sign_in(user)
    # 세션 설정을 위한 헬퍼
    # 실제로는 OmniAuth를 통한 로그인이지만 테스트에서는 세션 직접 설정
    visit root_path
    page.set_rack_session(user_id: user.id)
  end
end
