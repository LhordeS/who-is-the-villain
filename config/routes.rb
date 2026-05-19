Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :deeds, except: [:destroy] do
    resources :messages, only: [:create]
  end

end
