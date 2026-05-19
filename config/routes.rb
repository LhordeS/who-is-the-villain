Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get 'dashboard', to: "pages#dashboard"
  get 'leaderboard', to: "pages#leaderboard"

  resources :deeds, except: [:destroy]
  resources :chats, except: [:destroy] do
    resources :messages, only: [:create]
  end

end
