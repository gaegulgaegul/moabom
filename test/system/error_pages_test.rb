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

    # 중앙 정렬 레이아웃 확인
    assert_selector "div.min-h-screen.bg-cream-50.flex.flex-col.items-center.justify-center"

    # magnifying-glass 아이콘 확인
    assert_selector "svg[class*='w-12'][class*='h-12'][class*='text-warm-gray-400']"

    # 제목 확인
    assert_selector "h1.text-2xl.font-bold.text-warm-gray-800", text: "페이지를 찾을 수 없어요"

    # 설명 확인
    assert_selector "p.text-warm-gray-500.text-center", text: /요청하신 페이지가 존재하지 않거나/

    # btn-primary 홈 버튼 확인
    assert_selector "a.btn-primary", text: "홈으로 돌아가기"
    assert_selector "a.btn-primary svg[class*='w-5'][class*='h-5']" # home 아이콘
  end

  test "500 페이지 UI 표시" do
    visit "/500"

    # 중앙 정렬 레이아웃 확인
    assert_selector "div.min-h-screen.bg-cream-50.flex.flex-col.items-center.justify-center"

    # 빨간색 원형 아이콘 배경 확인
    assert_selector "div.w-24.h-24.bg-red-100.rounded-full"

    # exclamation-triangle 아이콘 확인
    assert_selector "svg[class*='w-12'][class*='h-12'][class*='text-red-500']"

    # 제목 확인
    assert_selector "h1.text-2xl.font-bold.text-warm-gray-800", text: "문제가 발생했어요"

    # 설명 확인
    assert_selector "p.text-warm-gray-500.text-center", text: /잠시 후 다시 시도해주세요/

    # btn-primary 홈 버튼 확인
    assert_selector "a.btn-primary", text: "홈으로 돌아가기"
    assert_selector "a.btn-primary svg[class*='w-5'][class*='h-5']" # home 아이콘
  end
end
