# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_onboarding!

  def index
    # Phase 6에서 실제 알림 데이터 구현 예정
    # 현재는 빈 목록 표시
    @notifications = []
  end
end
