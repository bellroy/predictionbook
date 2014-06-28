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
    self.current_question.credence_game = self
    self.current_question.save
  end

  def answered_questions()
    self.credence_questions.select(&:answered_at)
  end

  def num_answered()
    # TODO: just make this a db column.
    self.answered_questions.length
  end

  def average_score()
    a = self.score.to_f / self.num_answered
    a.finite? ? a : 0
  end

  def most_recently_answered(n)
    self.answered_questions.sort_by(&:answered_at).reverse.take(n)
  end

  def recent_score(n)
    self.most_recently_answered(n).map(&:score).reduce(&:+)
  end

  def recent_average(n)
    a = self.recent_score(n).to_f / self.most_recently_answered(n).length
    a.finite? ? a : 0
  end
end
