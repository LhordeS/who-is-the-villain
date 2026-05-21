Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get 'dashboard', to: "pages#dashboard"
  get 'leaderboard', to: "pages#leaderboard"

  resources :deeds, except: [:destroy] do
    member do
      post 'upvote'
      post 'downvote'
      post 'flag'
    end
    resources :messages, only: [:create]
  end

end
