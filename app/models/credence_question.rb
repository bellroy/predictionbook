class CredenceQuestion < ActiveRecord::Base
  belongs_to :credence_game
  belongs_to :credence_question_generator
  belongs_to :answer0, class_name: 'CredenceAnswer'
  belongs_to :answer1, class_name: 'CredenceAnswer'

  def self.pick_random
    num_gens = CredenceQuestionGenerator.count
    gen = CredenceQuestionGenerator.first(offset: rand(num_gens))
    while gen.weight < rand
      gen = CredenceQuestionGenerator.first(offset: rand(num_gens))
    end

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

  def to_wager
    # Return an object suitable for passing to the Statistics class.
    wager = Class.new do
      define_method :initialize do |q|
        @q = q
      end

      define_method :unknown? do
        @q.given_answer.nil?
      end

      define_method :correct? do
        if self.unknown?
          nil
        else
          @q.answer_correct? @q.given_answer
        end
      end

      define_method :relative_confidence do
        # Kind of hacky: the graphs lump 99% and 90% together, which we don't
        # want for the credence game. Pretend those are all 100%. If we allow
        # users to enter arbitrary credences, we'll need to rethink this.
        cred = @q.answer_credence
        cred == 99 ? 100 : cred
      end
    end

    wager.new(self)
  end
end