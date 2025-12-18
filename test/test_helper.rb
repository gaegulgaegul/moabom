# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Load support files
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

# OmniAuth test mode
OmniAuth.config.test_mode = true

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Attach test images to photo fixtures after loading
    setup do
      attach_images_to_photo_fixtures if defined?(Photo)
    end

    # Add more helper methods to be used by all tests here...

    private

    def attach_images_to_photo_fixtures
      Photo.find_each do |photo|
        next if photo.image.attached?

        photo.image.attach(
          io: File.open(Rails.root.join("test/fixtures/files/photo.jpg")),
          filename: "photo.jpg",
          content_type: "image/jpeg"
        )
      end
    end
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
