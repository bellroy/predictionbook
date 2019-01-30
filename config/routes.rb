PredictionBook::Application.routes.draw do
  # start with the root
  root to: 'predictions#home'

  # then devise, which is its own thing
  devise_for :users

  # then the other stuff having to do with users
  resources :users, only: %i[show update] do
    # nested resources come before member/collection routes
    resources :deadline_notifications
    member do
      get :settings
      get :statistics
      get :due_for_judgement
      post :generate_api_token
    end
  end

  # then everything else in alphabetical order
  resources :credence_games, only: %i[show destroy]
  resources :credence_game_responses, only: :update
  resources :deadline_notifications   # TODO: duplicated within users
  resource :feedback, controller: 'feedback'  # test fails if this line is changed (???)
  resources :group_member_invitations, only: :show

  resources :groups do
    resources :group_members, only: %i[index new create update destroy]
  end

  resources :prediction_groups, only: %i[show new create edit update]

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

  resources :response_notifications

  resources :responses do
    get :preview, on: :collection
  end

  # Due to rules around sitemap locations and allowed paths all sitemaps are at the root:
  resources :sitemaps, only: :index, path: "sitemap"
  get "/static-sitemap" => "sitemaps#static", as: :static_sitemap
  get "/predictions-sitemap:page" => "predictions#sitemap", as: :predictions_sitemap
  get '/happenstance' => 'predictions#happenstance', as: :happenstance
  get '/healthcheck' => 'content#healthcheck'

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  get '/predictions(/page/:page)' => 'predictions#index', page: 1
  get '/predictions/unjudged(/page/:page)' => 'predictions#unjudged', page: 1
  get '/predictions/judged(/page/:page)' => 'predictions#judged', page: 1
  get '/predictions/future(/page/:page)' => 'predictions#future', page: 1
  get '/users/:id(/page/:page)' => 'users#show', page: 1

  # Finally, the API routes
  namespace :api, format: :json do
    resources :current_users, only: :show
    resources :my_predictions, only: :index
    resources :predictions
    resources :prediction_group_by_description, only: :update
    resources :prediction_groups
    resources :prediction_judgements, only: :create
  end
end
