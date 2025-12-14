# frozen_string_literal: true

Rails.application.routes.draw do
  # OAuth
  get "auth/:provider/callback", to: "oauth_callbacks#create"
  get "auth/failure", to: "oauth_callbacks#failure"

  # Sessions
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Dashboard (protected)
  get "dashboard", to: "dashboard#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"
end
