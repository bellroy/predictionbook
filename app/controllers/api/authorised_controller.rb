# frozen_string_literal: true

module Api
  class AuthorisedController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_by_api_token

    private

    def authenticate_by_api_token
      @user = User.find_by(api_token: params[:api_token])
      render json: invalid_api_message, status: :unauthorized unless valid_params_and_user?
    end

    def invalid_api_message
      { error: 'invalid API token', status: :unauthorized }
    end

    def valid_params_and_user?
      params[:api_token] && @user
    end
  end
end
