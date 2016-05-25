class CredenceGameResponse < ActiveRecord::Base
  belongs_to :credence_game
  belongs_to :credence_question
  belongs_to :first_answer, class_name: 'CredenceAnswer'
  belongs_to :second_answer, class_name: 'CredenceAnswer'

  validates :credence_game_id, presence: true
  validates :credence_question_id, presence: true
  validates :first_answer_id, presence: true
  validates :second_answer_id, presence: true
  validates :correct_index, presence: true
  validates :answer_credence, inclusion: { in: 1..99, message: 'must be between 1 and 99' },
                              allow_nil: true

  delegate :text, to: :credence_question

  scope :answered, -> { where('answered_at IS NOT NULL') }

  def answers
    [first_answer, second_answer]
  end

  def answer_correct?
    given_answer == correct_index
  end

  # Check whether answer is the correct answer, and scores according to
  # credence. credence is a _percentage_, i.e. in the range [1, 99].
  def score_answer
    return nil if answer_credence.nil? || !valid?
    correct = answer_correct?
    truth_credence = correct ? answer_credence : (100 - answer_credence)
    score = (Math.log(2 * truth_credence.to_f / 100.0, 2) * 100).round
    [correct, score]
  end

  def score
    (score_answer || [0]).last
  end

  def answer_message
    # In the original game, you got a different message if you guessed 50%
    # (which gave you no points). If 50% becomes a valid guess, we'll want to do
    # the same here.
    right = answers[correct_index].format
    wrong = answers[1 - correct_index].format

    if answer_correct?
      %(<span class="credence-result"><strong>Correct!</strong>
          +#{score} points.</span><br>).html_safe +
        " The answer is #{right} versus #{wrong}."
    else
      %(<span class="credence-result"><strong>Incorrect.</strong>
          #{score} points.</span><br>).html_safe +
        " The right answer is #{right} versus #{wrong}."
    end
  end
end
