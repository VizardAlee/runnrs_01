Rails.application.routes.draw do
  get 'replies/create'
  root 'home#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

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
      resources :negotiations, only: [:create]
    end

    resources :negotiations, only: [:index, :show] do
      member do
        patch :accept_offer  # New route for accepting the offer and setting the agreed price
      end
      resources :replies, only: [:create]
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

  resources :products, only: [:index]
  
  get 'checkout', to: 'checkouts#new', as: 'checkout'
  post 'checkout', to: 'checkouts#create'

  post 'flutterwave_callback', to: 'checkouts#flutterwave_callback', as: :flutterwave_callback
  get 'flutterwave_callback', to: 'checkouts#flutterwave_callback'
  get 'order_confirmation/:id', to: 'orders#confirmation', as: 'order_confirmation'

  resource :profile, only: [:show] 

  get "up" => "rails/health#show", as: :rails_health_check
  get 'search', to: 'products#search', as: 'search'
end
