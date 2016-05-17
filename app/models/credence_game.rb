class CredenceGame < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_response, class_name: 'CredenceGameResponse'
  has_many :credence_game_responses

  after_initialize :ensure_current_response

  def ensure_current_response
    if self.current_response.nil?
      self.new_question
    end
  end

  def new_question
    # Will we ever want to attach a question to a game without immediately
    # asking it? If so, we'll need to not set 'asked_at' here.
    self.current_response = CredenceGameResponse.pick_random
    self.current_response.asked_at = Time.now
    self.current_response.credence_game = self
    self.current_response.save
  end

  def answered_questions
    self.credence_game_responses.select(&:answered_at)
  end

  def average_score
    average = self.score.to_f / self.num_answered
    average.finite? ? average : 0
  end

  def most_recently_answered(n)
    self.credence_game_responses
      .limit(10)
      .order('answered_at desc')
      .select(&:answered_at)
  end

  def recent_score(n)
    self.most_recently_answered(n).map(&:score).reduce(&:+)
  end

  def recent_average(n)
    average = self.recent_score(n).to_f / self.most_recently_answered(n).length
    average.finite? ? average : 0
  end

  def calibration_graph
    CredenceStatistics.new(self.answered_questions)
  end
end
