# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Gallery Card Component
  # A card with a collage/bento grid image layout
  #
  # @example Basic usage with 3 images
  #   <%= render Sketch::GalleryCardComponent.new do |card| %>
  #     <% card.with_main_image(src: "photo1.jpg", alt: "Main photo") %>
  #     <% card.with_secondary_image(src: "photo2.jpg", alt: "Second photo") %>
  #     <% card.with_tertiary_image(src: "photo3.jpg", alt: "Third photo", more_count: 5) %>
  #     <p>Gallery description here</p>
  #   <% end %>
  #
  class GalleryCardComponent < BaseComponent
    renders_one :main_image, ->(src:, alt: "", **options) do
      tag.div(class: "relative w-full h-full overflow-hidden") do
        tag.img(src: src, alt: alt, class: "w-full h-full object-cover", **options)
      end
    end

    renders_one :secondary_image, ->(src:, alt: "", **options) do
      tag.div(class: "relative w-full h-full overflow-hidden") do
        tag.img(src: src, alt: alt, class: "w-full h-full object-cover", **options)
      end
    end

    renders_one :tertiary_image, ->(src:, alt: "", more_count: nil, more_text: nil, **options) do
      tag.div(class: "relative w-full h-full overflow-hidden") do
        safe_join([
          tag.img(src: src, alt: alt, class: "w-full h-full object-cover", **options),
          if more_count.present? || more_text.present?
            overlay_text = more_text || "+#{more_count} 더보기"
            tag.div(class: "absolute inset-0 bg-sketch-overlay-medium flex items-center justify-center") do
              tag.span(overlay_text, class: "text-white font-sketch text-lg font-semibold")
            end
          end
        ].compact)
      end
    end

    def initialize(variant: :default, aspect_ratio: :landscape, hoverable: false, href: nil, **options)
      @variant = variant
      @aspect_ratio = aspect_ratio
      @hoverable = hoverable
      @href = href
      super(**options)
    end

    def card_classes
      base = [
        base_classes,
        "bg-sketch-paper",
        "border-2 border-sketch-ink",
        "rounded-sketch-lg",
        "overflow-hidden",
        @hoverable ? "hover:shadow-sketch-lg hover:-translate-y-1 cursor-pointer transition-all duration-200" : ""
      ]
      base.compact.join(" ")
    end

    def grid_height_class
      case @aspect_ratio
      when :square then "h-64"
      when :landscape then "h-48"
      when :portrait then "h-72"
      else "h-48"
      end
    end

    def card_data
      stimulus_data("card", {
        "sketch-card-hoverable-value": @hoverable
      })
    end

    def wrapper_tag
      @href.present? ? :a : :div
    end

    def wrapper_options
      opts = { class: card_classes, data: card_data }
      opts[:href] = @href if @href.present?
      opts
    end

    def has_images?
      main_image.present? || secondary_image.present? || tertiary_image.present?
    end
  end
end
