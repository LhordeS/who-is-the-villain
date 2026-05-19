Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
<<<<<<< HEAD
  resources :deeds, except: [:destroy] do
=======

  get 'dashboard', to: "pages#dashboard"
  get 'leaderboard', to: "pages#leaderboard"

  resources :deeds, except: [:destroy]
  resources :chats, except: [:destroy] do
>>>>>>> master
    resources :messages, only: [:create]
  end

end
