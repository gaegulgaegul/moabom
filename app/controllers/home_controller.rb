# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return unless logged_in?

    @family = current_user.families.first
    return unless @family

    @child = @family.children.order(birthdate: :desc).first
    @recent_photos = @family.photos.recent.limit(10)
  end
end
