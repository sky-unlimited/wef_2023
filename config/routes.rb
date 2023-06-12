Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users
    get 'pages/console'
    get 'pilot_prefs/edit'
    get 'pilot_prefs/update'
    root to: 'pages#home'
  end
end
