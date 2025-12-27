# frozen_string_literal: true

module Sketch
  # Frame0 Sketch-style Navigation Component
  #
  # @example Header navigation
  #   <%= render Sketch::NavComponent.new(variant: :header) do |nav| %>
  #     <% nav.with_brand(href: "/") do %>Logo<% end %>
  #     <% nav.with_item(href: "/photos", active: true) do %>Photos<% end %>
  #     <% nav.with_item(href: "/albums") do %>Albums<% end %>
  #   <% end %>
  #
  # @example Tab bar navigation
  #   <%= render Sketch::NavComponent.new(variant: :tabbar) do |nav| %>
  #     <% nav.with_tab(href: "/", icon: "home", label: "Home", active: true) %>
  #     <% nav.with_tab(href: "/photos", icon: "photo", label: "Photos") %>
  #     <% nav.with_tab(href: "/settings", icon: "cog-6-tooth", label: "Settings") %>
  #   <% end %>
  #
  class NavComponent < BaseComponent
    VARIANTS = {
      header: {
        container: "fixed top-0 inset-x-0 z-50 h-14",
        inner: "flex items-center justify-between px-4 h-full",
        bg: "bg-sketch-paper/90 backdrop-blur-md border-b-2 border-sketch-ink"
      },
      tabbar: {
        container: "fixed bottom-0 inset-x-0 z-50 safe-area-inset-bottom",
        inner: "flex items-center justify-around h-16",
        bg: "bg-sketch-paper/90 backdrop-blur-md border-t-2 border-sketch-ink"
      },
      sidebar: {
        container: "fixed left-0 top-0 bottom-0 z-40 w-64",
        inner: "flex flex-col h-full py-4",
        bg: "bg-sketch-paper border-r-2 border-sketch-ink"
      },
      inline: {
        container: "relative",
        inner: "flex items-center gap-4",
        bg: ""
      }
    }.freeze

    renders_one :brand, ->(href: "/", **options) do
      NavBrandComponent.new(href: href, **options)
    end

    renders_many :items, ->(href:, active: false, icon: nil, **options) do
      NavItemComponent.new(href: href, active: active, icon: icon, variant: @variant, **options)
    end

    renders_many :tabs, ->(href:, icon:, label:, active: false, badge: nil) do
      NavTabComponent.new(href: href, icon: icon, label: label, active: active, badge: badge)
    end

    renders_one :actions

    def initialize(variant: :header, **options)
      @variant = variant
      super(**options)
    end

    def nav_classes
      variant_config = VARIANTS.fetch(@variant, VARIANTS[:header])
      [
        base_classes,
        variant_config[:container],
        variant_config[:bg]
      ].compact.join(" ")
    end

    def inner_classes
      VARIANTS.fetch(@variant, VARIANTS[:header])[:inner]
    end

    def nav_data
      stimulus_data("nav")
    end

    def tabbar?
      @variant == :tabbar
    end

    def header?
      @variant == :header
    end

    def sidebar?
      @variant == :sidebar
    end
  end

  # Sub-component for navigation brand/logo
  class NavBrandComponent < ViewComponent::Base
    def initialize(href:, **options)
      @href = href
      @options = options
      super()
    end

    def call
      link_to @href, class: "flex items-center gap-2 font-sketch font-bold text-lg text-sketch-ink" do
        content
      end
    end
  end

  # Sub-component for navigation items
  class NavItemComponent < ViewComponent::Base
    def initialize(href:, active: false, icon: nil, variant: :header, **options)
      @href = href
      @active = active
      @icon = icon
      @variant = variant
      @options = options
      super()
    end

    def call
      link_to @href, class: item_classes, "aria-current": @active ? "page" : nil do
        safe_join([
          icon_element,
          content
        ].compact)
      end
    end

    private

    def item_classes
      base = "font-sketch text-sm transition-colors duration-200"
      active_styles = @active ? "text-sketch-ink font-semibold" : "text-sketch-gray hover:text-sketch-ink"
      "#{base} #{active_styles}"
    end

    def icon_element
      return nil unless @icon
      helpers.lucide_icon(@icon, class: "w-5 h-5 mr-1.5 inline")
    end
  end

  # Sub-component for tab bar items
  class NavTabComponent < ViewComponent::Base
    def initialize(href:, icon:, label:, active: false, badge: nil)
      @href = href
      @icon = icon
      @label = label
      @active = active
      @badge = badge
      super()
    end

    def call
      link_to @href, class: tab_classes, "aria-current": @active ? "page" : nil do
        safe_join([
          tag.span(class: "relative") do
            safe_join([
              helpers.lucide_icon(@icon, class: "w-6 h-6"),
              badge_element
            ].compact)
          end,
          tag.span(@label, class: "text-xs mt-1 font-sketch")
        ])
      end
    end

    private

    def tab_classes
      base = "flex flex-col items-center justify-center py-2 px-4 transition-colors duration-200"
      active_styles = @active ? "text-sketch-ink" : "text-sketch-gray hover:text-sketch-ink"
      "#{base} #{active_styles}"
    end

    def badge_element
      return nil unless @badge
      tag.span(@badge, class: "absolute -top-1 -right-1 w-4 h-4 bg-sketch-error text-white text-xs rounded-full flex items-center justify-center font-sketch")
    end
  end
end
