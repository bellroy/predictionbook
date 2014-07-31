class CredenceQuestionGenerator < ActiveRecord::Base
  has_many :credence_answers

  def create_random_question
    answer_ids = self.credence_answer_ids.shuffle

    ans0 = CredenceAnswer.find(answer_ids.pop)
    ans1 = CredenceAnswer.find(answer_ids.pop)

    while ans0.rank == ans1.rank do
      ans1 = CredenceAnswer.find(answer_ids.pop)
    end

    # If a generator has two answers of the same rank, those are more likely to
    # be ans0 here than ans1. We randomly swap them, to ensure questions are
    # uniformly distributed.
    if rand < 0.5
      ans0, ans1 = ans1, ans0
    end

    which = ans0.rank < ans1.rank ? 0 : 1

    CredenceQuestion.create(credence_question_generator: self,
                            answer0: ans0,
                            answer1: ans1,
                            correct_index: which)
  end
end
