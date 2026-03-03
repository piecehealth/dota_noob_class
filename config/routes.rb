Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource  :session,     only: [ :new, :create, :destroy ]
  resources :activations, only: [ :show, :update ], param: :token
  resource  :password,    only: [ :edit, :update ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :users, only: [] do
    get :matches, on: :member
  end

  resources :classrooms, only: [] do
    collection do
      get :mine
    end
  end

  resources :matches, only: [] do
    collection do
      get :mine
    end
  end

  root "pages#home"
end
