# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # System tests run in a separate server process, so we can't use transactional tests
  # Database changes need to be visible across processes
  self.use_transactional_tests = false

  # Clean up database after each test
  teardown do
    # Note: In production, consider using database_cleaner gem for more robust cleanup
    # For now, we rely on fixtures being reloaded for each test
  end

  # 시스템 테스트 헬퍼 포함
  include SystemTestHelpers
end
