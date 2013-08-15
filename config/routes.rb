JourneyTracker::Application.routes.draw do

  root :to => 'main#index'
  resources :trips do
    resources :photos, only: [:create, :update, :destroy]
  end

  match 'auth/:provider/callback', to: 'sessions#create', :via => :post
  match 'instagram/callback', to: 'trip_instagram_session#create'
  match 'instagram/connect', to: 'trip_instagram_session#new'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'
  match 'facebook/connect', to: 'trip_facebook_session#fetch_photos'
  match '/channel' => 'sessions#channel', :via => :get

end
