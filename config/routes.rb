Rails.application.routes.draw do
  root 'home#index'
  devise_for :users
  resources :stores do
    resources :products do
      member do
        patch :add_quantity
      end
    end
  end
  
  get 'test_pages/home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
