# frozen_string_literal: true

require "test_helper"

class Sketch::EmptyStateComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders empty state with title" do
    render_inline(Sketch::EmptyStateComponent.new(title: "No photos yet"))

    assert_selector "div.sketch-empty-state"
    assert_text "No photos yet"
  end

  test "renders empty state with title and description" do
    render_inline(Sketch::EmptyStateComponent.new(
      title: "No photos yet",
      description: "Start uploading your memories"
    ))

    assert_text "No photos yet"
    assert_text "Start uploading your memories"
  end

  # ==========================================
  # Icon Tests
  # ==========================================

  test "renders with icon" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty", icon: "image"))

    assert_selector "svg" # lucide icon
  end

  test "renders without icon when nil" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty"))

    # Should not have the icon wrapper with w-16 class
    assert_no_selector ".w-16.h-16"
  end

  # ==========================================
  # Action Button Tests
  # ==========================================

  test "renders with action button" do
    render_inline(Sketch::EmptyStateComponent.new(
      title: "Empty",
      action_text: "Add Photo",
      action_href: "/photos/new"
    ))

    assert_selector "a", text: "Add Photo"
    assert_selector "a[href='/photos/new']"
  end

  test "renders without action button when no action_text" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty"))

    # Should not render any action link when action_text is not provided
    assert_no_selector "a[href]"
    refute page.has_link?
  end

  # ==========================================
  # Size Tests
  # ==========================================

  test "renders sm size" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty", size: :sm))

    assert_selector "div.py-8"
  end

  test "renders md size (default)" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty", size: :md))

    assert_selector "div.py-12"
  end

  test "renders lg size" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty", size: :lg))

    assert_selector "div.py-16"
  end

  # ==========================================
  # Slot Tests
  # ==========================================

  test "renders with custom action slot" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty")) do |component|
      component.with_action { "<button class='custom-btn'>Custom Action</button>".html_safe }
    end

    assert_selector ".custom-btn", text: "Custom Action"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::EmptyStateComponent.new(title: "Empty", class: "my-custom-class"))

    assert_selector "div.sketch-empty-state.my-custom-class"
  end
end
