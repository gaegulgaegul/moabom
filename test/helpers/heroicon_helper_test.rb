# frozen_string_literal: true

require "test_helper"

class HeroiconHelperTest < ActionView::TestCase
  include Heroicon::ApplicationHelper

  test "heroicon helper renders svg for outline variant" do
    result = heroicon("home", variant: :outline)

    assert_includes result, "<svg"
    assert_includes result, "</svg>"
  end

  test "heroicon helper renders svg for solid variant" do
    result = heroicon("home", variant: :solid)

    assert_includes result, "<svg"
    assert_includes result, "</svg>"
  end

  test "heroicon helper accepts custom classes" do
    result = heroicon("home", variant: :outline, options: { class: "w-6 h-6" })

    assert_includes result, "w-6"
    assert_includes result, "h-6"
  end
end
