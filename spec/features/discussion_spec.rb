# frozen_string_literal: true

require 'spec_helper'

describe 'discussing predictions' do
  let(:user) { FactoryBot.create(:user) }
  let(:prediction) { FactoryBot.create(:prediction) }

  before { login_as user }

  it 'I want to be able to comment on closed predictions' do
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

  it 'Empty comment on submission on closed predictions' do
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

  it 'Posting a comment on a new prediciton' do
    visit prediction_path(prediction)
    fill_in 'response_comment', with: 'Test comment'
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'Test comment'
  end

  it 'Posting confidence on a new prediction' do
    visit prediction_path(prediction)
    fill_in 'response_confidence', with: '45'
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'estimated 45%'
  end

  it 'Empty comment and confidence on submission on a new prediction' do
    visit prediction_path(prediction)
    click_button 'Record my prediction'
    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'You must enter an estimate or comment'
  end
end
