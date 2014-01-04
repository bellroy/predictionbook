class CredenceQuestion
  def initialize()
    @text = "The following are both numbers. Which is larger?"
    @answers = [ CredenceAnswer.new('Two', 2),
                 CredenceAnswer.new('Three', 3) ]
    @correct_index = 1
  end

  # Check whether n is the correct answer, and scores according to credence.
  # credence is a _percentage_, i.e. in the range (0, 100). ***UNTESTED***
  def score_answer(n, credence)
    truth_credence = (n == @correct_index) ? credence : 100 - credence
    (Math.log(2* truth_credence.to_f/100.0, 2) * 100).round
  end

  attr_reader :text, :answers, :correct_index
end

class CredenceAnswer
  def initialize(text, value)
    @text = text
    @value = value
  end

  attr_reader :text, :value
end
