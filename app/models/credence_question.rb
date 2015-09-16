class CredenceQuestion < ActiveRecord::Base
  has_many :credence_answers, dependent: :destroy

  def create_random_question
    answer_ids = self.credence_answer_ids.shuffle

    first_answer = CredenceAnswer.find(answer_ids.pop)
    second_answer = CredenceAnswer.find(answer_ids.pop)

    while first_answer.rank == second_answer.rank do
      second_answer = CredenceAnswer.find(answer_ids.pop)
    end

    # If a generator has two answers of the same rank, those are more likely to
    # be first_answer here than second_answer. We randomly swap them, to ensure questions are
    # uniformly distributed.
    if rand < 0.5
      first_answer, second_answer = second_answer, first_answer
    end

    which = first_answer.rank < second_answer.rank ? 0 : 1

    CredenceGameResponse.create(credence_question: self,
                            first_answer: first_answer,
                            second_answer: second_answer,
                            correct_index: which)
  end
end
