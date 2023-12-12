Rails.application.routes.draw do
  get 'fuel_stations/index'
  namespace :api do
    namespace :v1 do
      get "/airports/find", to: "airports#find"
    end
  end

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users
    get 'console/index'
    get 'subscribers/index'
    get 'privacy_policy/index'
    post '/', to: 'subscribers#create'
    get 'subscribers/unsubscribe/:unsubscribe_hash', to: 'subscribers#unsubscribe', as: 'unsubscribe'
    resources :pilot_prefs,       only: [ :edit, :update ]
    resources :trip_requests,     only: [ :new, :create, :edit, :update ]
    resources :trip_suggestions,  only: [ :index ]
    resources :airports,          only: [ :index, :show ]
    resources :fuel_stations,     only: [ :index, :new, :create, :edit, :update ]
    root to: 'pages#home'
  end
end
