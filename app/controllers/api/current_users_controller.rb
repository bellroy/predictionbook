module Api
  class CurrentUsersController < AuthorisedController
    def show
      render json: @user
    end
  end
end
