Then /^I should see the response form$/ do
  expect(page).to have_selector("form[action='#{prediction_responses_path(@prediction)}']") do |form|
    expect(form).to have_selector "textarea[name='response[comment]']"
  end
end

Then /^the form should not have a field for entering a confidence$/ do
  expect(page).not_to have_selector("form input[name='response[confidence]']")
end

Given /^I take note of the response count$/ do
  @response_count = @prediction.responses.count
end

When /^I submit a confidence$/ do
  post prediction_responses_path(@prediction), response: { confidence: '90' }
end

Then /^The response count should be unchanged$/ do
  expect(@prediction.responses.count).to eq @response_count
end
