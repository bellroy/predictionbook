class CredenceQuestion
  def initialize()
    @text = "The following are both numbers. Which is larger?"

    v1 = rand(10)
    v2 = rand(10)
    while v1 == v2
      v2 = rand(10)
    end

    @answers = [ CredenceAnswer.new(text: 'First',
                                    real_val: v1,
                                    display_val: v1.to_s),
                 CredenceAnswer.new(text: 'Second',
                                    real_val: v2,
                                    display_val: v2.to_s) ]
    @correct_index = v1 > v2 ? 0 : 1
  end

  # Check whether n is the correct answer, and scores according to credence.
  # credence is a _percentage_, i.e. in the range (0, 100). ***UNTESTED***
  def score_answer(n, credence)
    truth_credence = (n == @correct_index) ? credence : 100 - credence
    (Math.log(2* truth_credence.to_f/100.0, 2) * 100).round
  end

  attr_reader :text, :answers, :correct_index
end
