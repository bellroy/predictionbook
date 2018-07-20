require 'spec_helper'

feature 'Sitemaps' do
  let(:user) { FactoryBot.create(:user) }
  before { FactoryBot.create_list(:prediction, 5, creator: user) }

  scenario 'Robot visits sitemap index successfully' do
    visit sitemaps_path(format: :xml)
    expect(page.status_code).to eq(200)
  end

  scenario 'Robot visits the static sitemap successfully' do
    visit static_sitemap_url(format: :xml)
    expect(page.status_code).to eq(200)
  end

  scenario 'Robot visits a prediction sitemap successfully' do
    visit predictions_sitemap_url(page: 1, format: :xml)
    expect(page.status_code).to eq(200)
  end
end
