# frozen_string_literal: true

require 'spec_helper'

describe 'response listing' do
  let(:page_header) { find('h2') }
  let(:page_content) { page.body }

  it 'user views the response listing' do
    visit responses_path
    expect(page_header.text).to eq 'Recent Responses'
  end

  it 'user views the response listing in XML' do
    visit responses_path(:xml)
    expect(page_content).to include 'Recent Responses'
  end
end
