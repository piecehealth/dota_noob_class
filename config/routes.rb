Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Public routes
  get "leaderboards/history", to: "leaderboards#history", as: :history_leaderboards
  get "leaderboards/:week", to: "leaderboards#show", as: :weekly_leaderboard, constraints: { week: /\d{4}-\d{2}-\d{2}/ }

  resources :leaderboards, only: [ :index ]

  resources :matches, only: [ :index, :show ] do
    collection do
      get :mine
      patch :update_match_player
    end
  end

  resources :stats, only: [ :index ] do
    collection do
      get :daily
      get :top_performers
      get :stars
      get :weekly
      get :ranks
      get :compare
      get :students
    end
  end

  # Classroom and Group stats (member routes)
  get "classrooms/:id/stats", to: "stats#classroom", as: :classroom_stats
  get "groups/:id/stats", to: "stats#group", as: :group_stats

  # Simple session management
  resource :session, only: [ :new, :create, :destroy ]

  # User routes
  resources :users, only: [ :show ] do
    member do
      get :matches
    end
  end

  # Classroom routes
  resources :classrooms, only: [] do
    collection do
      get :mine
    end
  end

  # Test-only routes (development and test environments only)
  if Rails.env.test? || Rails.env.development?
    namespace :test do
      get "sign_in/:user_id", to: "sessions#sign_in", as: :sign_in
    end
  end

  # Admin only routes
  require "admin_constraint"

  mount ExceptionTrack::Engine => "/exceptions",
        as: :exceptions,
        constraints: AdminConstraint.new

  mount MissionControl::Jobs::Engine => "/jobs",
        as: :mission_control_jobs,
        constraints: AdminConstraint.new

  root "pages#home"
end
