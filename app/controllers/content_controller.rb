class ContentController < ApplicationController

  # test the DB and return 200 if successful
  def healthcheck
    Prediction.count
    render :nothing => true, :status => 200
  end
end

