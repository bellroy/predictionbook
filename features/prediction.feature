Feature: Making a new prediction
  As a logged in user I want to make a prediction

Background:
  Given I am logged in
  And I am on the make new prediction page

Scenario: Making a new prediction
  When I fill in "What do you think will happen?" with "Desc"
  And I fill in "How sure are you?" with "55"
  And I fill in "When you will know?" with "tomorrow"
  And I press "Lock it in!"
  Then I should see "Desc"
  And I should see "known in 1 day"
  And I should see "estimated 55%"

Scenario: Editing a prediction
  Given there is a prediction created by me
  When I go to the edit prediction page
  And I fill in "What do you think will happen?" with "A new prediction"
  And I press "Save changes"
  Then I should be on the prediction page
  And I should see "A new prediction"
