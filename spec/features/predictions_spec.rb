# frozen_string_literal: true

require 'spec_helper'

describe 'creating and modifying predictions' do
  let(:user) { FactoryBot.create(:user) }

  before { login_as user }

  it 'making a new prediction' do
    visit new_prediction_path
    fill_in 'prediction_description', with: 'Desc'
    fill_in 'prediction_initial_confidence', with: '55'
    fill_in 'prediction_deadline_text', with: '1 day from now'
    click_button 'Lock it in!'

    expect(page).to have_content 'Desc'
    expect(page).to have_content 'known in 1 day'
    expect(page).to have_content 'estimated 55%'
  end

  it 'editing a prediction' do
    prediction = FactoryBot.create(:prediction, creator: user)
    visit edit_prediction_path(prediction)

    fill_in 'prediction_description', with: 'A new prediction'
    click_button 'Save changes'

    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'A new prediction'
  end

  it 'when user has set a visibility default' do
    user.update(visibility_default: 'visible_to_creator')

    visit new_prediction_path
    fill_in 'prediction_description', with: 'Desc'
    fill_in 'prediction_initial_confidence', with: '55'
    fill_in 'prediction_deadline_text', with: '1 day from now'
    click_button 'Lock it in!'

    expect(page).to have_content 'This prediction is private'

    visit predictions_path

    expect(page).not_to have_content 'Desc'
    expect(page).not_to have_content 'known in 1 day'
    expect(page).not_to have_content 'estimated 55%'

    visit user_path(user)

    expect(page).to have_content 'Desc'
    expect(page).to have_content 'known in 1 day'
    expect(page).to have_content '55% confidence'
  end
end
