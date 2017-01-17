cache("sitemaps/predictions/#{@page}", expires_in: 12.hours) do

  xml.instruct!
  xml.urlset("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") do

    # Loop through IDs of predictions writing out URLs for each:
    @predictions.each do |prediction|
      xml.url do |sitemap_url|
        sitemap_url.loc(prediction_url(prediction[0]))
        sitemap_url.lastmod(w3c_date(prediction[1]))
      end
    end

  end

end
