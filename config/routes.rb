Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Mission Control
  mount MissionControl::Jobs::Engine, at: "/jobs"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "page#welcome"

  resources :works, only: [:new, :create] do
    collection do
      post :upload_ly
    end
  end

  scope module: "sqlite_dashboard" do
    get 'sqlite_dashboard', to: 'databases#index'
    # Saved queries
    get 'sqlite_dashboard/saved_queries', to: 'databases#saved_queries'
    post 'saved_queries', to: 'databases#create_saved_query'
    get 'saved_queries/:id', to: 'databases#show_saved_query', as: :saved_query
    delete 'saved_queries/:id', to: 'databases#destroy_saved_query'

    # SQL Worksheet
    get 'worksheet', to: 'databases#worksheet', as: :worksheet

    resources :databases, only: [:index, :show] do
      member do
        post :execute_query
        post :export_csv
        post :export_json
        get :tables
        get :table_schema
      end
    end
  end
end
