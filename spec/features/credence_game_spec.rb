# frozen_string_literal: true

require 'spec_helper'

describe 'credence game' do
  let(:user) { FactoryBot.create(:user) }
  let!(:question) { FactoryBot.create(:credence_question, text: 'Do you have a stupid face?') }
  let!(:answers) { FactoryBot.create_list(:credence_answer, 2, credence_question: question) }

  before { login_as user }

  it 'user tries the credence game' do
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
