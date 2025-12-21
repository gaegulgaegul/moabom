# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return unless logged_in?

    @family = current_user.families.first
    return unless @family

    @child = @family.children.order(birthdate: :desc).first
    result = TimelineService.new(@family, page: params[:page] || 1).call
    @timeline = result.timeline
    @has_more = result.has_more

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "timeline-entries",
          partial: "timeline",
          locals: { timeline: @timeline }
        )
      end
    end
  end
end
