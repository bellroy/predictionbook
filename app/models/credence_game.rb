class CredenceGame < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_question, class_name: 'CredenceQuestion'

  def initialize()
    super
    new_question
  end

  def new_question()
    self.current_question = CredenceQuestion.pick_random
  end
end
