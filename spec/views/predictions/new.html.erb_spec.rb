require 'spec_helper'

describe 'A page to input a prediction' do
  before(:each) do
    errors = mock('errors', :on => nil)
    assigns[:prediction] = @prediction = mock_model(Prediction, :new_record? => true, :errors => errors, :null_object => true)
    template.stub!(:logged_in?).and_return(true)
    template.stub!(:user_statistics_cache_key).and_return "stats"
    template.stub!(:statistics).and_return(Statistics.new([])) 
    @user = mock_model(User, :has_email? => false)
    @user.stub!(:to_param).and_return "username"
    template.stub!(:current_user).and_return(@user)
  end
  
  def render_view
    render 'predictions/new'
  end
  
  it "should look up the user cache key for the current user" do
    template.should_receive(:user_statistics_cache_key).with(@user)
    render_view
  end
  
  it 'should cache a fragment for the statistics partial' do
    lambda {
      render_view
    }.should cache_fragment("views/stats")
  end
  
  it 'should have a form that POSTs to the prediction collection' do
    render_view
    response.should have_tag('form[method="post"][action="/predictions"]')
  end
  
  it 'should have a hidden field with the predictions UUID' do
    @prediction.stub!(:uuid).and_return('0d027d60-7b04-11dd-92d8-001f5b80f5b2')
    render_view
    response.should have_tag('input[type="hidden"][name=?][value=?]', 'prediction[uuid]','0d027d60-7b04-11dd-92d8-001f5b80f5b2')
  end
  
  it 'should have an input field for prediction description' do
    render_view
    response.should have_tag('textarea[name=?]', 'prediction[description]')
  end
  
  it 'should have an input field for the initial confidence' do
    render_view
    response.should have_tag('input[type="text"][name=?]', 'prediction[initial_confidence]')
  end

  describe '(check box for the notify creator)' do
    it 'should be present and checked when user has an email' do
      @prediction.stub!(:notify_creator).and_return true
      render_view
      response.should have_tag('input[type="checkbox"][name=?][checked=?]', 'prediction[notify_creator]', "checked")
    end
    it 'should be unchecked if user does not have email' do
      @prediction.stub!(:notify_creator).and_return false
      render_view
      response.should_not have_tag('input[type="checkbox"][name=?][checked=?]', 'prediction[notify_creator]', "checked")
    end
  end
  
  describe '(check box for private)' do
    it 'should be present' do
      render_view
      response.should have_tag('input[name=?]', 'prediction[private]')
    end
    it 'should be checked when user private_default is true' do
      @prediction.stub!(:private).and_return true
      render_view
      response.should have_tag('input[type="checkbox"][name=?][checked=?]', 'prediction[private]', "checked")
    end
    it 'should not be checked when user private_default is false' do
      @prediction.stub!(:private).and_return false
      render_view
      response.should_not have_tag('input[type="checkbox"][name=?][checked=?]', 'prediction[private]', "checked")
    end
  end
  
  it 'should have an input field for the result' do
    render_view
    response.should have_tag('input[type="text"][name=?]', 'prediction[deadline_text]')
  end
  
  it 'should have a submit button' do
    render_view
    response.should have_tag('input[type="submit"]')
  end
end
