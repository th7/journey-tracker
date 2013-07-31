JourneyTracker::Application.routes.draw do

  root :to => 'main#index'
  resources :users
  resources :trips do
    resources :photos, only: [:create]
  end
  resources :photos
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'instagram/callback', to: 'trip_instagram_session#create'
  match 'instagram/connect', to: 'trip_instagram_session#new'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'
  match 'facebook/connect', to: 'trip_facebook_session#fetch_photos'
  match "/test" => "photos#test", :via => :post
  match "/test" => "photos#testview", :via => :get

end
