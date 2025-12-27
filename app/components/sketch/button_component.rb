# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Button Component
  #
  # @example Basic usage
  #   <%= render Sketch::ButtonComponent.new(variant: :primary) do %>
  #     Click me
  #   <% end %>
  #
  # @example With icon and loading state
  #   <%= render Sketch::ButtonComponent.new(variant: :secondary, loading: true, icon: "plus") do %>
  #     Add Item
  #   <% end %>
  #
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
