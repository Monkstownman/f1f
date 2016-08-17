Rails.application.routes.draw do
  resources :user_thing_lookups
  resources :measures
  resources :things
 # root to: 'visitors#index'
  root to: 'user_thing_lookups#index'
  devise_for :users
  resources :users
end
