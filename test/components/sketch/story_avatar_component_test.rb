# frozen_string_literal: true

require "test_helper"

class Sketch::StoryAvatarComponentTest < ViewComponent::TestCase
  test "renders with default state (not selected)" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준",
      selected: false
    ))

    assert_selector ".story-avatar"
    assert_selector ".story-avatar-ring:not(.story-avatar-ring--selected)"
    assert_text "민준"
  end

  test "renders with selected state" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준",
      selected: true
    ))

    assert_selector ".story-avatar-ring.story-avatar-ring--selected"
  end

  test "renders with image" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준",
      src: "https://example.com/avatar.jpg"
    ))

    assert_selector "img[src='https://example.com/avatar.jpg']"
  end

  test "renders with initials when no image" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준이"
    ))

    assert_text "민준"
  end

  test "renders all option" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "전체",
      is_all: true,
      selected: true
    ))

    assert_selector ".story-avatar--all"
    assert_text "전체"
  end

  test "renders with custom size" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준",
      size: :lg
    ))

    assert_selector ".story-avatar--lg"
  end

  test "renders clickable when href provided" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준",
      href: "/home2?child_id=1"
    ))

    assert_selector "a[href='/home2?child_id=1']"
  end

  test "renders with data attributes for turbo" do
    render_inline(Sketch::StoryAvatarComponent.new(
      name: "민준",
      href: "/home2?child_id=1",
      turbo_frame: "timeline"
    ))

    assert_selector "a[data-turbo-frame='timeline']"
  end
end
