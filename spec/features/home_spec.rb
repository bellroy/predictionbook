# frozen_string_literal: true

require 'spec_helper'

describe 'homepage' do
  it 'visiting the homepage' do
    visit root_path
    expect(current_path).to eq root_path
  end
end
