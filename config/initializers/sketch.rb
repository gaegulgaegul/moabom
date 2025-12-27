# frozen_string_literal: true

# Frame0 Sketch Design System Initializer
# Loads sketch design tokens and configures the sketch environment
#
# Configuration is available via:
#   Rails.application.config.sketch_tokens

require "json"

Rails.application.config.sketch = ActiveSupport::OrderedOptions.new

# Load design tokens from JSON file
tokens_path = Rails.root.join("design-tokens.json")

if File.exist?(tokens_path)
  begin
    tokens_json = File.read(tokens_path)
    tokens = JSON.parse(tokens_json, symbolize_names: true)

    Rails.application.config.sketch_tokens = tokens.freeze

    # Extract commonly used values for easy access
    Rails.application.config.sketch.tap do |config|
      # Color palette
      config.colors = tokens.dig(:color) || {}

      # Stroke styles
      config.stroke = tokens.dig(:stroke) || {}

      # Typography
      config.typography = tokens.dig(:typography) || {}

      # Shadows
      config.shadows = tokens.dig(:shadow) || {}

      # Textures
      config.textures = tokens.dig(:texture) || {}

      # Components
      config.components = tokens.dig(:components) || {}

      # Default values
      config.defaults = {
        roughness: 1.5,
        bowing: 1,
        stroke_color: "#1A1A1A",
        stroke_width: 1.5,
        font_family: "'Caveat', 'Patrick Hand', 'Kalam', cursive"
      }.freeze
    end

    Rails.logger.info "[Sketch] Design tokens loaded successfully from design-tokens.json"
  rescue JSON::ParserError => e
    Rails.logger.error "[Sketch] Failed to parse design-tokens.json: #{e.message}"
    Rails.application.config.sketch_tokens = {}.freeze
  end
else
  Rails.logger.warn "[Sketch] design-tokens.json not found at #{tokens_path}"

  # Provide default configuration when tokens file is missing
  Rails.application.config.sketch_tokens = {}.freeze
  Rails.application.config.sketch.tap do |config|
    config.colors = {}
    config.stroke = {}
    config.typography = {}
    config.shadows = {}
    config.textures = {}
    config.components = {}
    config.defaults = {
      roughness: 1.5,
      bowing: 1,
      stroke_color: "#1A1A1A",
      stroke_width: 1.5,
      font_family: "'Caveat', 'Patrick Hand', 'Kalam', cursive"
    }.freeze
  end
end

# Helper module for accessing sketch configuration
module SketchConfig
  class << self
    def tokens
      Rails.application.config.sketch_tokens
    end

    def defaults
      Rails.application.config.sketch.defaults
    end

    def color(path)
      keys = path.to_s.split(".")
      keys.reduce(Rails.application.config.sketch.colors) { |h, k| h&.dig(k.to_sym) }
    end

    def stroke(key)
      Rails.application.config.sketch.stroke[key.to_sym]
    end

    def typography(key)
      Rails.application.config.sketch.typography[key.to_sym]
    end

    def shadow(key)
      Rails.application.config.sketch.shadows[key.to_sym]
    end

    def component(path)
      keys = path.to_s.split(".")
      keys.reduce(Rails.application.config.sketch.components) { |h, k| h&.dig(k.to_sym) }
    end

    # Get roughness value by name
    def roughness(level = :normal)
      case level.to_sym
      when :smooth then 0.5
      when :normal then 1.5
      when :rough then 2.5
      when :sketchy then 3.5
      else 1.5
      end
    end

    # Get random dash pattern
    def random_dash_pattern
      patterns = [
        "4, 3",
        "5, 2",
        "3, 4",
        "6, 2, 2, 2",
        "8, 3"
      ]
      patterns.sample
    end

    # Get random seed for Rough.js
    def random_seed
      rand(1..9999)
    end
  end
end

# Make SketchConfig available globally
Rails.application.config.to_prepare do
  # Include sketch helper in all views
  ActionView::Base.include SketchHelper if defined?(SketchHelper)
end
