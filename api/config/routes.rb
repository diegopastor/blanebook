Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    # Authentication
    post "auth/register", to: "auth#register"
    post "auth/login", to: "auth#login"
    delete "auth/logout", to: "auth#logout"
    get "auth/me", to: "auth#me"

    # Books
    resources :books, only: [ :index, :show, :create, :update, :destroy ]

    # Borrowings
    resources :borrowings, only: [ :index, :show, :create ] do
      member do
        patch :return, to: "borrowings#return_book"
      end
    end

    # Dashboard
    get "dashboard/librarian", to: "dashboard#librarian"
    get "dashboard/member", to: "dashboard#member"
  end
end
