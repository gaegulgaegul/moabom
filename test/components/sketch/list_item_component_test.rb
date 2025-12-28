# frozen_string_literal: true

require "test_helper"

class Sketch::ListItemComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders list item with title" do
    render_inline(Sketch::ListItemComponent.new(title: "Item Title"))

    assert_selector "div.sketch-list-item"
    assert_text "Item Title"
  end

  test "renders list item with title and description" do
    render_inline(Sketch::ListItemComponent.new(
      title: "Item Title",
      description: "Item description"
    ))

    assert_text "Item Title"
    assert_text "Item description"
  end

  # ==========================================
  # Link Tests
  # ==========================================

  test "renders as link when href is provided" do
    render_inline(Sketch::ListItemComponent.new(title: "Link Item", href: "/path"))

    assert_selector "a.sketch-list-item[href='/path']"
  end

  test "renders as div when no href" do
    render_inline(Sketch::ListItemComponent.new(title: "Div Item"))

    assert_selector "div.sketch-list-item"
    assert_no_selector "a.sketch-list-item"
  end

  # ==========================================
  # Icon/Avatar Tests
  # ==========================================

  test "renders with leading icon" do
    render_inline(Sketch::ListItemComponent.new(title: "With Icon", icon: "user"))

    assert_selector "svg" # lucide icon
  end

  test "renders with trailing chevron" do
    render_inline(Sketch::ListItemComponent.new(title: "With Chevron", show_chevron: true))

    assert_selector "svg" # chevron icon
  end

  # ==========================================
  # Slot Tests
  # ==========================================

  test "renders with leading slot" do
    render_inline(Sketch::ListItemComponent.new(title: "With Leading")) do |item|
      item.with_leading { "<div class='custom-leading'>L</div>".html_safe }
    end

    assert_selector ".custom-leading", text: "L"
  end

  test "renders with trailing slot" do
    render_inline(Sketch::ListItemComponent.new(title: "With Trailing")) do |item|
      item.with_trailing { "<div class='custom-trailing'>T</div>".html_safe }
    end

    assert_selector ".custom-trailing", text: "T"
  end

  # ==========================================
  # Variant Tests
  # ==========================================

  test "renders default variant" do
    render_inline(Sketch::ListItemComponent.new(title: "Default"))

    assert_selector "div.sketch-list-item"
  end

  test "renders setting variant" do
    render_inline(Sketch::ListItemComponent.new(title: "Setting", variant: :setting))

    assert_selector "div.hover\\:bg-sketch-cream"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::ListItemComponent.new(title: "Custom", class: "my-custom-class"))

    assert_selector ".sketch-list-item.my-custom-class"
  end
end
