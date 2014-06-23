class CredenceGame < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_question, class_name: 'CredenceQuestion'
  has_many :credence_questions

  after_initialize :ensure_current_question
  def ensure_current_question()
    if self.current_question.nil?
      self.new_question
    end
  end

  def new_question()
    # Will we ever want to attach a question to a game without immediately
    # asking it? If so, we'll need to not set 'asked_at' here.
    self.current_question = CredenceQuestion.pick_random
    self.current_question.asked_at = Time.now
    self.current_question.save
  end
end
