# frozen_string_literal: true

class ContentController < ApplicationController
  # test the DB and return 200 if successful
  def healthcheck
    Prediction.count
    head :ok
  end
end
