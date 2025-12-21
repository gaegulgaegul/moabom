# frozen_string_literal: true

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
