Rails.application.routes.draw do
  # Health check endpoint
  get "/health", to: "health#show"
  get "/up", to: "health#show"

  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"

  # GraphQL playground
  get "/graphiql", to: "graphql#playground"

  # Custom API authentication routes
  namespace :api do
    post "/auth/login", to: "sessions#create"
    post "/auth/refresh", to: "sessions#refresh"
    delete "/auth/logout", to: "sessions#destroy"
    post "/auth/register", to: "registrations#create"

    # Voice Bot — Twilio webhook (redirects to voice-agent service)
    scope :voice, controller: :voice_bot do
      post "/incoming", action: :incoming
      post "/status",   action: :status
    end

    # API v1 - Public REST API with API key authentication
    namespace :v1 do
      # API documentation
      get "/", to: "docs#index"
      get "/docs", to: "docs#index"

      # Courses
      resources :courses, only: [:index, :show]

      # Tee Times
      resources :tee_times, only: [:index, :show]

      # Bookings
      resources :bookings, only: [:index, :show, :create] do
        member do
          patch :cancel
          get :ics, defaults: { format: 'ics' }
        end
      end

      # Webhooks
      resources :webhooks, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :test
        end
      end

      # Voice call logs
      resources :voice_call_logs, only: [:index, :show, :create]

      # SMS status callback (Twilio webhook)
      post "/sms/status_callback", to: "sms#status_callback"
    end
  end

  # ActionCable WebSocket
  mount ActionCable.server => "/cable"

  # Catch all unmatched routes
  match "*path", to: proc { [404, { "Content-Type" => "application/json" }, ['{"error":"Not Found"}']] }, via: :all
end
