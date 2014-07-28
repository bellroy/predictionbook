require 'spec_helper'

describe 'predictions/index.html.erb' do

  before do
    assign(:predictions, [])
    assign(:statistics, Statistics.new([]))
    view.stub(:show_statistics?).and_return(false)
    view.stub(:current_user).and_return User.new
  end

  it 'should render without errors' do
    render
    rendered.should_not be_blank
  end

  it 'should render predictions' do
    prediction = create_valid_prediction
    assign(:predictions, [prediction])

    render
    rendered.should have_selector("a[href='#{prediction_path(prediction)}']")
  end

end
