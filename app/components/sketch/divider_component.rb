# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Divider Component
  #
  # @example Horizontal divider
  #   <%= render Sketch::DividerComponent.new %>
  #
  # @example Vertical dashed divider
  #   <%= render Sketch::DividerComponent.new(direction: :vertical, variant: :dashed) %>
  #
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
