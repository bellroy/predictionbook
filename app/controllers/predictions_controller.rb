class PredictionsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :judge, :withdraw, :edit, :update]
  before_filter :find_prediction, :only => [:judge, :show, :withdraw, :edit, :update]
  before_filter :must_be_authorized_for_prediction, :only => [:withdraw, :edit, :update]
  
  helper_method :statistics, :show_statistics?
  
  cache_sweeper :statistics_sweeper, :only => :judge
  
  def new
    @title = "Make a Prediction"
    @statistics = current_user.statistics if current_user
    @prediction = Prediction.new(:creator => current_user)
  end
  
  def create
    begin
      @prediction = Prediction.create!(params[:prediction].merge(:creator => current_user))
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
    @prediction = Prediction.new(:creator => current_user)
    @responses = Response.recent.limit(25)
    @title = "How sure are you?"
    @filter = 'popular'
    @predictions = Prediction.popular.limit(5)
    @show_statistics = false
  end
  
  def recent
    #TODO: remove this in a month or so
    redirect_to predictions_path, :status=>:moved_permanently
  end
  
  def index
    @title = "Recent Predictions"
    @filter = 'recent'
    @predictions = Prediction.recent.limit(100)
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
    @predictions = Prediction.judged
    @show_statistics = true
    render :action => 'index'
  end

  def unjudged
    @title = "Unjudged Predictions"
    @filter = 'unjudged'
    @predictions = Prediction.unjudged
    render :action => 'index'
  end
  
  def future
    @title = "Upcoming Predictions"
    @filter = 'future'
    @predictions = Prediction.future
    render :action => 'index'
  end

  def happenstance
    @title = "Recent Happenstance"
    @unjudged = Prediction.unjudged.limit(5)
    @judged = Prediction.judged.limit(5)
    @recent = Prediction.recent.limit(5)
    @responses = Response.recent.limit(25)
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
    @statistics ||= Response.wagers.statistics
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
