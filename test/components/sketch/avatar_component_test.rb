# frozen_string_literal: true

require "test_helper"

class Sketch::AvatarComponentTest < ViewComponent::TestCase
  # ==========================================
  # Basic Rendering Tests
  # ==========================================

  test "renders avatar with default settings" do
    render_inline(Sketch::AvatarComponent.new)

    assert_selector "div.sketch-avatar"
    assert_selector "div.w-10.h-10" # md size default
  end

  test "renders avatar with image" do
    render_inline(Sketch::AvatarComponent.new(
      src: "https://example.com/avatar.jpg",
      alt: "User Avatar"
    ))

    assert_selector "img[src='https://example.com/avatar.jpg'][alt='User Avatar']"
    assert_selector "img.rounded-full.object-cover"
  end

  test "renders avatar with initials when no image" do
    render_inline(Sketch::AvatarComponent.new(initials: "JD"))

    assert_selector "span", text: "JD"
  end

  test "renders avatar with truncated initials" do
    render_inline(Sketch::AvatarComponent.new(initials: "JOHN"))

    assert_selector "span", text: "JO"
  end

  test "renders default user icon when no image or initials" do
    render_inline(Sketch::AvatarComponent.new)

    assert_selector "svg" # lucide user icon
  end

  # ==========================================
  # Size Tests
  # ==========================================

  test "renders xs size avatar" do
    render_inline(Sketch::AvatarComponent.new(size: :xs))

    assert_selector "div.w-6.h-6"
  end

  test "renders sm size avatar" do
    render_inline(Sketch::AvatarComponent.new(size: :sm))

    assert_selector "div.w-8.h-8"
  end

  test "renders md size avatar (default)" do
    render_inline(Sketch::AvatarComponent.new(size: :md))

    assert_selector "div.w-10.h-10"
  end

  test "renders lg size avatar" do
    render_inline(Sketch::AvatarComponent.new(size: :lg))

    assert_selector "div.w-12.h-12"
  end

  test "renders xl size avatar" do
    render_inline(Sketch::AvatarComponent.new(size: :xl))

    assert_selector "div.w-16.h-16"
  end

  # ==========================================
  # Border Tests
  # ==========================================

  test "renders avatar with border by default" do
    render_inline(Sketch::AvatarComponent.new)

    assert_selector "div.border-2.border-sketch-ink"
  end

  test "renders avatar without border when border is false" do
    render_inline(Sketch::AvatarComponent.new(border: false))

    assert_no_selector "div.border-2"
  end

  # ==========================================
  # Status Indicator Tests
  # ==========================================

  test "renders online status indicator" do
    render_inline(Sketch::AvatarComponent.new(status: :online))

    assert_selector "span.bg-emerald-500.rounded-full"
  end

  test "renders offline status indicator" do
    render_inline(Sketch::AvatarComponent.new(status: :offline))

    assert_selector "span.bg-gray-400.rounded-full"
  end

  test "renders away status indicator" do
    render_inline(Sketch::AvatarComponent.new(status: :away))

    assert_selector "span.bg-amber-500.rounded-full"
  end

  test "renders busy status indicator" do
    render_inline(Sketch::AvatarComponent.new(status: :busy))

    assert_selector "span.bg-red-500.rounded-full"
  end

  test "does not render status indicator when status is nil" do
    render_inline(Sketch::AvatarComponent.new)

    assert_no_selector "span.rounded-full.absolute"
  end

  # ==========================================
  # Custom Class Tests
  # ==========================================

  test "accepts custom classes" do
    render_inline(Sketch::AvatarComponent.new(class: "my-custom-class"))

    assert_selector "div.sketch-avatar.my-custom-class"
  end
end
