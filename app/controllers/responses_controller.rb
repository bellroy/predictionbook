# frozen_string_literal: true

class ResponsesController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    @responses = Response.recent(limit: 50)
  end
end
