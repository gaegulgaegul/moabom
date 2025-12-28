# frozen_string_literal: true

require "application_system_test_case"

class ErrorPagesTest < ApplicationSystemTestCase
  setup do
    # 커스텀 에러 페이지를 테스트하기 위해 local request를 false로 설정
    @original_show_exceptions = Rails.application.config.action_dispatch.show_exceptions
    @original_consider_local = Rails.application.config.consider_all_requests_local
    Rails.application.config.action_dispatch.show_exceptions = :all
    Rails.application.config.consider_all_requests_local = false
  end

  teardown do
    Rails.application.config.action_dispatch.show_exceptions = @original_show_exceptions
    Rails.application.config.consider_all_requests_local = @original_consider_local
  end

  test "404 페이지 UI 표시" do
    visit "/non_existent_page"

    # Sketch 디자인: 중앙 정렬 레이아웃 확인
    assert_selector "div.min-h-screen.bg-sketch-paper.flex.flex-col.items-center.justify-center"

    # 제목 확인
    assert_selector "h1", text: "페이지를 찾을 수 없어요"

    # 설명 확인
    assert_text "요청하신 페이지가 존재하지 않거나"

    # 홈 버튼 확인
    assert_text "홈으로 돌아가기"
  end

  test "500 페이지 UI 표시" do
    visit "/500"

    # Sketch 디자인: 중앙 정렬 레이아웃 확인
    assert_selector "div.min-h-screen.bg-sketch-paper.flex.flex-col.items-center.justify-center"

    # 제목 확인
    assert_selector "h1", text: "문제가 발생했어요"

    # 설명 확인
    assert_text "잠시 후 다시 시도해주세요"

    # 홈 버튼 확인
    assert_text "홈으로 돌아가기"
  end
end
