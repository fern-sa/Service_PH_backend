Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get 'profile', to: 'users/registrations#show'
    get 'users/index', to: 'users/registrations#index'
  end

  resources :messages, only: [:create]

  # API routes for Core Business Functionality
  namespace :api do
    namespace :v1 do
      resources :categories, only: [:index, :show]
      resources :tasks do
        member do
          patch :start_work
          patch :mark_complete
        end
        
        resources :offers, except: [:update, :destroy] do
          member do
            patch :accept
            patch :reject
          end
        end
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
