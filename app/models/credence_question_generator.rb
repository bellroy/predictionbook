class CredenceQuestionGenerator < ActiveRecord::Base
  has_many :credence_answers

  def create_random_question
    answer_ids = self.credence_answer_ids.shuffle.slice(0,2)

    answers = [ CredenceAnswer.find(answer_ids[0]),
                CredenceAnswer.find(answer_ids[1]) ]
    which = answers[0].rank < answers[1].rank ? 0 : 1

    # XXX This should check whether this question already exists.
    CredenceQuestion.create(credence_question_generator: self,
                            answer0: answers[0],
                            answer1: answers[1],
                            correct_index: which)
  end
end
