# encoding: utf-8

class PredictionGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_prediction_group, only: %i[show edit update]
  before_action :must_be_authorized_for_prediction, only: %i[edit update show]

  def show
    @events = @prediction_group.predictions.flat_map(&:events).sort_by(&:created_at)
    @title = @prediction_group.description
  end

  def new
    @title = 'Make a Prediction Group'
    @statistics = current_user.try(:statistics)
    visibility = current_user.try(:visibility_default) || 0
    group_id = current_user.try(:group_default_id)
    @prediction_group = PredictionGroup.new
    @prediction_group.predictions.new(creator: current_user, visibility: visibility,
                                      group_id: group_id)
  end

  def create
    @prediction_group = UpdatedPredictionGroup.new(PredictionGroup.new,
                                                   current_user,
                                                   prediction_group_params).prediction_group
    if @prediction_group.save
      redirect_to prediction_group_path(@prediction_group)
    else
      @prediction_group.predictions.new if @prediction_group.default_prediction.nil?
      render action: 'new', status: :unprocessable_entity
    end
  end

  def edit
    group_desc = @prediction_group.description
    @title = "Editing: “!#{group_desc}”"
  end

  def update
    prediction_group_params = params[:prediction_group].to_unsafe_h
    @prediction_group = UpdatedPredictionGroup.new(@prediction_group,
                                                   current_user,
                                                   prediction_group_params).prediction_group
    if @prediction_group.save
      redirect_to prediction_group_path(@prediction_group)
    else
      render action: 'edit', status: :unprocessable_entity
    end
  end

  private

  def must_be_authorized_for_prediction
    prediction = @prediction_group.predictions.first || Prediction.new
    action = params[:action]
    authorized = (current_user || User.new).authorized_for(@groups, prediction, action)
    showing_public_prediction = (action == 'show' && prediction.visible_to_everyone?)
    notice = 'You are not authorized to perform that action'
    redirect_to(root_path, notice: notice) unless authorized || showing_public_prediction
  end

  def find_prediction_group
    @prediction_group = PredictionGroup.includes(predictions: %i[responses versions judgements])
                                       .find(params[:id])
  end

  def prediction_group_params
    params.require(:prediction_group).permit!
  end
end
