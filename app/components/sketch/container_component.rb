# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Container Component
  #
  # @example Basic container
  #   <%= render Sketch::ContainerComponent.new do %>
  #     Content here
  #   <% end %>
  #
  # @example With variant and custom tag
  #   <%= render Sketch::ContainerComponent.new(tag: :section, variant: :card) do %>
  #     Card content
  #   <% end %>
  #
  class ContainerComponent < BaseComponent
    VARIANTS = {
      default: "bg-white",
      paper: "bg-sketch-paper",
      cream: "bg-sketch-cream",
      glass: "bg-white/70 backdrop-blur-md",
      card: "bg-white rounded-xl border border-sketch-gray/20 shadow-sm"
    }.freeze

    PADDING = {
      none: "p-0",
      sm: "p-2",
      md: "p-4",
      lg: "p-6",
      xl: "p-8"
    }.freeze

    def initialize(tag: :div, variant: :default, border: true, padding: :md, **options)
      @tag = tag
      @variant = variant
      @border = border
      @padding = padding
      @custom_class = options.delete(:class)
      super(**options)
    end

    def container_tag
      @tag
    end

    def container_classes
      variant_classes = VARIANTS.fetch(@variant, VARIANTS[:default])
      padding_classes = PADDING.fetch(@padding, PADDING[:md])

      [
        "sketch-container",
        "relative",
        variant_classes,
        padding_classes,
        @border ? "sketch-border-container" : "",
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def container_data
      return {} unless @border

      {
        controller: "sketch-border",
        "sketch-border-roughness-value": roughness_value
      }
    end
  end
end
