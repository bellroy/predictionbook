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

  def self.create_from_xml_element! (generator, id_prefix)
    return if generator['Type'] != 'Sorted'

    question = CredenceQuestion.new(
      enabled: generator['Used'].to_s == 'y',
      text_id: "#{id_prefix}:#{generator['Id']}",
      question_type: generator['Type'].to_s,
      text: generator['QuestionText'].to_s,
      prefix: generator['InfoPrefix'].to_s,
      suffix: generator['InfoSuffix'].to_s,
      adjacent_within: generator['AdjacentWithin'].to_s.to_i,
      weight: generator['Weight'].to_s.to_f
    )
    question.save!

    rank = -1
    last_value = nil
    generator.search('Answer').each do |answer|
      current_value = answer['Value'].to_s
      if last_value != current_value
        rank += 1
        last_value = current_value
      end

      question.credence_answers.create!(
        text: answer['Text'],
        value: current_value,
        rank: rank
      )
    end

    return question
  end
end
