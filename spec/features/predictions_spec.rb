require 'spec_helper'

feature 'creating and modifying predictions' do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  scenario 'making a new prediction' do
    visit new_prediction_path
    fill_in 'prediction_description', with: 'Desc'
    fill_in 'prediction_initial_confidence', with: '55'
    fill_in 'prediction_deadline_text', with: '1 day from now'
    click_button 'Lock it in!'

    expect(page).to have_content 'Desc'
    expect(page).to have_content 'known in 1 day'
    expect(page).to have_content 'estimated 55%'
  end

  scenario 'editing a prediction' do
    prediction = FactoryGirl.create(:prediction, creator: user)
    visit edit_prediction_path(prediction)

    fill_in 'prediction_description', with: 'A new prediction'
    click_button 'Save changes'

    expect(current_path).to eq prediction_path(prediction)
    expect(page).to have_content 'A new prediction'
  end
end
