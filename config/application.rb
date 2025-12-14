# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Moabom
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # OmniAuth middleware
    require_relative "../lib/omniauth/strategies/kakao"

    config.middleware.use OmniAuth::Builder do
      kakao_client_id = Rails.application.credentials.dig(:kakao, :client_id) || "test_client_id"
      kakao_client_secret = Rails.application.credentials.dig(:kakao, :client_secret) || "test_client_secret"

      provider :kakao, kakao_client_id, kakao_client_secret
    end
  end
end
