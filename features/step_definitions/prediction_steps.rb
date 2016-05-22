Given /^there is a prediction created by me$/ do
  @prediction = FactoryGirl.create(:prediction, creator: @user)
end

Given /^there is a new prediction$/ do
  @prediction = FactoryGirl.create(:prediction)
end

Given /^there is a closed prediction$/ do
  @prediction = FactoryGirl.create(:prediction)
  @prediction.judge!(:right, nil)
end
