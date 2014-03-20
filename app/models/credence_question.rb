class CredenceQuestion < ActiveRecord::Base
  belongs_to :credence_question_generator
  belongs_to :answer0, class_name: 'CredenceAnswer'
  belongs_to :answer1, class_name: 'CredenceAnswer'

  def self.pick_random
    # XXX This doesn't take gen.weight into account.
    num_gens = CredenceQuestionGenerator.count
    gen = CredenceQuestionGenerator.first(offset: rand(num_gens))

    answer_ids = gen.credence_answer_ids.shuffle.slice(0,2)

    answers = [ CredenceAnswer.find(answer_ids[0]),
                CredenceAnswer.find(answer_ids[1]) ]
    which = answers[0].real_val > answers[1].real_val

    # XXX This should check whether this question already exists.
    self.create(credence_question_generator: gen,
                answer0: answers[0],
                answer1: answers[1],
                answer0_correct: which)
  end

  def text
    self.credence_question_generator.text
  end

  def answers
    [ self.answer0, self.answer1 ]
  end

  # Check whether n is the correct answer, and scores according to credence.
  # credence is a _percentage_, i.e. in the range (0, 100). ***UNTESTED***
  def score_answer(n, credence)
    truth_credence = (n == 0 && self.answer0_correct) ? credence : 100 - credence
    (Math.log(2* truth_credence.to_f/100.0, 2) * 100).round
  end
end
