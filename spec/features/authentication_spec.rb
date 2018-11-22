# frozen_string_literal: true

require 'spec_helper'

describe 'authentication' do
  let!(:user) { FactoryBot.create(:user, name: 'Bob', login: 'login') }

  it 'user logs in and logs out again' do
    visit root_path
    within 'ul#user-links' do
      click_link 'Login'
    end
    fill_in 'user_login', with: 'login'
    fill_in 'user_password', with: 'password'
    click_button 'Log in'
    expect(page).to have_content 'Your profile'
    within 'ul#user-links' do
      click_link 'Logout'
    end
    expect(page).to have_link 'Login'
  end
end
