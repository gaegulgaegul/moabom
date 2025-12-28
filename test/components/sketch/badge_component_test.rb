# frozen_string_literal: true

require "test_helper"

class Sketch::BadgeComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders badge with text" do
    render_inline(Sketch::BadgeComponent.new(text: "New"))

    assert_selector "span.sketch-badge", text: "New"
  end

  test "renders badge with block content" do
    render_inline(Sketch::BadgeComponent.new) do
      "Block content"
    end

    assert_selector "span.sketch-badge", text: "Block content"
  end

  # ==========================================
  # Variant Tests
  # ==========================================

  test "renders default variant" do
    render_inline(Sketch::BadgeComponent.new(text: "Default"))

    assert_selector "span.bg-sketch-cream"
  end

  test "renders primary variant" do
    render_inline(Sketch::BadgeComponent.new(text: "Primary", variant: :primary))

    assert_selector "span.bg-primary-100"
  end

  test "renders success variant" do
    render_inline(Sketch::BadgeComponent.new(text: "Success", variant: :success))

    assert_selector "span.bg-emerald-100"
  end

  test "renders warning variant" do
    render_inline(Sketch::BadgeComponent.new(text: "Warning", variant: :warning))

    assert_selector "span.bg-amber-100"
  end

  test "renders danger variant" do
    render_inline(Sketch::BadgeComponent.new(text: "Danger", variant: :danger))

    assert_selector "span.bg-red-100"
  end

  test "renders info variant" do
    render_inline(Sketch::BadgeComponent.new(text: "Info", variant: :info))

    assert_selector "span.bg-blue-100"
  end

  # ==========================================
  # Size Tests
  # ==========================================

  test "renders sm size badge" do
    render_inline(Sketch::BadgeComponent.new(text: "Small", size: :sm))

    assert_selector "span.text-xs"
  end

  test "renders md size badge (default)" do
    render_inline(Sketch::BadgeComponent.new(text: "Medium", size: :md))

    assert_selector "span.text-sm"
  end

  test "renders lg size badge" do
    render_inline(Sketch::BadgeComponent.new(text: "Large", size: :lg))

    assert_selector "span.text-base"
  end

  # ==========================================
  # Shape Tests
  # ==========================================

  test "renders rounded (pill) badge by default" do
    render_inline(Sketch::BadgeComponent.new(text: "Pill"))

    assert_selector "span.rounded-full"
  end

  test "renders non-rounded badge when rounded is false" do
    render_inline(Sketch::BadgeComponent.new(text: "Square", rounded: false))

    assert_no_selector "span.rounded-full"
  end

  # ==========================================
  # Icon Tests
  # ==========================================

  test "renders badge with icon" do
    render_inline(Sketch::BadgeComponent.new(text: "Photos", icon: "image"))

    assert_selector "svg" # lucide icon
    assert_selector "span.sketch-badge", text: "Photos"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::BadgeComponent.new(text: "Custom", class: "my-custom-class"))

    assert_selector "span.sketch-badge.my-custom-class"
  end
end
