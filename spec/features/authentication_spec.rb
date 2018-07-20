require 'spec_helper'

feature 'authentication' do
  let!(:user) { FactoryBot.create(:user, name: 'Bob', login: 'login') }

  scenario 'user logs in and logs out again' do
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
