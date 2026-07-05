Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token

  resources :boards do
    member { get :roadmap }
    resources :posts, only: %i[ new create ], shallow: true
  end

  resources :posts, only: %i[ show edit update destroy ] do
    resource :vote, only: %i[ create destroy ]
    member { patch :status }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "boards#index"
end
