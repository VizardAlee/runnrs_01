Rails.application.routes.draw do
  root 'home#index'
  devise_for :users
  resources :stores do
    member do
      get 'new_logo', to: 'stores#new_logo'
      patch 'update_logo', to: 'stores#update_logo'
    end
    resources :products do
      resources :variations
      collection do
        get 'search'
      end
      member do
        patch :add_quantity
      end
    end
  end

  post 'shopping_carts/add_item', to: 'shopping_carts#add_item', as: 'shopping_carts_add_item'

  resource :shopping_cart, only: [:show] do
    resources :line_items, only: [:create, :destroy]
  end

  resources :line_items, only: [:create] 
  resources :orders
  resources :orders, only: [:index, :show, :update]
  get 'test_pages/home'

  resources :checkouts, only: [:new, :create] do
    collection do
      post :paystack_callback
    end
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'checkout', to: 'checkouts#new', as: 'checkout'
  post 'checkout', to: 'checkouts#create'

  post 'flutterwave_callback', to: 'checkouts#flutterwave_callback', as: :flutterwave_callback
  get 'flutterwave_callback', to: 'checkouts#flutterwave_callback'



  resource :profile, only: [:show] 

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'search', to: 'products#search', as: 'search'
  # Defines the root path route ("/")
  # root "posts#index"
end
