# frozen_string_literal: true

module Sketch
  # Sketch 스타일 버튼 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 버튼
  #
  # 주요 기능:
  # - 다양한 버튼 스타일 (primary, secondary, ghost, danger)
  # - 아이콘 지원 (좌/우 위치)
  # - 로딩/비활성화 상태
  # - RoughJS 기반 스케치 테두리
  #
  # @param variant [Symbol] 버튼 스타일 (:primary, :secondary, :ghost, :danger)
  # @param type [Symbol] 버튼 타입 (:button, :submit, :reset)
  # @param icon [String] 아이콘 이름
  # @param icon_position [Symbol] 아이콘 위치 (:left, :right)
  # @param full_width [Boolean] 전체 너비 사용 여부
  #
  # @example 기본 사용
  #   render Sketch::ButtonComponent.new(variant: :primary) { "클릭" }
  class ButtonComponent < BaseComponent
    VARIANTS = {
      primary: {
        bg: "bg-sketch-paper",
        text: "text-sketch-ink",
        border: "border-sketch-ink",
        hover: "hover:bg-sketch-cream"
      },
      secondary: {
        bg: "bg-transparent",
        text: "text-sketch-ink",
        border: "border-sketch-gray",
        hover: "hover:bg-sketch-cream/50"
      },
      ghost: {
        bg: "bg-transparent",
        text: "text-sketch-ink",
        border: "border-transparent",
        hover: "hover:bg-sketch-cream"
      },
      danger: {
        bg: "bg-sketch-paper",
        text: "text-sketch-error",
        border: "border-sketch-error",
        hover: "hover:bg-red-50"
      }
    }.freeze

    def initialize(
      variant: :primary,
      type: :button,
      icon: nil,
      icon_position: :left,
      full_width: false,
      **options
    )
      @variant = variant
      @type = type
      @icon = icon
      @icon_position = icon_position
      @full_width = full_width
      super(**options)
    end

    def button_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:primary])
      [
        base_classes,
        size_config[:padding],
        size_config[:text],
        variant_config[:bg],
        variant_config[:text],
        variant_config[:hover],
        "border-2",
        "font-sketch font-medium",
        "rounded-sketch-md",
        "inline-flex items-center justify-center gap-2",
        @full_width ? "w-full" : "",
        "focus:outline-none focus:ring-2 focus:ring-sketch-ink focus:ring-offset-2",
        "active:translate-y-px"
      ].compact.join(" ")
    end

    def button_data
      stimulus_data("button", {
        "sketch-button-variant-value": @variant,
        action: "mouseenter->sketch-button#onHover mouseleave->sketch-button#onLeave"
      })
    end

    def icon_classes
      size_config[:icon]
    end

    def has_icon?
      @icon.present?
    end

    def icon_left?
      @icon_position == :left
    end

    def icon_name
      @icon
    end

    def button_type
      @type.to_s
    end

    def aria_disabled
      disabled? ? "true" : nil
    end

    def aria_busy
      loading? ? "true" : nil
    end
  end
end
