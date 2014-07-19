class CredenceQuestion < ActiveRecord::Base
  belongs_to :credence_game
  belongs_to :credence_question_generator
  belongs_to :answer0, class_name: 'CredenceAnswer'
  belongs_to :answer1, class_name: 'CredenceAnswer'

  def self.pick_random
    # XXX This doesn't take gen.weight into account.
    num_gens = CredenceQuestionGenerator.count
    gen = CredenceQuestionGenerator.first(offset: rand(num_gens))

    gen.create_random_question
  end

  def text
    self.credence_question_generator.text
  end

  def answers
    [ self.answer0, self.answer1 ]
  end

  def answer_correct?(ans)
    ans == self.correct_index
  end

  # Check whether ans is the correct answer, and scores according to credence.
  # credence is a _percentage_, i.e. in the range (0, 100).
  def score_answer(ans, credence)
    correct = self.answer_correct? ans
    truth_credence = correct ? credence : 100 - credence
    score = (Math.log(2* truth_credence.to_f/100.0, 2) * 100).round
    return correct, score
  end

  def score
    _, s = self.score_answer(self.given_answer, self.answer_credence)
    s
  end

  def answer_message(ans)
    # In the original game, you got a different message if you guessed 50%
    # (which gave you no points). If 50% becomes a valid guess, we'll want to do
    # the same here.

    right = self.answers[self.correct_index].format
    wrong = self.answers[1 - self.correct_index].format

    if self.answer_correct? ans
      "Correct! The answer is #{right} versus #{wrong}."
    else
      "Incorrect. The right answer is #{right} versus #{wrong}."
    end
  end
end
