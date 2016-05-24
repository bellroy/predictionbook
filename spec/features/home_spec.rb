require 'spec_helper'

feature 'homepage' do
  scenario 'visiting the homepage' do
    visit root_path
    expect(current_path).to eq root_path
  end
end
