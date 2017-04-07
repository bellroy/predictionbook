require 'spec_helper'

describe 'predictions/new' do
  let(:prediction) { FactoryGirl.build(:prediction) }
  let(:user) { instance_double(User, has_email?: false, to_param: 'username') }

  before(:each) do
    assign(:prediction, prediction)
    assign(:statistics, Statistics.new)
    allow(view).to receive(:user_statistics_cache_key).and_return 'stats'
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'looks up the user cache key for the current user' do
    expect(view).to receive(:user_statistics_cache_key).with(user)
    render
  end

  it 'has a form that POSTs to the prediction collection' do
    render
    expect(rendered).to have_selector("form[method='post'][action='/predictions']")
  end

  it 'has a hidden field with the predictions UUID' do
    expect(prediction.uuid).not_to be_blank
    render
    expect(rendered).to include '<input type="hidden" ' \
      "value=\"#{prediction.uuid}\" name=\"prediction[uuid]\" id=\"prediction_uuid\" />"
  end

  it 'has an input field for prediction description' do
    render
    expect(rendered).to have_selector("textarea[name='prediction[description]']")
  end

  it 'has an input field for the initial confidence' do
    render
    expect(rendered).to have_selector("input[type='text'][name='prediction[initial_confidence]']")
  end

  describe '(check box for the notify creator)' do
    it 'is present and checked when user has an email' do
      expect(prediction).to receive(:notify_creator).and_return true
      render
      expect(rendered).to have_checked_field('prediction[notify_creator]')
    end

    it 'is unchecked if user does not have email' do
      expect(prediction).to receive(:notify_creator).and_return false
      render
      expect(rendered).to_not have_checked_field('prediction[notify_creator]')
    end
  end

  describe '(check box for private)' do
    it 'is present' do
      render
      expect(rendered).to have_field('prediction[private]')
    end

    it 'is checked when user private_default is true' do
      expect(prediction).to receive(:private).and_return true
      render
      expect(rendered).to have_checked_field('prediction[private]')
    end

    it 'is not checked when user private_default is false' do
      expect(prediction).to receive(:private).and_return false
      render
      expect(rendered).to_not have_checked_field('prediction[private]')
    end
  end

  it 'has an input field for the result' do
    render
    expect(rendered).to have_selector("input[type='text'][name='prediction[deadline_text]']")
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_css('input[type="submit"]')
  end
end
