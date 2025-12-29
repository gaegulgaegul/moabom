# frozen_string_literal: true

# ErrorsController
#
# 역할: HTTP 에러 페이지 렌더링
#
# 주요 기능:
# - 404 Not Found 페이지 표시 (not_found)
# - 500 Internal Server Error 페이지 표시 (internal_server_error)
# - 에러 전용 레이아웃 사용 (layout "error")
#
# 연관 설정: config/routes.rb의 에러 라우팅, errors 레이아웃
class ErrorsController < ApplicationController
  layout "error"

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.any { head :not_found }
    end
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
