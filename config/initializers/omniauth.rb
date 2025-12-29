# frozen_string_literal: true

require_relative "../../lib/omniauth/strategies/kakao"

OmniAuth.config.logger = Rails.logger

# Test mode configuration
OmniAuth.config.test_mode = Rails.env.test?

# Handle OAuth failures
OmniAuth.config.on_failure = proc do |env|
  OauthCallbacksController.action(:failure).call(env)
end

# Load credentials before block (block is lazily evaluated)
kakao_client_id = Rails.application.credentials.dig(:kakao, :client_id)
kakao_client_secret = Rails.application.credentials.dig(:kakao, :client_secret)

# Register OmniAuth providers
Rails.application.middleware.use OmniAuth::Builder do
  provider :kakao, kakao_client_id, kakao_client_secret
end
