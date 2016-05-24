require 'spec_helper'

feature 'discussing predictions' do
  let(:user) { FactoryGirl.create(:user) }
  let(:prediction) { FactoryGirl.create(:prediction) }

  before { login_as user }

  scenario 'I want to be able to comment on closed predictions' do
    prediction.judge!(:right, nil)
    visit prediction_path(prediction)
    within("form[action='#{prediction_responses_path(prediction)}']") do
      expect(page).to have_selector "textarea[name='response[comment]']"
    end
    expect(page).not_to have_field 'prediction_initial_confidence'
    fill_in 'response_comment', with: 'Test comment'
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'Test comment'
  end

  scenario 'Empty comment on submission on closed predictions' do
    prediction.judge!(:right, nil)
    visit prediction_path(prediction)
    within("form[action='#{prediction_responses_path(prediction)}']") do
      expect(page).to have_selector "textarea[name='response[comment]']"
    end
    expect(page).not_to have_field 'prediction_initial_confidence'
    fill_in 'response_comment', with: ''
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'You must enter an estimate or comment'
  end

  scenario 'Posting a comment on a new prediciton' do
    visit prediction_path(prediction)
    fill_in 'response_comment', with: 'Test comment'
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'Test comment'
  end

  scenario 'Posting confidence on a new prediction' do
    visit prediction_path(prediction)
    fill_in 'response_confidence', with: '45'
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'estimated 45%'
  end

  scenario 'Empty comment and confidence on submission on a new prediction' do
    visit prediction_path(prediction)
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'You must enter an estimate or comment'
  end
end
