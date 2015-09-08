PredictionBook2::Application.routes.draw do

  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login

  resource :session

  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup

  resources :users do
    get :settings, :on=> :member
    get :due_for_judgement, :on => :member
    post :generate_api_token, :on => :member
    resources :deadline_notifications
  end

  resources :passwords, :only => [:new, :create]

  resources :deadline_notifications
  resources :response_notifications

  resource :feedback, :controller=> 'feedback'

  resources :responses do
    get :preview, :on=> :collection
  end

  resources :predictions do
    collection do
      get :recent
      get :unjudged
      get :judged
      get :future
    end
    member do
      post :withdraw
      post :judge
    end

    resources :responses do
      get :preview, :on=> :collection
    end
  end

  match '/happenstance' => 'predictions#happenstance', :as=> :happenstance

  resource :credence,
    :controller => 'credence',
    :only => [:show, :update, :destroy]

  root :to => 'predictions#home'

  match '/healthcheck' => 'content#healthcheck'
  
  namespace :api do
    resources :predictions
  end
end

