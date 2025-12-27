# frozen_string_literal: true

# Frame0 Sketch Design System Helpers
# Provides helper methods for creating sketch-style UI elements
#
# Usage:
#   <%= sketch_container(class: 'p-8') do %>
#     <p>Content with sketch border</p>
#   <% end %>
#
module SketchHelper
  # Default sketch configuration
  SKETCH_DEFAULTS = {
    roughness: 1.5,
    bowing: 1,
    stroke: "#1A1A1A",
    stroke_width: 1.5
  }.freeze

  # ============================================
  # 1. sketch_container - Generic sketch container
  # ============================================
  #
  # @param tag [Symbol] HTML tag to use (default: :div)
  # @param variant [Symbol] Style variant (:default, :paper, :cream, :glass)
  # @param border [Boolean] Whether to show sketch border
  # @param roughness [Symbol] Roughness level (:smooth, :normal, :rough, :sketchy)
  # @param options [Hash] Additional HTML options
  # @yield Block content
  # @return [String] HTML string
  #
  # @example Basic usage
  #   <%= sketch_container do %>Content<% end %>
  #
  # @example With options
  #   <%= sketch_container(tag: :section, variant: :paper, class: 'p-6') do %>
  #     Content
  #   <% end %>
  #
  def sketch_container(tag: :div, variant: :default, border: true, roughness: :normal, **options, &block)
    variant_classes = sketch_variant_classes(variant)
    roughness_value = sketch_roughness_value(roughness)

    base_classes = [
      "sketch-container",
      "relative",
      variant_classes,
      border ? "sketch-border-container" : "",
      options[:class]
    ].compact.join(" ")

    data_attrs = {
      controller: border ? "sketch-border" : nil,
      "sketch-border-roughness-value": border ? roughness_value : nil
    }.compact

    merged_options = options.merge(
      class: base_classes,
      data: (options[:data] || {}).merge(data_attrs)
    )

    content_tag(tag, **merged_options, &block)
  end

  # ============================================
  # 2. sketch_button - Sketch style button
  # ============================================
  #
  # @param text [String] Button text (or use block)
  # @param variant [Symbol] Style variant (:primary, :secondary, :ghost, :danger)
  # @param size [Symbol] Size (:xs, :sm, :md, :lg, :xl)
  # @param icon [String] Heroicon name
  # @param icon_position [Symbol] Icon position (:left, :right)
  # @param loading [Boolean] Show loading state
  # @param disabled [Boolean] Disable button
  # @param options [Hash] Additional HTML options
  #
  # @example Basic button
  #   <%= sketch_button("Click me", variant: :primary) %>
  #
  # @example With icon and block
  #   <%= sketch_button(variant: :secondary, icon: "plus") do %>
  #     Add Item
  #   <% end %>
  #
  def sketch_button(text = nil, variant: :primary, size: :md, icon: nil, icon_position: :left, loading: false, disabled: false, **options, &block)
    render Sketch::ButtonComponent.new(
      variant: variant,
      size: size,
      icon: icon,
      icon_position: icon_position,
      loading: loading,
      disabled: disabled,
      **options
    ) do
      block_given? ? capture(&block) : text
    end
  end

  # ============================================
  # 3. sketch_card - Sketch style card
  # ============================================
  #
  # @param variant [Symbol] Style variant (:default, :elevated, :flat, :glass)
  # @param padding [Symbol] Padding size (:none, :sm, :md, :lg)
  # @param hoverable [Boolean] Add hover effect
  # @param href [String] Make card clickable link
  # @param options [Hash] Additional HTML options
  #
  # @example Basic card
  #   <%= sketch_card do %>Card content<% end %>
  #
  # @example Clickable card
  #   <%= sketch_card(variant: :elevated, hoverable: true, href: photo_path(@photo)) do %>
  #     Photo card
  #   <% end %>
  #
  def sketch_card(variant: :default, padding: :md, hoverable: false, href: nil, **options, &block)
    render Sketch::CardComponent.new(
      variant: variant,
      padding: padding,
      hoverable: hoverable,
      href: href,
      **options
    ), &block
  end

  # ============================================
  # 4. sketch_input - Sketch style input field
  # ============================================
  #
  # @param name [String] Input name (required)
  # @param type [Symbol] Input type (:text, :email, :password, :textarea, :select)
  # @param variant [Symbol] Style variant (:default, :filled, :underline)
  # @param label [String] Label text
  # @param placeholder [String] Placeholder text
  # @param value [String] Input value
  # @param helper [String] Helper text
  # @param error [String] Error message
  # @param required [Boolean] Mark as required
  # @param options [Hash] Additional options
  #
  # @example Basic input
  #   <%= sketch_input(name: "email", type: :email, label: "Email") %>
  #
  # @example With error
  #   <%= sketch_input(name: "username", label: "Username", error: "Already taken") %>
  #
  def sketch_input(name:, type: :text, variant: :default, label: nil, placeholder: nil, value: nil, helper: nil, error: nil, required: false, **options)
    render Sketch::InputComponent.new(
      name: name,
      type: type,
      variant: variant,
      label: label,
      placeholder: placeholder,
      value: value,
      helper: helper,
      error: error,
      required: required,
      **options
    )
  end

  # ============================================
  # 5. sketch_icon - Sketch style icon wrapper
  # ============================================
  #
  # @param name [String] Lucide icon name (required)
  # @param size [Symbol] Icon size (:xs, :sm, :md, :lg, :xl)
  # @param sketch_style [Boolean] Apply sketch filter effect
  # @param color [String] Icon color class
  # @param options [Hash] Additional HTML options
  #
  # @example Basic icon
  #   <%= sketch_icon("heart") %>
  #
  # @example With sketch effect
  #   <%= sketch_icon("camera", size: :lg, sketch_style: true) %>
  #
  # Note: Lucide icons use kebab-case names (e.g., "arrow-left", "chevron-right")
  #
  def sketch_icon(name, size: :md, sketch_style: false, color: nil, **options)
    size_classes = {
      xs: "w-3 h-3",
      sm: "w-4 h-4",
      md: "w-5 h-5",
      lg: "w-6 h-6",
      xl: "w-8 h-8"
    }

    icon_classes = [
      size_classes[size] || size_classes[:md],
      color || "text-sketch-ink",
      sketch_style ? "sketch-icon" : "",
      options[:class]
    ].compact.join(" ")

    lucide_icon(name, class: icon_classes, **options.except(:class))
  end

  # ============================================
  # 6. sketch_divider - Sketch style divider line
  # ============================================
  #
  # @param direction [Symbol] Direction (:horizontal, :vertical)
  # @param variant [Symbol] Style variant (:solid, :dashed, :dotted, :rough)
  # @param thickness [Symbol] Line thickness (:thin, :normal, :thick)
  # @param options [Hash] Additional HTML options
  #
  # @example Horizontal divider
  #   <%= sketch_divider %>
  #
  # @example Vertical dashed divider
  #   <%= sketch_divider(direction: :vertical, variant: :dashed) %>
  #
  def sketch_divider(direction: :horizontal, variant: :solid, thickness: :normal, **options)
    thickness_map = { thin: 1, normal: 2, thick: 3 }
    stroke_width = thickness_map[thickness] || 2

    base_classes = [
      "sketch-divider",
      direction == :horizontal ? "w-full h-0" : "h-full w-0",
      "border-sketch-gray",
      options[:class]
    ].compact.join(" ")

    border_style = case variant
    when :dashed then "border-dashed"
    when :dotted then "border-dotted"
    when :rough then "sketch-rough-line"
    else "border-solid"
    end

    border_direction = direction == :horizontal ? "border-t-#{stroke_width}" : "border-l-#{stroke_width}"

    content_tag(:hr, nil, **options.merge(
      class: "#{base_classes} #{border_style} #{border_direction}",
      role: "separator",
      "aria-orientation": direction.to_s
    ))
  end

  # ============================================
  # 7. sketch_badge - Sketch style badge/tag
  # ============================================
  #
  # @param text [String] Badge text
  # @param variant [Symbol] Color variant (:default, :primary, :success, :warning, :error, :info)
  # @param size [Symbol] Badge size (:sm, :md, :lg)
  # @param rounded [Boolean] Fully rounded (pill shape)
  # @param icon [String] Optional heroicon name
  # @param options [Hash] Additional HTML options
  #
  # @example Basic badge
  #   <%= sketch_badge("New") %>
  #
  # @example With icon
  #   <%= sketch_badge("3 photos", variant: :primary, icon: "photo") %>
  #
  def sketch_badge(text, variant: :default, size: :md, rounded: true, icon: nil, **options)
    variant_classes = {
      default: "bg-sketch-cream text-sketch-ink border-sketch-gray",
      primary: "bg-primary-100 text-primary-800 border-primary-300",
      success: "bg-emerald-100 text-emerald-800 border-emerald-300",
      warning: "bg-amber-100 text-amber-800 border-amber-300",
      error: "bg-red-100 text-red-800 border-red-300",
      info: "bg-blue-100 text-blue-800 border-blue-300"
    }

    size_classes = {
      sm: "text-xs px-2 py-0.5",
      md: "text-sm px-2.5 py-1",
      lg: "text-base px-3 py-1.5"
    }

    icon_sizes = { sm: :xs, md: :sm, lg: :md }

    base_classes = [
      "sketch-badge",
      "inline-flex items-center gap-1",
      "font-sketch font-medium",
      "border",
      rounded ? "rounded-full" : "rounded-sketch-sm",
      variant_classes[variant] || variant_classes[:default],
      size_classes[size] || size_classes[:md],
      options[:class]
    ].compact.join(" ")

    content_tag(:span, **options.merge(class: base_classes)) do
      parts = []
      parts << sketch_icon(icon, size: icon_sizes[size], variant: :mini) if icon
      parts << text
      safe_join(parts)
    end
  end

  # ============================================
  # 8. sketch_avatar - Sketch style avatar
  # ============================================
  #
  # @param src [String] Image source URL
  # @param alt [String] Alt text
  # @param size [Symbol] Avatar size (:xs, :sm, :md, :lg, :xl)
  # @param initials [String] Initials to show if no image
  # @param border [Boolean] Show sketch border
  # @param status [Symbol] Online status (:online, :offline, :away, :busy)
  # @param options [Hash] Additional HTML options
  #
  # @example With image
  #   <%= sketch_avatar(src: user.avatar_url, alt: user.name) %>
  #
  # @example With initials
  #   <%= sketch_avatar(initials: "JD", size: :lg) %>
  #
  def sketch_avatar(src: nil, alt: "", size: :md, initials: nil, border: true, status: nil, **options)
    size_classes = {
      xs: "w-6 h-6 text-xs",
      sm: "w-8 h-8 text-sm",
      md: "w-10 h-10 text-base",
      lg: "w-12 h-12 text-lg",
      xl: "w-16 h-16 text-xl"
    }

    status_colors = {
      online: "bg-emerald-500",
      offline: "bg-gray-400",
      away: "bg-amber-500",
      busy: "bg-red-500"
    }

    base_classes = [
      "sketch-avatar",
      "relative inline-flex items-center justify-center",
      "rounded-full",
      "bg-sketch-cream",
      "font-sketch font-medium text-sketch-ink",
      border ? "border-2 border-sketch-ink" : "",
      size_classes[size] || size_classes[:md],
      options[:class]
    ].compact.join(" ")

    content_tag(:div, **options.merge(class: base_classes)) do
      parts = []

      if src.present?
        parts << image_tag(src, alt: alt, class: "w-full h-full rounded-full object-cover")
      elsif initials.present?
        parts << content_tag(:span, initials.upcase[0..1], class: "select-none")
      else
        parts << sketch_icon("user", size: size, color: "text-sketch-gray")
      end

      if status.present?
        status_size = size == :xs || size == :sm ? "w-2 h-2" : "w-3 h-3"
        parts << content_tag(:span, nil, class: [
          "absolute bottom-0 right-0",
          "rounded-full border-2 border-white",
          status_size,
          status_colors[status] || status_colors[:offline]
        ].join(" "))
      end

      safe_join(parts)
    end
  end

  private

  # Get CSS classes for variant
  def sketch_variant_classes(variant)
    {
      default: "bg-white",
      paper: "bg-sketch-paper",
      cream: "bg-sketch-cream",
      glass: "bg-white/70 backdrop-blur-md"
    }[variant] || "bg-white"
  end

  # Get roughness numeric value
  def sketch_roughness_value(roughness)
    {
      smooth: 0.5,
      normal: 1.5,
      rough: 2.5,
      sketchy: 3.5
    }[roughness] || 1.5
  end
end
