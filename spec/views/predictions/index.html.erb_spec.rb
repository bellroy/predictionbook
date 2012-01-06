require 'spec_helper'

describe 'An index of predictions' do
  
  before do
    assigns[:predictions] = []
    assigns[:statistics] = Statistics.new([])
    template.stub!(:show_statistics?).and_return(false)
    template.stub!(:current_user).and_return User.new
  end

  def render_view
    render 'predictions/index'
  end

  it 'should render without errors' do
    render_view
    response.should be_success
  end

  it 'should render predictions' do
    prediction = Prediction.new
    prediction.stub!(:to_param).and_return(437)
    prediction.save(false)
    prediction.stub!(:deadline).and_return(Time.now)
    prediction.stub!(:created_at).and_return(Time.now)
    prediction.stub!(:mean_confidence).and_return(10)
    assigns[:predictions] = [prediction]
    render_view
    response.should have_tag('a[href=?]', prediction_path(prediction))
  end
  
end
