JourneyTracker::Application.routes.draw do

  root :to => 'main#index'
  resources :users
  resources :trips
  resources :photos
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'instagram/callback', to: 'trips#callback'
  match 'instagram/connect', to: 'trips#connect'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'
  match 'facebook/connect', to: 'sessions#fetch_photos'


end
