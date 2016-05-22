PredictionBook2::Application.routes.draw do
  devise_for :users

  resources :users, only: :show do
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

  get '/happenstance' => 'predictions#happenstance', as: :happenstance

  root to: 'predictions#home'

  get '/healthcheck' => 'content#healthcheck'

  namespace :api do
    resources :predictions
  end
end
