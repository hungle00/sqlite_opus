Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "page#welcome"
  
  # Create sample database
  post "create_first_database", to: "page#create_first_database", as: :create_first_database

  resources :works, only: [:new, :create, :destroy] do
    collection do
      post :upload_db
    end
  end
  
  scope 'sqlite_opus', module: "sqlite_dashboard" do
    get 'dashboard', to: 'databases#index'
    get 'worksheet', to: 'databases#worksheet', as: :worksheet

    # Saved Queries
    resources :saved_queries, only: [:index, :show, :create, :destroy]

    # Databases
    resources :databases, only: [:index, :show] do
      member do
        post :execute_query
        post :export_csv
        post :export_json
        get :tables
        get :table_info
      end
    end
  end
end
