# frozen_string_literal: true

# Demo controller for Frame0 Sketch Design System
# This controller showcases all sketch-style components
#
# Access at: /sketch-demo
class SketchDemoController < ApplicationController
  skip_before_action :check_onboarding

  def index
    @page_title = "Sketch Design System Demo"
  end
end
