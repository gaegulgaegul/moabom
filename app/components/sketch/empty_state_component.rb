# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Empty State Component
  #
  # @example Basic empty state
  #   <%= render Sketch::EmptyStateComponent.new(
  #     icon: "image",
  #     title: "No photos yet",
  #     description: "Start uploading your memories"
  #   ) %>
  #
  # @example With action button
  #   <%= render Sketch::EmptyStateComponent.new(
  #     icon: "image",
  #     title: "No photos yet",
  #     description: "Start uploading your memories",
  #     action_text: "Upload Photo",
  #     action_href: "/photos/new"
  #   ) %>
  #
  class EmptyStateComponent < BaseComponent
    renders_one :action

    SIZES = {
      sm: { padding: "py-8", icon: "w-12 h-12", title: "text-lg", desc: "text-sm" },
      md: { padding: "py-12", icon: "w-16 h-16", title: "text-xl", desc: "text-base" },
      lg: { padding: "py-16", icon: "w-20 h-20", title: "text-2xl", desc: "text-lg" }
    }.freeze

    def initialize(
      title:,
      description: nil,
      icon: nil,
      action_text: nil,
      action_href: nil,
      size: :md,
      **options
    )
      @title = title
      @description = description
      @icon = icon
      @action_text = action_text
      @action_href = action_href
      @empty_size = size
      @custom_class = options.delete(:class)
      super(**options)
    end

    def container_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])

      [
        "sketch-empty-state",
        "flex flex-col items-center justify-center",
        "text-center px-4",
        size_config[:padding],
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
      size_config = SIZES.fetch(@empty_size, SIZES[:md])
      "#{size_config[:icon]} text-sketch-gray/50"
    end

    def title_text
      @title
    end

    def title_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])
      "font-sketch font-medium text-sketch-ink #{size_config[:title]}"
    end

    def has_description?
      @description.present?
    end

    def description_text
      @description
    end

    def description_classes
      size_config = SIZES.fetch(@empty_size, SIZES[:md])
      "font-hand text-sketch-gray #{size_config[:desc]}"
    end

    def has_action?
      @action_text.present? && @action_href.present?
    end

    def action_text
      @action_text
    end

    def action_href
      @action_href
    end
  end
end
