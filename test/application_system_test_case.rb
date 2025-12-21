# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Disable parallelization for system tests
  # System tests use a separate Puma server process which needs to access the same database
  # Parallel workers use separate database files (test-1.sqlite3, test-2.sqlite3, etc.)
  # This causes the server to read from a different database than the test writes to
  parallelize(workers: 1)

  # Disable transactional tests for system tests
  # System tests run a separate Puma server process
  # Transactional tests wrap each test in a transaction and roll back after
  # This means the Puma server can't see the test data because it's in a transaction
  # We need actual database commits so the server can access the data
  self.use_transactional_tests = false

  # 시스템 테스트 헬퍼 포함
  include SystemTestHelpers
end
