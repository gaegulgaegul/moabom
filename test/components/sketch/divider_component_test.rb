# frozen_string_literal: true

require "test_helper"

class Sketch::DividerComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders horizontal divider by default" do
    render_inline(Sketch::DividerComponent.new)

    assert_selector "hr.sketch-divider"
    assert_selector "hr[role='separator']"
    assert_selector "hr[aria-orientation='horizontal']"
  end

  test "renders vertical divider" do
    render_inline(Sketch::DividerComponent.new(direction: :vertical))

    assert_selector "hr[aria-orientation='vertical']"
  end

  # ==========================================
  # Variant Tests
  # ==========================================

  test "renders solid variant (default)" do
    render_inline(Sketch::DividerComponent.new(variant: :solid))

    assert_selector "hr.border-solid"
  end

  test "renders dashed variant" do
    render_inline(Sketch::DividerComponent.new(variant: :dashed))

    assert_selector "hr.border-dashed"
  end

  test "renders dotted variant" do
    render_inline(Sketch::DividerComponent.new(variant: :dotted))

    assert_selector "hr.border-dotted"
  end

  # ==========================================
  # Thickness Tests
  # ==========================================

  test "renders thin thickness" do
    render_inline(Sketch::DividerComponent.new(thickness: :thin))

    assert_selector "hr.border-t"
  end

  test "renders normal thickness (default)" do
    render_inline(Sketch::DividerComponent.new(thickness: :normal))

    assert_selector "hr.border-t-2"
  end

  test "renders thick thickness" do
    render_inline(Sketch::DividerComponent.new(thickness: :thick))

    assert_selector "hr.border-t-4"
  end

  # ==========================================
  # Direction Tests
  # ==========================================

  test "horizontal divider has correct classes" do
    render_inline(Sketch::DividerComponent.new(direction: :horizontal))

    assert_selector "hr.w-full"
  end

  test "vertical divider has correct classes" do
    render_inline(Sketch::DividerComponent.new(direction: :vertical))

    assert_selector "hr.h-full"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::DividerComponent.new(class: "my-custom-class"))

    assert_selector "hr.sketch-divider.my-custom-class"
  end
end
