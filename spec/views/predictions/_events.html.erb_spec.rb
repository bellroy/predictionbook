require 'spec_helper'

describe 'Prediction responses partial' do
  
  def render_partial
    render :partial => 'predictions/events', :locals => { :events => @events }
  end
  
  before(:each) do
    @wager = mock_model(Response, :null_object => true, :created_at => Time.now)
    @events = [@wager]
  end
  it 'should list the responses' do
    @events = [@wager,@wager]
    render_partial
    response.should have_tag('li', 2)
  end
  it 'should show the responses confidence' do
    @wager.stub!(:confidence).and_return(30)
    render_partial
    response.should have_text(/30%/)
  end
  it 'should not show nil relative_confidences' do
    @wager.should_not_receive(:relative_confidence)
    @wager.stub!(:confidence).and_return(nil)
    render_partial
  end
  it 'should show who made the response' do
    @wager.stub!(:user).and_return(User.new(:name => 'Person', :login => "login.name"))
    render_partial
    response.should have_tag('[class=user]', 'Person')
  end      
  it 'should show when they made the response' do
    @wager.stub!(:created_at).and_return(3.days.ago)
    render_partial
    response.should have_tag('span', '3 days ago')
  end
  describe 'should include any supplied comments' do
    before(:each) do
      @wager.stub!(:comment).and_return(@comment = mock('comment'))
      @wager.stub!(:action_comment?).and_return(false)
    end
    it 'should show use the markup helper to render any supplied comment' do
      template.should_receive(:markup).with(@comment)
      render_partial
    end
    it 'should include the markup in the response' do
      template.stub!(:markup).and_return('<comment>markup response</comment>')
      render_partial
      response.body.should have_tag('comment', 'markup response')
    end
  end
end
