# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Modal Component
  #
  # @example Basic modal
  #   <%= render Sketch::ModalComponent.new(id: "confirm-modal", title: "Confirm Action") do %>
  #     <p>Are you sure you want to proceed?</p>
  #   <% end %>
  #
  # @example Modal with footer actions
  #   <%= render Sketch::ModalComponent.new(id: "edit-modal", title: "Edit Item", size: :lg) do |modal| %>
  #     <% modal.with_body do %>
  #       <p>Modal content here</p>
  #     <% end %>
  #     <% modal.with_footer do %>
  #       <%= render Sketch::ButtonComponent.new(variant: :ghost) do %>Cancel<% end %>
  #       <%= render Sketch::ButtonComponent.new(variant: :primary) do %>Save<% end %>
  #     <% end %>
  #   <% end %>
  #
  class ModalComponent < BaseComponent
    SIZES = {
      sm: "max-w-sm",
      md: "max-w-md",
      lg: "max-w-lg",
      xl: "max-w-xl",
      full: "max-w-4xl"
    }.freeze

    renders_one :header
    renders_one :body
    renders_one :footer

    def initialize(
      id:,
      title: nil,
      size: :md,
      closable: true,
      backdrop_close: true,
      **options
    )
      @id = id
      @title = title
      @modal_size = size
      @closable = closable
      @backdrop_close = backdrop_close
      super(**options)
    end

    def modal_id
      @id
    end

    def modal_classes
      [
        base_classes,
        "fixed inset-0 z-50",
        "flex items-center justify-center",
        "p-4"
      ].compact.join(" ")
    end

    def backdrop_classes
      [
        "absolute inset-0",
        "bg-sketch-ink/40 backdrop-blur-sm",
        "transition-opacity duration-300"
      ].join(" ")
    end

    def dialog_classes
      size_class = SIZES.fetch(@modal_size, SIZES[:md])
      [
        "relative z-10",
        "w-full",
        size_class,
        "bg-sketch-paper",
        "rounded-sketch-lg",
        "border-2 border-sketch-ink",
        "shadow-sketch-lg",
        "transform transition-all duration-300"
      ].join(" ")
    end

    def header_classes
      "flex items-center justify-between px-5 py-4 border-b-2 border-sketch-gray/30"
    end

    def title_classes
      "font-sketch text-lg font-semibold text-sketch-ink"
    end

    def body_classes
      "px-5 py-4"
    end

    def footer_classes
      "flex items-center justify-end gap-3 px-5 py-4 border-t-2 border-sketch-gray/30"
    end

    def close_button_classes
      [
        "p-1 rounded-sketch-sm",
        "text-sketch-gray hover:text-sketch-ink",
        "hover:bg-sketch-cream",
        "transition-colors duration-200"
      ].join(" ")
    end

    def modal_data
      {
        controller: "sketch-modal",
        "sketch-modal-roughness-value": roughness_value,
        "sketch-modal-backdrop-close-value": @backdrop_close,
        action: "keydown.escape->sketch-modal#close"
      }
    end

    def has_title?
      @title.present? || header?
    end

    def title_text
      @title
    end

    def closable?
      @closable
    end

    def has_body?
      body?
    end

    def has_footer?
      footer?
    end
  end
end
