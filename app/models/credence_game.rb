class CredenceGame < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_response, class_name: CredenceGameResponse.name, autosave: true
  has_many :responses, class_name: CredenceGameResponse.name, dependent: :destroy

  after_create :ensure_current_response

  def responses_selected_by_users
    responses.answered
  end

  def average_score
    average = score.to_f / num_answered
    average.finite? ? average : 0
  end

  def most_recently_answered(limit)
    responses_selected_by_users.order('answered_at desc').limit(limit)
  end

  def recent_score(limit)
    most_recently_answered(limit).map(&:score).reduce(&:+)
  end

  def recent_average(limit)
    average = recent_score(limit).to_f / most_recently_answered(limit).length
    average.finite? ? average : 0
  end

  def calibration_graph
    CredenceStatistics.new(responses_selected_by_users)
  end

  def add_score(new_score)
    self.score = score + new_score
    self.num_answered = num_answered + 1
    create_new_response_to_random_question
  end

  private

  def ensure_current_response
    create_new_response_to_random_question if current_response.nil?
  end

  def create_new_response_to_random_question
    question = CredenceQuestion.where(enabled: true).order('RAND()').first
    self.current_response = question.build_random_response(self) if question.present?
    save! if saved_changes?
  end
end
