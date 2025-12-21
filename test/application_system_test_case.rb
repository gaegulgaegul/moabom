# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Disable parallelization for system tests
  # System tests use a separate Puma server process which needs to access the same database
  # Parallel workers use separate database files (test-1.sqlite3, test-2.sqlite3, etc.)
  # This causes the server to read from a different database than the test writes to
  parallelize(workers: 1)

  # 시스템 테스트 헬퍼 포함
  include SystemTestHelpers
end
