# frozen_string_literal: true

require 'spec_helper'

describe 'Sitemaps' do
  let(:user) { FactoryBot.create(:user) }

  before { FactoryBot.create_list(:prediction, 5, creator: user) }

  it 'Robot visits sitemap index successfully' do
    visit sitemaps_path(format: :xml)
    expect(page.status_code).to eq(200)
  end

  it 'Robot visits the static sitemap successfully' do
    visit static_sitemap_url(format: :xml)
    expect(page.status_code).to eq(200)
  end

  it 'Robot visits a prediction sitemap successfully' do
    visit predictions_sitemap_url(page: 1, format: :xml)
    expect(page.status_code).to eq(200)
  end
end
