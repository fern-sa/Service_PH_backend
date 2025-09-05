Rails.application.routes.draw do
  devise_for :users, path: 'api/v1', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'api/v1/users/sessions',
    registrations: 'api/v1/users/registrations',
    confirmations: 'api/v1/users/confirmations',
    passwords: 'api/v1/users/passwords'
  }

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
            patch :confirm_cash_payment
          end
          
          resources :payments, only: [:create] do
            collection do
              patch :confirm_cash
              post :stripe_intent
            end
          end
        end
      end
      resources :users, only: [:index] do
        collection do
          get "profile", to: "users#show"
        end
      end
      resources :messages, only: [:create] do
        collection do
          get :fetch_log
          get "user_log", to: "messages#fetch_all_logs_for_user"
          get "all_logs", to: "messages#fetch_all_logs_in_db"
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
