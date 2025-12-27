# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Input Component
  #
  # @example Basic text input
  #   <%= render Sketch::InputComponent.new(name: "email", type: :email, placeholder: "Enter email") %>
  #
  # @example With label and helper text
  #   <%= render Sketch::InputComponent.new(
  #     name: "username",
  #     label: "Username",
  #     helper: "Choose a unique username",
  #     required: true
  #   ) %>
  #
  # @example Textarea
  #   <%= render Sketch::InputComponent.new(
  #     name: "bio",
  #     type: :textarea,
  #     rows: 4,
  #     label: "Bio"
  #   ) %>
  #
  class InputComponent < BaseComponent
    TYPES = %i[text email password tel url number date textarea select].freeze

    VARIANTS = {
      default: {
        bg: "bg-sketch-paper",
        border: "border-sketch-ink",
        focus: "focus:ring-sketch-ink"
      },
      filled: {
        bg: "bg-sketch-cream",
        border: "border-transparent",
        focus: "focus:ring-sketch-ink focus:border-sketch-ink"
      },
      underline: {
        bg: "bg-transparent",
        border: "border-b-2 border-t-0 border-l-0 border-r-0 rounded-none border-sketch-gray",
        focus: "focus:ring-0 focus:border-sketch-ink"
      }
    }.freeze

    def initialize(
      name:,
      type: :text,
      variant: :default,
      label: nil,
      placeholder: nil,
      value: nil,
      helper: nil,
      error: nil,
      required: false,
      rows: 3,
      options: [],
      **attrs
    )
      @name = name
      @type = type.to_sym
      @variant = variant
      @label = label
      @placeholder = placeholder
      @value = value
      @helper = helper
      @error = error
      @required = required
      @rows = rows
      @select_options = options
      @attrs = attrs
      super(**attrs.slice(:roughness, :size, :disabled, :loading))
    end

    def input_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:default])

      [
        base_classes,
        "w-full",
        size_config[:padding],
        size_config[:text],
        variant_config[:bg],
        "border-2",
        variant_config[:focus],
        "rounded-sketch-md",
        "font-sketch",
        "placeholder:text-sketch-gray placeholder:font-sketch",
        "focus:outline-none focus:ring-2 focus:ring-offset-1",
        @error ? "border-sketch-error" : "",
        disabled? ? "bg-sketch-cream/50" : ""
      ].compact.join(" ")
    end

    def input_data
      stimulus_data("input", {
        action: "focus->sketch-input#onFocus blur->sketch-input#onBlur"
      })
    end

    def wrapper_classes
      "sketch-input-wrapper relative"
    end

    def label_classes
      "block mb-1.5 font-sketch text-sm font-medium text-sketch-ink"
    end

    def helper_classes
      "mt-1.5 text-xs font-sketch text-sketch-gray"
    end

    def error_classes
      "mt-1.5 text-xs font-sketch text-sketch-error"
    end

    def input_id
      @attrs[:id] || "input_#{@name}"
    end

    def input_name
      @name
    end

    def input_type
      return nil if textarea? || select?
      @type.to_s
    end

    def textarea?
      @type == :textarea
    end

    def select?
      @type == :select
    end

    def has_label?
      @label.present?
    end

    def has_helper?
      @helper.present? && @error.blank?
    end

    def has_error?
      @error.present?
    end

    def required?
      @required
    end

    def placeholder_text
      @placeholder
    end

    def input_value
      @value
    end

    def textarea_rows
      @rows
    end

    def select_options
      @select_options
    end

    def label_text
      text = @label
      text += " *" if required?
      text
    end

    def helper_text
      @helper
    end

    def error_text
      @error
    end

    def aria_describedby
      return "#{input_id}_error" if has_error?
      return "#{input_id}_helper" if has_helper?
      nil
    end
  end
end
