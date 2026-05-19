Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
<<<<<<< HEAD
<<<<<<< HEAD
  resources :deeds, except: [:destroy] do
=======
=======
>>>>>>> 1457d7a254f8d2dfb233fe716039de594e757557

  get 'dashboard', to: "pages#dashboard"
  get 'leaderboard', to: "pages#leaderboard"

<<<<<<< HEAD
  resources :deeds, except: [:destroy]
  resources :chats, except: [:destroy] do
>>>>>>> master
=======
  resources :deeds, except: [:destroy] do
>>>>>>> 1457d7a254f8d2dfb233fe716039de594e757557
    resources :messages, only: [:create]
  end

end
