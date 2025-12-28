# frozen_string_literal: true

require "test_helper"

class Sketch::ContainerComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders container with block content" do
    render_inline(Sketch::ContainerComponent.new) do
      "Container content"
    end

    assert_selector "div.sketch-container", text: "Container content"
  end

  test "renders with custom tag" do
    render_inline(Sketch::ContainerComponent.new(tag: :section)) do
      "Section content"
    end

    assert_selector "section.sketch-container"
  end

  # ==========================================
  # Variant Tests
  # ==========================================

  test "renders default variant" do
    render_inline(Sketch::ContainerComponent.new) { "Content" }

    assert_selector "div.bg-white"
  end

  test "renders paper variant" do
    render_inline(Sketch::ContainerComponent.new(variant: :paper)) { "Content" }

    assert_selector "div.bg-sketch-paper"
  end

  test "renders cream variant" do
    render_inline(Sketch::ContainerComponent.new(variant: :cream)) { "Content" }

    assert_selector "div.bg-sketch-cream"
  end

  test "renders glass variant" do
    render_inline(Sketch::ContainerComponent.new(variant: :glass)) { "Content" }

    assert_selector "div.backdrop-blur-md"
  end

  test "renders card variant" do
    render_inline(Sketch::ContainerComponent.new(variant: :card)) { "Content" }

    assert_selector "div.rounded-xl.border"
  end

  # ==========================================
  # Border Tests
  # ==========================================

  test "renders with border by default" do
    render_inline(Sketch::ContainerComponent.new) { "Content" }

    assert_selector "div.sketch-border-container"
  end

  test "renders without border when border is false" do
    render_inline(Sketch::ContainerComponent.new(border: false)) { "Content" }

    assert_no_selector "div.sketch-border-container"
  end

  # ==========================================
  # Padding Tests
  # ==========================================

  test "renders with no padding" do
    render_inline(Sketch::ContainerComponent.new(padding: :none)) { "Content" }

    assert_selector "div.p-0"
  end

  test "renders with sm padding" do
    render_inline(Sketch::ContainerComponent.new(padding: :sm)) { "Content" }

    assert_selector "div.p-2"
  end

  test "renders with md padding (default)" do
    render_inline(Sketch::ContainerComponent.new(padding: :md)) { "Content" }

    assert_selector "div.p-4"
  end

  test "renders with lg padding" do
    render_inline(Sketch::ContainerComponent.new(padding: :lg)) { "Content" }

    assert_selector "div.p-6"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::ContainerComponent.new(class: "my-custom-class")) { "Content" }

    assert_selector "div.sketch-container.my-custom-class"
  end
end
