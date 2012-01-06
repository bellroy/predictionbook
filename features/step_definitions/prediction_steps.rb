Given /^there is a prediction created by me$/ do
  @prediction = create_valid_prediction(:creator => @user)
end

Given /^there is a closed prediction$/ do
  @prediction = create_valid_prediction
  @prediction.judge!(:right,nil)
end
