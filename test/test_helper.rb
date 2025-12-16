# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# OmniAuth test mode
OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in(user)
      post login_url, params: { user_id: user.id }
    end

    def sign_out
      delete logout_url
    end

    # Default headers for API requests
    def api_headers
      { "Origin" => "capacitor://localhost" }
    end
  end
end
