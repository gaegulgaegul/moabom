# frozen_string_literal: true

require "test_helper"

class Sketch::AlertComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders alert with message" do
    render_inline(Sketch::AlertComponent.new(message: "Hello World"))

    assert_selector "div.sketch-alert", text: "Hello World"
  end

  test "renders alert with block content" do
    render_inline(Sketch::AlertComponent.new) do
      "Block message"
    end

    assert_selector "div.sketch-alert", text: "Block message"
  end

  # ==========================================
  # Variant Tests
  # ==========================================

  test "renders info variant (default)" do
    render_inline(Sketch::AlertComponent.new(message: "Info"))

    assert_selector "div.bg-blue-50"
    assert_selector "svg" # info icon
  end

  test "renders success variant" do
    render_inline(Sketch::AlertComponent.new(message: "Success", variant: :success))

    assert_selector "div.bg-emerald-50"
  end

  test "renders warning variant" do
    render_inline(Sketch::AlertComponent.new(message: "Warning", variant: :warning))

    assert_selector "div.bg-amber-50"
  end

  test "renders error variant" do
    render_inline(Sketch::AlertComponent.new(message: "Error", variant: :error))

    assert_selector "div.bg-red-50"
  end

  # ==========================================
  # Title Tests
  # ==========================================

  test "renders alert with title" do
    render_inline(Sketch::AlertComponent.new(message: "Message", title: "Alert Title"))

    assert_selector "p.font-semibold", text: "Alert Title"
    assert_text "Message"
  end

  test "renders alert without title" do
    render_inline(Sketch::AlertComponent.new(message: "Just message"))

    assert_no_selector "p.font-semibold"
    assert_text "Just message"
  end

  # ==========================================
  # Dismissible Tests
  # ==========================================

  test "renders dismissible alert with close button" do
    render_inline(Sketch::AlertComponent.new(message: "Dismiss me", dismissible: true))

    assert_selector "button[type='button']"
    assert_selector "svg" # x icon
  end

  test "renders non-dismissible alert without close button" do
    render_inline(Sketch::AlertComponent.new(message: "No dismiss", dismissible: false))

    assert_no_selector "button[type='button']"
  end

  # ==========================================
  # ARIA Tests
  # ==========================================

  test "has correct role for info" do
    render_inline(Sketch::AlertComponent.new(message: "Info", variant: :info))

    assert_selector "div[role='status']"
  end

  test "has correct role for error" do
    render_inline(Sketch::AlertComponent.new(message: "Error", variant: :error))

    assert_selector "div[role='alert']"
  end

  test "has correct role for warning" do
    render_inline(Sketch::AlertComponent.new(message: "Warning", variant: :warning))

    assert_selector "div[role='alert']"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::AlertComponent.new(message: "Custom", class: "my-custom-class"))

    assert_selector "div.sketch-alert.my-custom-class"
  end
end
