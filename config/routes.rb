Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource  :session,     only: [ :new, :create, :destroy ]
  resources :activations, only: [ :show, :update ], param: :token
  resource  :password,    only: [ :edit, :update ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Public routes - no authentication required
  resources :matches, only: [:index, :show] do
    collection do
      get :mine
      patch :update_match_player
    end
  end
  resources :stats, only: [:index] do
    collection do
      get :daily
      get :top_performers
      get :stars
      get :weekly
      get :ranks
      get :compare
    end
  end
  
  get "classrooms/:id/stats" => "stats#classroom", as: :classroom_stats
  get "groups/:id/stats" => "stats#group", as: :group_stats

  # Authentication required routes
  resources :users, only: [] do
    get :matches,           on: :member
    get :coaching_requests, on: :member
  end

  resources :classrooms, only: [] do
    collection do
      get :mine
    end
  end

  resources :coaching_requests, only: [ :index ] do
    collection do
      get :mine
    end
  end

  resources :matches, only: [] do
    collection do
      get :mine
    end
    scope module: "matches" do
      resource :coaching_request, only: [ :show, :create ] do
        patch :claim
        patch :complete
        patch :reopen
        delete :cancel
        resources :comments, only: [ :create ]
      end
    end
  end

  # Admin routes (protected by AdminConstraint)
  require "admin_constraint"
  
  mount ExceptionTrack::Engine => "/exceptions",
        as: :exceptions,
        constraints: AdminConstraint.new

  mount MissionControl::Jobs::Engine => "/jobs",
        as: :mission_control_jobs,
        constraints: AdminConstraint.new

  root "pages#home"
end
