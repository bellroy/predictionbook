# encoding: utf-8

class PredictionsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :judge, :withdraw, :edit, :update]
  before_filter :find_prediction, :only => [:judge, :show, :withdraw, :edit, :update]
  before_filter :must_be_authorized_for_prediction, :only => [:withdraw, :edit, :update]

  helper_method :statistics, :show_statistics?

  cache_sweeper :statistics_sweeper, :only => :judge

  def new
    @title = "Make a Prediction"
    @statistics = current_user.statistics if current_user
    privacy = false
    if current_user
      privacy = current_user.private_default
    end
    @prediction = Prediction.new(:creator => current_user, :private => privacy)
  end

  def create
    begin
      prediction_params = params[:prediction]
      prediction_params[:private] = current_user.private_default if !prediction_params.has_key?(:private)
      @prediction = Prediction.create!(prediction_params.merge(:creator => current_user))
    rescue Prediction::DuplicateRecord => duplicate
      @prediction = duplicate.record
    end
    redirect_to prediction_path(@prediction)
  rescue ActiveRecord::RecordInvalid => invalid
    @prediction = invalid.record
    render :action => 'new', :status => :unprocessable_entity
  end

  def edit
    @title = "Editing: “#{@prediction.description}”"
  end

  def update
    @prediction.update_attributes!(params[:prediction])
    redirect_to prediction_path(@prediction)
  rescue ActiveRecord::RecordInvalid => invalid
    @prediction = invalid.record
    render :action => 'edit', :status => :unprocessable_entity
  end

  def home
    privacy = false
    if current_user
      privacy = current_user.private_default
    end
    @prediction = Prediction.new(:creator => current_user, :private => privacy)
    @responses = Response.limit(25).recent
    @title = "How sure are you?"
    @filter = 'popular'
    @predictions = Prediction.limit(5).popular
    @show_statistics = false
  end

  def recent
    #TODO: remove this in a month or so
    redirect_to predictions_path, :status=>:moved_permanently
  end

  def index
    @title = "Recent Predictions"
    @filter = 'recent'
    @predictions = Prediction.limit(100).recent
    @show_statistics = true
  end

  def show
    if @prediction.private?
      access_forbidden and return unless current_user && current_user.authorized_for(@prediction)
    end
    if logged_in?
      @prediction_response = Response.new(:user => current_user)
      @deadline_notification = @prediction.deadline_notification_for_user(current_user)
      @response_notification = @prediction.response_notification_for_user(current_user)
      @response_notification.viewed!
    end
    @events = @prediction.events
    @title = @prediction.description
  end

  def judged
    @title = "Judged Predictions"
    @filter = 'judged'
    @predictions = Prediction.limit(100).judged
    @show_statistics = true
    render :action => 'index'
  end

  def unjudged
    @title = "Unjudged Predictions"
    @filter = 'unjudged'
    @predictions = Prediction.limit(100).unjudged
    render :action => 'index'
  end

  def future
    @title = "Upcoming Predictions"
    @filter = 'future'
    @predictions = Prediction.limit(100).future
    render :action => 'index'
  end

  def happenstance
    @title = "Recent Happenstance"
    @unjudged = Prediction.limit(5).unjudged
    @judged = Prediction.limit(5).judged
    @recent = Prediction.limit(5).recent
    @responses = Response.limit(25).recent
  end

  def judge
    @prediction.judge!(params[:outcome], current_user)
    flash[:judged] = 'judged'
    redirect_to @prediction
  end

  def withdraw
    @prediction.withdraw!
    redirect_to @prediction
  end

  def statistics
    @statistics ||= Statistics.new
  end

  def show_statistics?
    @show_statistics
  end


private
  def must_be_authorized_for_prediction
    access_forbidden unless current_user && current_user.authorized_for(@prediction)
  end

  def find_prediction
    @prediction = Prediction.find(params[:id])
  end
end
