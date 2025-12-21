# frozen_string_literal: true

module SystemTestHelpers
  # 시스템 테스트에서 사용자 로그인 헬퍼
  def sign_in(user)
    # For system tests, we need to submit a form to create a session
    # since we can't directly manipulate sessions with Selenium
    # CSRF is disabled for /login in test environment

    # Ensure user is in the database before proceeding
    user.reload
    raise "User not found in database" unless User.exists?(user.id)

    # Force SQLite WAL checkpoint to ensure all writes are visible to Puma server
    # This is critical because Puma runs in a separate process and may not see
    # uncommitted WAL changes
    ActiveRecord::Base.connection.execute("PRAGMA wal_checkpoint(FULL)")

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

    # Wait for login to complete by checking for notification bell
    # The bell icon only appears when logged in (inside <% if logged_in? %>)
    # This confirms the session is established and user data is loaded
    assert_selector "a[aria-label='알림']", wait: 15
  end

  # 로그아웃 헬퍼
  def sign_out
    click_on "로그아웃" if has_button?("로그아웃")
  end
end
