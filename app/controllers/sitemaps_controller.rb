# frozen_string_literal: true

class SitemapsController < ApplicationController
  MAXIMUM_ENTRIES_IN_SITEMAP = 50_000

  # The sitemap lists out all the sitemap indexes:
  def index
    @total_prediction_sitemaps = Prediction
                                 .visible_to_everyone
                                 .page(1)
                                 .per(MAXIMUM_ENTRIES_IN_SITEMAP)
                                 .total_pages
  end

  # Static links go into this sitemap:
  def static
    @last_prediction_updated_at = Prediction.maximum(:updated_at)
  end
end
