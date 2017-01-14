require "spec_helper"

feature "Robot visits sitemap and is given list of predictions" do
  scenario "successfully" do
    visit sitemap_path(format: :xml)
    expect(page.status_code).to eq(200)
  end
end
