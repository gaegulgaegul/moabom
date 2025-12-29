# frozen_string_literal: true

# ApplicationJob
#
# 역할: 모든 백그라운드 작업의 기본 클래스
#
# 주요 기능:
# - ActiveJob 기반 비동기 작업 처리
# - Solid Queue 어댑터 사용 (SQLite 기반)
# - 자동 재시도 및 에러 처리 설정 가능
#
# 연관 클래스: SendPushNotificationJob 등 모든 Job이 상속
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
