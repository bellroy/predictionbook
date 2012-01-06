Feature: Discussing Predictions
  As any user I want to be able to discuss predictions

Background:
  Given there is a closed prediction
  And I am logged in

Scenario: I want to be able to comment on closed predictions
  When I go to the prediction page
  Then I should see the response form
  And the form should not have a field for entering a confidence

Scenario: Posting a confidence on a closed prediction
  Given I am on the prediction page
  And I take note of the response count
  When I submit a confidence
  Then the response code should be 422
  And The response count should be unchanged
