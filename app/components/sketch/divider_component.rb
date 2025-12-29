# frozen_string_literal: true

module Sketch
  # Sketch 스타일 구분선 컴포넌트
  #
  # 역할: Frame0 디자인 시스템의 스케치 스타일 콘텐츠 구분선
  #
  # 주요 기능:
  # - 가로/세로 방향 지원
  # - 다양한 선 스타일 (solid, dashed, dotted, rough)
  # - 다양한 두께 (thin, normal, thick)
  # - ARIA orientation 속성 자동 설정
  #
  # @param direction [Symbol] 방향 (:horizontal, :vertical)
  # @param variant [Symbol] 선 스타일 (:solid, :dashed, :dotted, :rough)
  # @param thickness [Symbol] 두께 (:thin, :normal, :thick)
  #
  # @example 가로 구분선
  #   render Sketch::DividerComponent.new
  #
  # @example 세로 점선 구분선
  #   render Sketch::DividerComponent.new(direction: :vertical, variant: :dashed)
  class DividerComponent < BaseComponent
    THICKNESS = {
      thin: 1,
      normal: 2,
      thick: 4
    }.freeze

    def initialize(direction: :horizontal, variant: :solid, thickness: :normal, **options)
      @direction = direction
      @variant = variant
      @thickness = thickness
      @custom_class = options.delete(:class)
      super(**options)
    end

    def divider_classes
      [
        "sketch-divider",
        direction_classes,
        "border-sketch-gray",
        border_style_class,
        thickness_class,
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def aria_orientation
      @direction.to_s
    end

    private

    def direction_classes
      case @direction
      when :horizontal
        "w-full h-0"
      when :vertical
        "h-full w-0"
      else
        "w-full h-0"
      end
    end

    def border_style_class
      case @variant
      when :dashed then "border-dashed"
      when :dotted then "border-dotted"
      when :rough then "sketch-rough-line"
      else "border-solid"
      end
    end

    def thickness_class
      thickness_value = THICKNESS.fetch(@thickness, 2)
      case @direction
      when :horizontal
        "border-t#{thickness_value > 1 ? "-#{thickness_value}" : ""}"
      when :vertical
        "border-l#{thickness_value > 1 ? "-#{thickness_value}" : ""}"
      else
        "border-t#{thickness_value > 1 ? "-#{thickness_value}" : ""}"
      end
    end
  end
end
