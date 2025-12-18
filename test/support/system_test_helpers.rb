# frozen_string_literal: true

module SystemTestHelpers
  # 시스템 테스트에서 사용자 로그인 헬퍼
  def sign_in(user)
    # For system tests, we need to use the test login endpoint
    # Since we're using Capybara with a real browser (Selenium),
    # we can't directly manipulate the session

    # Visit root first to start session
    visit root_path

    # Set user_id in local storage or session via JavaScript
    # This simulates a logged-in user
    page.execute_script("localStorage.setItem('test_user_id', '#{user.id}');")

    # Set cookie for the application to read
    page.driver.browser.manage.add_cookie(
      name: "test_user_id",
      value: user.id.to_s,
      path: "/",
      domain: "127.0.0.1"
    )

    # Refresh to load with the new cookie
    visit root_path
  end

  # 로그아웃 헬퍼
  def sign_out
    click_on "로그아웃" if has_button?("로그아웃")
  end
end
