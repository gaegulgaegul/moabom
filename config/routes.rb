# frozen_string_literal: true

Rails.application.routes.draw do
  # OAuth
  get "auth/:provider/callback", to: "oauth_callbacks#create"
  get "auth/failure", to: "oauth_callbacks#failure"

  # Sessions
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  post "dev_login", to: "sessions#dev_login" if Rails.env.development?

  # Dashboard (protected)
  get "dashboard", to: "dashboard#index"

  # Families
  resources :families, only: [ :show, :update ] do
    resources :members, controller: "families/members", only: [ :index, :update, :destroy ]
    resources :children, controller: "families/children"
    resources :photos, controller: "families/photos" do
      collection do
        post :batch
      end
      resources :reactions, controller: "photos/reactions", only: [ :create, :destroy ]
      resources :comments, controller: "photos/comments", only: [ :index, :create, :destroy ]
    end
  end

  # Onboarding
  namespace :onboarding do
    resource :profile, only: [ :show, :update ]
    resource :child, only: [ :show, :create ]
    resource :invite, only: [ :show ]
  end

  # Settings (Phase 7)
  namespace :settings do
    resource :profile, only: [ :show, :update ]
    resource :notifications, only: [ :show, :update ]
  end

  # Native API (Phase 8)
  namespace :api do
    namespace :native do
      resource :sync, only: [ :show ]
      resources :push_tokens, only: [ :create, :destroy ]
    end
  end

  # Invitation (short URL)
  get "i/:token", to: "invitations#show", as: :accept_invitation
  post "i/:token", to: "invitations#accept"

  # Notifications
  resources :notifications, only: [ :index, :update ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Root
  root "home#index"

  # Catch-all for 404 (must be last)
  match "*path", to: "errors#not_found", via: :all
end
