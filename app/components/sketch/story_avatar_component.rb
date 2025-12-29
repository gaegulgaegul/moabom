# frozen_string_literal: true

module Sketch
  # Sketch 스타일 스토리 아바타 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 인스타그램 스토리 스타일 아바타
  #
  # 주요 기능:
  # - 선택 상태 링 애니메이션
  # - 다양한 크기 지원 (sm, md, lg)
  # - 이미지 또는 이니셜 표시
  # - '전체' 옵션을 위한 특별 스타일
  # - 이름 표시 (자동 말줄임)
  # - 링크 및 Turbo Frame 지원
  #
  # @param name [String] 표시 이름 (필수)
  # @param src [String] 아바타 이미지 URL
  # @param selected [Boolean] 선택 상태
  # @param is_all [Boolean] '전체' 옵션 여부
  # @param size [Symbol] 크기 (:sm, :md, :lg)
  # @param href [String] 링크 URL
  # @param turbo_frame [String] Turbo Frame 타겟
  #
  # @example 기본 사용
  #   render Sketch::StoryAvatarComponent.new(name: "민준", src: child.avatar_url)
  #
  # @example 선택된 상태
  #   render Sketch::StoryAvatarComponent.new(name: "민준", selected: true)
  #
  # @example 전체 옵션
  #   render Sketch::StoryAvatarComponent.new(name: "전체", is_all: true, selected: true)
  class StoryAvatarComponent < BaseComponent
    SIZES = {
      sm: { container: "w-14", avatar: "w-12 h-12", text: "text-xs", ring: "p-0.5" },
      md: { container: "w-16", avatar: "w-14 h-14", text: "text-xs", ring: "p-0.5" },
      lg: { container: "w-20", avatar: "w-16 h-16", text: "text-sm", ring: "p-1" }
    }.freeze

    def initialize(name:, src: nil, selected: false, is_all: false, size: :md, href: nil, turbo_frame: nil, **options)
      @name = name
      @src = src
      @selected = selected
      @is_all = is_all
      @story_size = size
      @href = href
      @turbo_frame = turbo_frame
      super(**options)
    end

    def container_classes
      size_config = SIZES.fetch(@story_size, SIZES[:md])
      [
        "story-avatar",
        "story-avatar--#{@story_size}",
        "flex flex-col items-center gap-1",
        size_config[:container],
        @is_all ? "story-avatar--all" : ""
      ].compact.reject(&:blank?).join(" ")
    end

    def ring_classes
      size_config = SIZES.fetch(@story_size, SIZES[:md])
      [
        "story-avatar-ring",
        "rounded-full",
        size_config[:ring],
        @selected ? "story-avatar-ring--selected bg-gradient-to-tr from-primary-400 to-accent-500" : "bg-sketch-cream",
        @selected ? "ring-2 ring-primary-500 ring-offset-2" : "border-2 border-sketch-gray/30"
      ].join(" ")
    end

    def avatar_classes
      size_config = SIZES.fetch(@story_size, SIZES[:md])
      [
        "rounded-full",
        "bg-sketch-cream",
        "flex items-center justify-center",
        "overflow-hidden",
        "border-2 border-white",
        size_config[:avatar]
      ].join(" ")
    end

    def name_classes
      size_config = SIZES.fetch(@story_size, SIZES[:md])
      [
        "font-hand",
        "text-center",
        "truncate",
        "w-full",
        size_config[:text],
        @selected ? "text-sketch-ink font-medium" : "text-sketch-gray"
      ].join(" ")
    end

    def displayed_name
      @name.to_s.truncate(4, omission: "")
    end

    def displayed_initials
      @name.to_s[0..1]
    end

    def has_image?
      @src.present?
    end

    def is_all?
      @is_all
    end

    def wrapper_tag
      @href.present? ? :a : :div
    end

    def wrapper_options
      opts = { class: container_classes }
      if @href.present?
        opts[:href] = @href
        opts[:data] = { turbo_frame: @turbo_frame } if @turbo_frame.present?
      end
      opts
    end
  end
end
