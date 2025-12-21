# frozen_string_literal: true

module SystemTestHelpers
  # 시스템 테스트에서 사용자 로그인 헬퍼
  def sign_in(user)
    # For system tests, we need to submit a form to create a session
    # since we can't directly manipulate sessions with Selenium
    # CSRF is disabled for /login in test environment

    # Ensure database changes are visible (important for CI parallel tests)
    user.reload
    user.families.each(&:reload)

    # Visit a page first to establish a session
    visit root_path

    # Use JavaScript to create and submit a hidden form (no CSRF needed in test)
    page.execute_script(<<~JS)
      var form = document.createElement('form');
      form.method = 'POST';
      form.action = '/login';

      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'user_id';
      input.value = '#{user.id}';
      form.appendChild(input);

      document.body.appendChild(form);
      form.submit();
    JS

    # Wait for redirect and page load to complete
    # Check for header element which only appears when logged in
    # This is more reliable than flash message which may disappear quickly
    assert_selector "header", wait: 10

    # Additional verification: check for notification bell which only appears when logged in
    # This confirms session is fully loaded with user data
    assert_selector "a[aria-label='알림']", wait: 5
  end

  # 로그아웃 헬퍼
  def sign_out
    click_on "로그아웃" if has_button?("로그아웃")
  end
end
