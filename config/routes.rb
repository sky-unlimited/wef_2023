Rails.application.routes.draw do
  #get 'subscribers/index'
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users
    get 'pages/console'
    root to: 'pages#home'
  end

end
