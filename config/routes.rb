Rails.application.routes.draw do
  resources :users, only: [:new, :create]
  resource :account, only: [:show, :edit, :update, :destroy] do
    resources :orders, only: [:index], module: :account
  end
  resources :products, only: [:index, :show]

  namespace :admin do
    resources :products, except: [:show]
    resources :orders, only: [:index, :show] do
      member do
        patch :complete
        patch :refund
      end
    end
    resources :users, only: [:index, :show, :destroy]
  end

  resource :cart, only: [:show]
  resources :cart_items, only: [:create, :update, :destroy]
  
  post "order_checkout", to: "order_checkouts#create", as: :order_checkout

  post "stripe/webhooks", to: "stripe_webhooks#create"

  resources :orders, only: [:show] do
    member do
      patch :request_refund
    end
  end

  get "order_lookup", to: "order_lookups#new", as: :order_lookup
  post "order_lookup", to: "order_lookups#create"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "sign_up", to: "users#new", as: :sign_up

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end
