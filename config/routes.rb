Rails.application.routes.draw do
  resources :status_setups
  require 'sidekiq/web'

  # authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  # end

  resources :refgos
  resources :orders  do
    collection do
      post :import_last_retail
    end
    member do
      post :update_retail
      post :create_refgo
      post :check_refgo
    end
  end
  resources :retails
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "orders#index"
end
