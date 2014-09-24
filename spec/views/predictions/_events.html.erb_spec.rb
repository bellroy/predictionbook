require 'spec_helper'

describe 'Prediction responses partial' do

  def render_partial
    render :partial => 'predictions/events', :locals => { :events => @events }
  end

  before(:each) do
    user = mock_model(User).as_null_object
    @wager = mock_model(Response, :created_at => Time.now, :user => user).as_null_object
    @events = [@wager]
  end
  it 'should list the responses' do
    @events = [@wager,@wager]
    render_partial
    rendered.should have_selector('li', :count=> 2)
  end
  it 'should show the responses confidence' do
    @wager.stub(:confidence).and_return(30)
    render_partial
    rendered.should =~ /30%/
  end
  it 'should not show nil relative_confidences' do
    @wager.should_not_receive(:relative_confidence)
    @wager.stub(:confidence).and_return(nil)
    render_partial
  end
  it 'should show who made the response' do
    @wager.stub(:user).and_return(User.new(:name => 'Person', :login => "login.name"))
    render_partial
    rendered.should have_css('.user', :text=> 'Person')
  end
  it 'should show when they made the response' do
    @wager.stub(:created_at).and_return(3.days.ago)
    render_partial
    rendered.should have_css('span', :text=> '3 days ago')
  end
  describe 'should include any supplied comments' do
    before(:each) do
      @wager.stub(:comment?).and_return(true)
      @wager.stub(:comment).and_return(@comment = double('comment'))
      @wager.stub(:action_comment?).and_return(false)
    end
    it 'should use the markup helper to render any supplied comment' do
      view.should_receive(:markup).with(@comment).and_return("comment")
      render_partial
    end
    it 'should include the markup in the response' do
      view.stub(:markup).and_return('<comment>markup response</comment>')
      render_partial
      rendered.should have_css('.comment', :text=> 'markup response')
    end
  end
end
