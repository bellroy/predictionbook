# frozen_string_literal: true

require 'spec_helper'

describe 'creating and modifying prediction groups', js: true do
  let(:user) { FactoryBot.create(:user) }

  before { login_as user }

  it 'making a new prediction group' do
    visit new_prediction_group_path
    fill_in 'prediction_group[description]', with: 'I will do a thing in'
    fill_in 'prediction_group[prediction_0_description]', with: 'Less than a day'
    fill_in 'prediction_group[prediction_0_initial_confidence]', with: '1'
    click_button 'Add another prediction'
    fill_in 'prediction_group[prediction_1_description]', with: 'Less than a week'
    fill_in 'prediction_group[prediction_1_initial_confidence]', with: '10'
    click_button 'Add another prediction'
    fill_in 'prediction_group[prediction_2_description]', with: 'Less than a month'
    fill_in 'prediction_group[prediction_2_initial_confidence]', with: '40'
    click_button 'Add another prediction'
    fill_in 'prediction_group[prediction_3_description]', with: 'Less than a year'
    fill_in 'prediction_group[prediction_3_initial_confidence]', with: '95'
    fill_in 'prediction_group[deadline_text]', with: '1 year from now'
    click_button 'Lock in your predictions!'

    expect(page).to have_content "known on #{1.year.from_now.strftime('%Y')}"

    expect(page).to have_content '[I will do a thing in] Less than a day'
    expect(page).to have_content '( 1% confidence )'
    expect(page).to have_content '[I will do a thing in] Less than a week'
    expect(page).to have_content '( 10% confidence )'
    expect(page).to have_content '[I will do a thing in] Less than a month'
    expect(page).to have_content '( 40% confidence )'
    expect(page).to have_content '[I will do a thing in] Less than a year'
    expect(page).to have_content '( 95% confidence )'
  end

  it 'editing a prediction' do
    prediction_group = FactoryBot.create(:prediction_group, creator: user, predictions: 5)
    visit edit_prediction_group_path(prediction_group)

    fill_in 'prediction_group_description', with: 'A new prediction'
    fill_in 'prediction_group[prediction_0_description]', with: 'Your calibration is going to suck'
    click_button 'Lock in your predictions!'

    expect(page).to have_content 'A new prediction'
    expect(page).to have_content 'Your calibration is going to suck'
    prediction_group.reload
    expect(prediction_group.predictions.length).to eq 5
    prediction_group.predictions.each do |prediction|
      expect(page).to have_content prediction.description_with_group
    end
    expect(current_path).to eq prediction_group_path(prediction_group)
  end

  it 'when user has set a visibility default' do
    user.update(visibility_default: 'visible_to_creator')

    visit new_prediction_group_path
    fill_in 'prediction_group_description', with: 'Tomorrow'
    fill_in 'prediction_group[prediction_0_description]', with: 'You will explode'
    fill_in 'prediction_group[prediction_0_initial_confidence]', with: '55'
    fill_in 'prediction_group_deadline_text', with: '1 day from now'
    click_button 'Lock in your predictions!'

    expect(page).to have_content '[private]'

    visit predictions_path

    expect(page).not_to have_content '[Tomorrow] You will explode'
    expect(page).not_to have_content 'known in 1 day'
    expect(page).not_to have_content 'estimated 55%'

    visit user_path(user)

    expect(page).to have_content '[Tomorrow] You will explode'
    expect(page).to have_content 'known in 1 day'
    expect(page).to have_content '55% confidence'
  end
end
