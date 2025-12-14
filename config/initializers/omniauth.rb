# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

# Test mode configuration
OmniAuth.config.test_mode = Rails.env.test?

# Handle OAuth failures
OmniAuth.config.on_failure = proc do |env|
  OauthCallbacksController.action(:failure).call(env)
end
