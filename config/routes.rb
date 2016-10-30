PredictionBook::Application.routes.draw do

  concern :paginatable do
    get '(page/:page)', :action => :index, :on => :collection, :as => ''
  end

  resources :my_resources, :concerns => :paginatable

  get '/predictions(/page/:page)' => 'predictions#index', :as => :predictions, :page => 1
  get '/predictions/unjudged(/page/:page)' => 'predictions#unjudged', :as => :unjudged, :page => 1
  get '/predictions/judged(/page/:page)' => 'predictions#judged', :as => :judged, :page => 1
  get '/users/:id(/page/:page)' => 'users#show', :as => :users, :page => 1

  devise_for :users

  resources :users, only: [:show, :update] do
    get :settings, on: :member
    get :statistics, on: :member
    get :due_for_judgement, on: :member
    post :generate_api_token, on: :member
    resources :deadline_notifications
  end

  resources :deadline_notifications
  resources :response_notifications

  resource :feedback, controller: 'feedback'

  resources :responses do
    get :preview, on: :collection
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
      get :preview, on: :collection
    end
  end
  resources :credence_games, only: [:show, :destroy]
  resources :credence_game_responses, only: :update

  get '/happenstance' => 'predictions#happenstance', as: :happenstance

  root to: 'predictions#home'

  get '/healthcheck' => 'content#healthcheck'
  namespace :api do
    resources :predictions
  end
end
