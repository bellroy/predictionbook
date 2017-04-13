PredictionBook::Application.routes.draw do
  devise_for :users

  resources :users, only: [:show, :update] do
    get :settings, on: :member
    get :statistics, on: :member, format: :html
    get :due_for_judgement, on: :member
    post :generate_api_token, on: :member
    resources :deadline_notifications
  end

  resources :groups, only: [:index, :show]

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
    resources :predictions, format: :json
    resources :prediction_judgements, only: [:create], format: :json
  end

  concern :paginatable do
    get '(page/:page)', :action => :index, :on => :collection, :as => ''
  end

  resources :my_resources, :concerns => :paginatable

  get '/predictions(/page/:page)' => 'predictions#index', :page => 1
  get '/predictions/unjudged(/page/:page)' => 'predictions#unjudged', :page => 1
  get '/predictions/judged(/page/:page)' => 'predictions#judged', :page => 1
  get '/predictions/future(/page/:page)' => 'predictions#future', :page => 1
  get '/users/:id(/page/:page)' => 'users#show', :page => 1
end
