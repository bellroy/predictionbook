Feature: Discussing Predictions
  As any user I want to be able to discuss predictions

Background:
  And I am logged in

Scenario: I want to be able to comment on closed predictions
  Given there is a closed prediction
  When I go to the prediction page
  Then I should see the response form
  And the form should not have a field for entering a confidence
  And I fill in "Anything to add?" with "Test comment"
  And I press "Record my prediction"
  Then I should be on the prediction page
  And I should see "Test comment"

Scenario: Empty comment on submission on closed predictions
  Given there is a closed prediction
  When I go to the prediction page
  Then I should see the response form
  And the form should not have a field for entering a confidence
  And I fill in "Anything to add?" with ""
  And I press "Record my prediction"
  Then I should be on the prediction page
  And I should see "You must enter an estimate or comment"

Scenario: Posting a confidence on a closed prediction
  Given there is a closed prediction
  And I am on the prediction page
  And I take note of the response count
  When I submit a confidence
  Then The response count should be unchanged

Scenario: Posting a comment on a new prediciton
  Given there is a new prediction
  And I am on the prediction page
  And I fill in "Anything to add?" with "Test comment"
  And I press "Record my prediction"
  Then I should be on the prediction page
  And I should see "Test comment"

Scenario: Posting confidence on a new prediction
  Given there is a new prediction
  And I am on the prediction page
  And I fill in "What's your estimate of this happening?" with "45"
  And I press "Record my prediction"
  Then I should be on the prediction page
  And I should see "estimated 45%"

Scenario: Empty comment and confidence on submission on a new prediction
  Given there is a new prediction
  When I am on the prediction page
  And I press "Record my prediction"
  Then I should be on the prediction page
  And I should see "You must enter an estimate or comment"
