PredictionBook::Application.routes.draw do
  devise_for :users

  resources :users, only: [:show, :update] do
    get :settings, on: :member
    get :statistics, on: :member, format: :html
    get :due_for_judgement, on: :member
    post :generate_api_token, on: :member
    resources :deadline_notifications
  end

  resources :groups, format: :html do
    resources :group_members, format: :html, only: [:index, :new, :create, :update, :destroy]
  end
  resources :group_member_invitations, only: :show

  resources :deadline_notifications
  resources :response_notifications

  resource :feedback, controller: 'feedback'

  resources :responses do
    get :preview, on: :collection
  end

  resources :prediction_groups, only: [:show, :new, :create, :edit, :update]
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

  # Due to rules around sitemap locations and allowed paths all sitemaps are at the root:
  resources :sitemaps, only: [:index], path: "sitemap"
  get "/static-sitemap" => "sitemaps#static", as: :static_sitemap
  get "/predictions-sitemap:page" => "predictions#sitemap", as: :predictions_sitemap

  get '/happenstance' => 'predictions#happenstance', as: :happenstance

  root to: 'predictions#home'

  get '/healthcheck' => 'content#healthcheck'
  namespace :api, format: :json do
    resources :current_users, only: :show
    resources :my_predictions, only: :index
    resources :predictions
    resources :prediction_group_by_description, only: [:update]
    resources :prediction_groups
    resources :prediction_judgements, only: [:create]
  end

  concern :paginatable do
    get '(page/:page)', :action => :index, :on => :collection, :as => ''
  end

  get '/predictions(/page/:page)' => 'predictions#index', :page => 1
  get '/predictions/unjudged(/page/:page)' => 'predictions#unjudged', :page => 1
  get '/predictions/judged(/page/:page)' => 'predictions#judged', :page => 1
  get '/predictions/future(/page/:page)' => 'predictions#future', :page => 1
  get '/users/:id(/page/:page)' => 'users#show', :page => 1
end
