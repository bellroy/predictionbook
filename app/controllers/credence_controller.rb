class CredenceController < ApplicationController
  def go
    @title = "Credence game"
    @question = CredenceQuestion.new
  end
end
