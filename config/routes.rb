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

  # Onboarding
  namespace :onboarding do
    resource :profile, only: [ :show, :update ]
    resource :child, only: [ :show, :create ]
    resource :invite, only: [ :show ]
  end

  # Invitation (short URL)
  get "i/:token", to: "invitations#show", as: :accept_invitation

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"
end
