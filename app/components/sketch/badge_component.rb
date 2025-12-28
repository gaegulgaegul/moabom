# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Badge Component
  #
  # @example Basic badge
  #   <%= render Sketch::BadgeComponent.new(text: "New") %>
  #
  # @example With variant and icon
  #   <%= render Sketch::BadgeComponent.new(text: "3 photos", variant: :primary, icon: "photo") %>
  #
  class BadgeComponent < BaseComponent
    VARIANTS = {
      default: "bg-sketch-cream text-sketch-ink border-sketch-gray",
      primary: "bg-primary-100 text-primary-800 border-primary-300",
      secondary: "bg-secondary-100 text-secondary-800 border-secondary-300",
      success: "bg-emerald-100 text-emerald-800 border-emerald-300",
      warning: "bg-amber-100 text-amber-800 border-amber-300",
      danger: "bg-red-100 text-red-800 border-red-300",
      info: "bg-blue-100 text-blue-800 border-blue-300"
    }.freeze

    SIZES = {
      sm: { padding: "px-2 py-0.5", text: "text-xs", icon: "w-3 h-3" },
      md: { padding: "px-2.5 py-1", text: "text-sm", icon: "w-4 h-4" },
      lg: { padding: "px-3 py-1.5", text: "text-base", icon: "w-5 h-5" }
    }.freeze

    def initialize(text: nil, variant: :default, size: :md, rounded: true, icon: nil, **options)
      @text = text
      @variant = variant
      @badge_size = size
      @rounded = rounded
      @icon = icon
      @custom_class = options.delete(:class)
      super(**options)
    end

    def badge_classes
      size_config = SIZES.fetch(@badge_size, SIZES[:md])
      variant_classes = VARIANTS.fetch(@variant, VARIANTS[:default])

      [
        "sketch-badge",
        "inline-flex items-center gap-1",
        "font-sketch font-medium",
        "border",
        size_config[:padding],
        size_config[:text],
        variant_classes,
        @rounded ? "rounded-full" : "rounded-sketch-sm",
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def has_icon?
      @icon.present?
    end

    def icon_name
      @icon
    end

    def icon_classes
      size_config = SIZES.fetch(@badge_size, SIZES[:md])
      size_config[:icon]
    end

    def badge_text
      @text
    end

    def render?
      @text.present? || content.present?
    end
  end
end
