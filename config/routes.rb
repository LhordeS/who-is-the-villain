Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :deeds, except: [:destroy]
  resources :messages, except: [:destroy]
  resources :chats, except: [:destroy]

end
