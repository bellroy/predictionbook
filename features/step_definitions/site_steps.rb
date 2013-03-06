Given /^I am logged in$/ do
  @user = create_valid_user(:login => 'buzzo', :password => 'testing')
  visit login_path
  fill_in "Login", :with => @user.login
  fill_in "Password", :with => @user.password
  click_button "Log in"
end

