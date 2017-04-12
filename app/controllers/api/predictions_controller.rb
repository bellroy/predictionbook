module Api
  class PredictionsController < AuthorisedController
    MAXIMUM_PREDICTIONS_LIMIT = 1000
    DEFAULT_PREDICTIONS_LIMIT = 100

    before_action :build_predictions, only: [:index]
    before_action :build_new_prediction, only: [:create]
    before_action :find_prediction, only: %i[show update]
    before_action :authorize_to_see_prediction, only: [:show]
    before_action :authorize_to_update_prediction, only: [:update]

    def create
      if @prediction.save
        render json: @prediction
      else
        render json: @prediction.errors, status: :unprocessable_entity
      end
    end

    def index
      render json: @predictions
    end

    def show
      render json: @prediction
    end

    def update
      if @prediction.update_attributes(prediction_params)
        render json: @prediction
      else
        render json: @prediction.errors, status: :unprocessable_entity
      end
    end

    private

    def authorize_to_see_prediction
      raise UnauthorizedRequest unless @prediction.visible_to_everyone? ||
                                       @user.authorized_for(@groups, @prediction)
    end

    def authorize_to_update_prediction
      raise UnauthorizedRequest unless @user.authorized_for(@groups, @prediction)
    end

    def build_new_prediction
      permitted_params = prediction_params
      if permitted_params[:visibility].nil? && @user.present?
        permitted_params[:visibility] = @user.visibility_default
      end

      @prediction = Prediction.new(prediction_params.merge(creator: @user))
    end

    def build_predictions
      limit = params[:limit].to_i
      limit = DEFAULT_PREDICTIONS_LIMIT unless (1..MAXIMUM_PREDICTIONS_LIMIT).cover?(limit)
      @predictions = Prediction.recent.limit(limit)
    end

    def find_prediction
      @prediction = Prediction.find(params[:id])
    end

    def prediction_params
      permitted_params = params.require(:prediction).permit!
      if permitted_params[:private].present?
        private_value = permitted_params.delete(:private)
        permitted_params[:visibility] = 'visible_to_creator' if private_value
      end
      permitted_params
    end
  end
end
