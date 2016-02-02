class CredenceGameResponse < ActiveRecord::Base
  belongs_to :credence_game
  belongs_to :credence_question
  belongs_to :first_answer, class_name: 'CredenceAnswer'
  belongs_to :second_answer, class_name: 'CredenceAnswer'

  def self.pick_random
    enabled_gens = CredenceQuestion.where(enabled: true)
    num_enabled = enabled_gens.count

    gen = enabled_gens.first(offset: rand(num_enabled))
    while !gen.enabled || gen.weight < rand
      gen = enabled_gens.first(offset: rand(num_enabled))
    end

    gen.create_random_question
  end

  def text
    self.credence_question.text
  end

  def answers
    [ self.first_answer, self.second_answer ]
  end

  def answer_correct?(ans)
    ans == self.correct_index
  end

  # Check whether ans is the correct answer, and scores according to credence.
  # credence is a _percentage_, i.e. in the range [1, 99].
  def score_answer(ans, credence)
    # A certain-but-wrong answer gives an error anyway, but a certain-and-right
    # answer just scores 100. We have to reject both, or players can guess with
    # no consequences.
    if credence < 1 or credence > 99
      raise ArgumentError, 'Credence must be between 1 and 99'
    end

    correct = self.answer_correct? ans
    truth_credence = correct ? credence : 100 - credence
    score = (Math.log(2* truth_credence.to_f/100.0, 2) * 100).round
    return correct, score
  end

  def score
    _, s = self.score_answer(self.given_answer, self.answer_credence)
    s
  end

  def answer_message(ans, score)
    # In the original game, you got a different message if you guessed 50%
    # (which gave you no points). If 50% becomes a valid guess, we'll want to do
    # the same here.

    right = self.answers[self.correct_index].format
    wrong = self.answers[1 - self.correct_index].format

    if self.answer_correct? ans
      %Q{<span class="credence-result"><strong>Correct!</strong>
          +#{score} points.</span><br>}.html_safe +
        " The answer is #{right} versus #{wrong}."
    else
      %Q{<span class="credence-result"><strong>Incorrect.</strong>
          #{score} points.</span><br>}.html_safe +
        " The right answer is #{right} versus #{wrong}."
    end
  end
end
