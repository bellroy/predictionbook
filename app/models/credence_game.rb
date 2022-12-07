# frozen_string_literal: true

class CredenceGame < ApplicationRecord
  belongs_to :user
  belongs_to :current_response, class_name: CredenceGameResponse.name, autosave: true, optional: true
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
    self.score += new_score
    self.num_answered += 1
    set_current_response
    save!
  end

  private

  def enabled_questions
    @enabled_questions ||= CredenceQuestion.enabled
  end

  def ensure_current_response
    unless current_response.present?
      set_current_response
      save!
    end
  end

  def set_current_response
    enabled_question_count = enabled_questions.count
    return if enabled_question_count.zero?

    random_offset = Random.rand(enabled_question_count)
    question = enabled_questions.offset(random_offset).first

    if question.present?
      self.current_response = question.build_random_response(self)
    end
  end
end
