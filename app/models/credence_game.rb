class CredenceGame < ActiveRecord::Base
  def initialize()
    super
    new_question
  end

  def new_question()
    @current_question = CredenceQuestion.new
  end

  attr_reader :current_question
end
