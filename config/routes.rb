Rails.application.routes.draw do
  resources :user_thing_lookups
  resources :measures
  resources :things
  # root to: 'visitors#index'
  root to: 'user_thing_lookups#index'
  devise_for :users
  resources :users

  scope '/api' do
    scope '/v1' do
      scope '/measures' do
        get '/' => 'api_measures#index'
        post '/' => 'api_measures#create'
        scope '/:name' do
          get '/' => 'api_measures#show'
          put '/' => 'api_measures#update'
        end
      end
    end
  end
end