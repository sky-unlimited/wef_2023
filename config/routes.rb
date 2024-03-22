Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "/airports/find", to: "airports#find"
    end
  end

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users
    resources :users, only: [] do
      resources :followers,         only: [ :create ]
    end
    resources :followers,           only: [ :destroy ]
    get 'console/index'
    get 'subscribers/index'
    get 'legal/privacy'
    get 'legal/terms_and_conditions'
    post '/', to: 'subscribers#create'
    get 'subscribers/unsubscribe/:unsubscribe_hash', to: 'subscribers#unsubscribe', as: 'unsubscribe'
    resources :pilots,            only: [ :show, :edit, :update ]
    resources :preferences,       only: [ :edit, :update ]
    # resources :pilot_prefs,       only: [ :edit, :update ] # TODO: Remove after checking if it's not used
    resources :trip_requests,     only: [ :new, :create, :edit, :update ]
    resources :trip_suggestions,  only: [ :index ]
    resources :airports,          only: [ :index, :show ]
    resources :fuel_stations,     only: [ :index, :new, :show, :edit, :update, :create ]
    resources :contacts,          only: [ :index, :new, :create ]
    resources :events,            only: [ :index, :new, :create, :edit, :update, :destroy ]
    root to: 'pages#home'
  end

  resources :blogs
end
