# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Card Component
  #
  # @example Basic usage
  #   <%= render Sketch::CardComponent.new do %>
  #     <p>Card content here</p>
  #   <% end %>
  #
  # @example With header and footer
  #   <%= render Sketch::CardComponent.new(variant: :elevated) do |card| %>
  #     <% card.with_header do %>Card Title<% end %>
  #     <p>Card content</p>
  #     <% card.with_footer do %>Footer actions<% end %>
  #   <% end %>
  #
  class CardComponent < BaseComponent
    VARIANTS = {
      default: {
        bg: "bg-sketch-paper",
        border: "border-sketch-ink",
        shadow: ""
      },
      elevated: {
        bg: "bg-sketch-paper",
        border: "border-sketch-ink",
        shadow: "shadow-sketch-md"
      },
      flat: {
        bg: "bg-sketch-cream",
        border: "border-sketch-gray",
        shadow: ""
      },
      glass: {
        bg: "bg-white/70 backdrop-blur-md",
        border: "border-white/20",
        shadow: "shadow-lg"
      }
    }.freeze

    renders_one :header
    renders_one :footer
    renders_one :image, ->(src:, alt: "", **options) do
      tag.div(class: "sketch-card-image -mx-4 -mt-4 mb-4 overflow-hidden rounded-t-sketch-lg") do
        tag.img(src: src, alt: alt, class: "w-full h-48 object-cover", **options)
      end
    end

    def initialize(variant: :default, padding: :md, hoverable: false, clickable: false, href: nil, **options)
      @variant = variant
      @padding = padding
      @hoverable = hoverable
      @clickable = clickable
      @href = href
      super(**options)
    end

    def card_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:default])
      padding_class = case @padding
      when :none then ""
      when :sm then "p-3"
      when :md then "p-4"
      when :lg then "p-6"
      else "p-4"
      end

      [
        base_classes,
        variant_config[:bg],
        variant_config[:shadow],
        "border-2",
        "rounded-sketch-lg",
        padding_class,
        @hoverable ? "hover:shadow-sketch-lg hover:-translate-y-1 cursor-pointer" : "",
        @clickable ? "cursor-pointer" : ""
      ].compact.join(" ")
    end

    def card_data
      stimulus_data("card", {
        "sketch-card-hoverable-value": @hoverable,
        action: @hoverable ? "mouseenter->sketch-card#onHover mouseleave->sketch-card#onLeave" : ""
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

    def header?
      header.present?
    end

    def footer?
      footer.present?
    end

    def image?
      image.present?
    end
  end
end
