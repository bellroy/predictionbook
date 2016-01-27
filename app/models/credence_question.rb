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
    # be first_answer here than second_answer. We randomly swap them, to ensure
    # questions are uniformly distributed.
    if rand < 0.5
      first_answer, second_answer = second_answer, first_answer
    end

    which = first_answer.rank < second_answer.rank ? 0 : 1

    CredenceGameResponse.create(credence_question: self,
                                first_answer: first_answer,
                                second_answer: second_answer,
                                correct_index: which)
  end

  def self.create_from_element! (gen, id_prefix)
    return if gen['Type'] != 'Sorted'

    cq = CredenceQuestion.new(
      enabled: gen['Used'].to_s == 'y',
      text_id: "#{id_prefix}:#{gen['Id']}",
      question_type: gen['Type'].to_s,
      text: gen['QuestionText'].to_s,
      prefix: gen['InfoPrefix'].to_s,
      suffix: gen['InfoSuffix'].to_s,
      adjacent_within: gen['AdjacentWithin'].to_s.to_i,
      weight: gen['Weight'].to_s.to_f
    )
    cq.save!

    rank = -1
    last_val = nil
    gen.search('Answer').each do |ans|
      cur_val = ans['Value'].to_s
      if last_val != cur_val
        rank += 1
        last_val = cur_val
      end

      cq.credence_answers.create!(
        text: ans['Text'],
        value: cur_val,
        rank: rank
      )
    end

    return cq
  end
end
