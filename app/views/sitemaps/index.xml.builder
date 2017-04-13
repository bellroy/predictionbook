cache("sitemaps/index", expires_in: 12.hours) do

  xml.instruct!
  xml.sitemapindex("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") do

    xml.sitemap do |sitemap|
      sitemap.loc(static_sitemap_url(format: :xml))
    end

    1.upto(@total_prediction_sitemaps).each do |i|
      xml.sitemap do |sitemap|
        sitemap.loc(predictions_sitemap_url(page: i, format: :xml))
      end
    end

  end

end
