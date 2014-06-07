class CredenceGame < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_question, class_name: 'CredenceQuestion'

  after_initialize :ensure_current_question
  def ensure_current_question()
    if self.current_question.nil?
      self.new_question
    end
  end

  def new_question()
    self.current_question = CredenceQuestion.pick_random
  end
end
