# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style List Item Component
  #
  # @example Basic list item
  #   <%= render Sketch::ListItemComponent.new(title: "Settings", icon: "settings") %>
  #
  # @example With description and link
  #   <%= render Sketch::ListItemComponent.new(
  #     title: "Profile",
  #     description: "Edit your profile",
  #     href: "/settings/profile",
  #     show_chevron: true
  #   ) %>
  #
  # @example With custom slots
  #   <%= render Sketch::ListItemComponent.new(title: "Custom") do |item| %>
  #     <% item.with_leading do %>
  #       <%= render Sketch::AvatarComponent.new(initials: "JD") %>
  #     <% end %>
  #     <% item.with_trailing do %>
  #       <%= render Sketch::BadgeComponent.new(text: "New") %>
  #     <% end %>
  #   <% end %>
  #
  class ListItemComponent < BaseComponent
    renders_one :leading
    renders_one :trailing

    VARIANTS = {
      default: "",
      setting: "hover:bg-sketch-cream transition-colors",
      member: "hover:bg-sketch-cream/50"
    }.freeze

    def initialize(title:, description: nil, href: nil, icon: nil, show_chevron: false, variant: :default, **options)
      @title = title
      @description = description
      @href = href
      @icon = icon
      @show_chevron = show_chevron
      @variant = variant
      @custom_class = options.delete(:class)
      super(**options)
    end

    def list_item_classes
      variant_classes = VARIANTS.fetch(@variant, VARIANTS[:default])

      [
        "sketch-list-item",
        "flex items-center gap-3",
        "py-3 px-4",
        variant_classes,
        @custom_class
      ].compact.reject(&:blank?).join(" ")
    end

    def list_item_tag
      @href.present? ? :a : :div
    end

    def list_item_options
      opts = { class: list_item_classes }
      opts[:href] = @href if @href.present?
      opts
    end

    def has_icon?
      @icon.present?
    end

    def icon_name
      @icon
    end

    def title_text
      @title
    end

    def has_description?
      @description.present?
    end

    def description_text
      @description
    end

    def show_chevron?
      @show_chevron
    end

    def has_leading?
      leading? || has_icon?
    end
  end
end
