# frozen_string_literal: true

require "test_helper"

class LucideHelperTest < ActionView::TestCase
  include LucideRails::RailsHelper

  test "lucide_icon helper renders svg" do
    result = lucide_icon("home")

    assert_includes result, "<svg"
    assert_includes result, "</svg>"
  end

  test "lucide_icon helper accepts custom classes" do
    result = lucide_icon("home", class: "w-6 h-6")

    assert_includes result, "w-6"
    assert_includes result, "h-6"
  end

  test "lucide_icon helper renders different icons" do
    %w[heart camera settings bell user].each do |icon_name|
      result = lucide_icon(icon_name)
      assert_includes result, "<svg", "Icon #{icon_name} should render an SVG"
    end
  end
end
