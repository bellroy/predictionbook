# frozen_string_literal: true

require 'csv'

class PredictionsController < ApplicationController
  before_action :authenticate_user!, only: %i[mine]
  before_action :find_prediction, only: %i[show]
  before_action :must_be_authorized_for_prediction, only: %i[show]
  before_action :ensure_statistics, only: [:index]

  def home
    visibility = current_user.try(:visibility_default) || 'visible_to_everyone'
    group_id = current_user.try(:group_default_id)
    @prediction = Prediction.new(creator: current_user, visibility: visibility, group_id: group_id)
    @responses = Response.recent(limit: 25)
      .includes(prediction: %i[prediction_group judgements], user: nil)
    @title = 'How sure are you?'
    @filter = 'popular'
    @predictions = Prediction.popular.limit(5)
    @show_statistics = false
  end

  def mine
    ps = PredictionsQuery.new(
      page: params[:page].to_i,
      page_size: params[:page_size].to_i,
      predictions: current_user.predictions.not_withdrawn,
      status: 'recent',
      tag_names: params.fetch(:tag_names, [])
    ).call
    serialized_predictions = ps.map { |p| PredictionSerializer.new(p).serializable_hash.except(:responses) }
    generated_csv = CSV.generate do |csv|
      written_column_headers = false
      serialized_predictions.each do |h|
        unless written_column_headers
          csv << h.keys
          written_column_headers = true
        end
        csv << h.values
      end
    end
    send_data(generated_csv, filename: 'my_predictions.csv')
  end

  def recent
    # TODO: remove this in a month or so
    redirect_to predictions_path, status: :moved_permanently
  end

  MAXIMUM_ENTRIES_IN_SITEMAP = 50_000

  def sitemap
    @page = params[:page]
    # Grabbing IDs & updated_at of all non-private predictions:
    @predictions = Prediction.order(created_at: :desc).visible_to_everyone.page(@page)
      .per(MAXIMUM_ENTRIES_IN_SITEMAP).pluck(:id, :updated_at)
  end

  def index
    @title = 'Recent Predictions'
    @filter = 'recent'
    @predictions = PredictionsQuery.new(
      page: params[:page].to_i,
      predictions: Prediction.visible_to_everyone,
      status: @filter,
      tag_names: params.fetch(:tag_names, [])
    ).call
    @show_statistics = true
  end

  def show
    if current_user.present?
      @prediction_response = Response.new(user: current_user)
    end

    @events = @prediction.events
    @title = @prediction.description_with_group
  end

  def judged
    @title = 'Judged Predictions'
    @filter = 'judged'
    @predictions = Prediction.visible_to_everyone.judged.page(params[:page])
    @show_statistics = true
    render action: 'index'
  end

  def unjudged
    @title = 'Unjudged Predictions'
    @filter = 'unjudged'
    @predictions = Prediction.visible_to_everyone.unjudged.page(params[:page])
    render action: 'index'
  end

  def future
    @title = 'Upcoming Predictions'
    @filter = 'future'
    @predictions = Prediction.visible_to_everyone.future.page(params[:page])
    render action: 'index'
  end

  def happenstance
    @title = 'Recent Happenstance'
    @unjudged = Prediction.visible_to_everyone.unjudged.limit(5)
    @judged = Prediction.visible_to_everyone.judged.limit(5)
    @recent = Prediction.visible_to_everyone.recent.limit(5)
    @responses = Response.recent(limit: 25).includes(prediction: :judgements, user: nil)
  end

  private

  def ensure_statistics
    @statistics ||= Statistics.new
  end

  def must_be_authorized_for_prediction
    authorized = (current_user || User.new).authorized_for?(@prediction, params[:action])
    showing_public_prediction = (params[:action] == 'show' && @prediction.visible_to_everyone?)
    notice = 'You are not authorized to perform that action'
    redirect_to(root_path, notice: notice) unless authorized || showing_public_prediction
  end

  def find_prediction
    @prediction = Prediction.find(params[:id])
  end
end
