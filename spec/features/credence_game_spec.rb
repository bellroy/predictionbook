require 'spec_helper'

feature 'credence game' do
  let(:user) { FactoryGirl.create(:user) }
  let!(:question) { FactoryGirl.create(:credence_question, text: 'Do you have a stupid face?') }
  let!(:answers) { FactoryGirl.create_list(:credence_answer, 2, credence_question: question) }

  before { login_as user }

  scenario 'user tries the credence game' do
    visit root_path
    within 'ul#nav-menu' do
      click_link 'Credence game'
    end
    expect(page).to have_content 'Do you have a stupid face?'
    within 'tr.answer0' do
      click_button '51%'
    end
    expect(page).to have_content 'answer is'
    expect(find('table#credence-scores').text).not_to be_empty
  end
end
