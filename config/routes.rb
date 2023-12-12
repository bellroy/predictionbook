Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    # start with the root
  root to: 'predictions#home'

  # then devise, which is its own thing
  devise_for :users

  # then the other stuff having to do with users
  resources :users, only: %i[show] do
    member do
      get :settings
      get :statistics
      get :due_for_judgement
    end
  end

  # then everything else in alphabetical order
  resource :feedback, controller: 'feedback'  # test fails if this line is changed (???)

  resources :groups, only: %i[index show] do
    resources :group_members, only: %i[index]
  end

  resources :prediction_groups, only: %i[show]

  resources :predictions, only: %i[index show] do
    collection do
      get :mine, format: :csv
      get :recent
      get :unjudged
      get :judged
      get :future
    end

    resources :responses, only: %i[index]
  end

  resources :responses, only: %i[index]

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
    resources :predictions, only: %i[index show]
    resources :prediction_groups, only: %i[index show]
  end
end
