class CredenceQuestion
  def initialize()
    @text = "The following are both numbers. Which is larger?"

    # XXX This doesn't take gen.weight into account.
    num_gens = CredenceQuestionGenerator.count
    gen = CredenceQuestionGenerator.first(offset: rand(num_gens))

    @text = gen.text

    answer_ids = gen.credence_answer_ids.shuffle.slice(0,2)

    @answers = [ CredenceAnswer.find(answer_ids[0]),
                 CredenceAnswer.find(answer_ids[1]) ]
    @correct_index = @answers[0].real_val > @answers[1].real_val ? 0 : 1
  end

  # Check whether n is the correct answer, and scores according to credence.
  # credence is a _percentage_, i.e. in the range (0, 100). ***UNTESTED***
  def score_answer(n, credence)
    truth_credence = (n == @correct_index) ? credence : 100 - credence
    (Math.log(2* truth_credence.to_f/100.0, 2) * 100).round
  end

  attr_reader :text, :answers, :correct_index
end
