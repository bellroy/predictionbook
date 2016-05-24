require 'spec_helper'

describe 'predictions/index.html.erb' do
  before do
    assign(:predictions, [])
    assign(:statistics, Statistics.new)
    allow(view).to receive(:show_statistics?).and_return(false)
    allow(view).to receive(:current_user).and_return User.new
  end

  it 'renders without errors' do
    render
    expect(rendered).not_to be_blank
  end

  it 'renders predictions' do
    prediction = FactoryGirl.create(:prediction)
    assign(:predictions, [prediction])

    render
    expect(rendered).to have_selector("a[href='#{prediction_path(prediction)}']")
  end
end
