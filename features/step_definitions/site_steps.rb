Given /^I am logged in$/ do
  @user = FactoryGirl.create(:user, login: 'buzzo')
  visit new_user_session_path
  fill_in 'Login', with: @user.login
  fill_in 'Password', with: @user.password
  click_button 'Log in'
end
