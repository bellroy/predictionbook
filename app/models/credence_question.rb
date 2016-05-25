class CredenceQuestion < ActiveRecord::Base
  has_many :answers, class_name: CredenceAnswer, dependent: :destroy, autosave: true
  has_many :responses, class_name: CredenceGameResponse, dependent: :destroy, autosave: true

  def create_random_response(game)
    randomly_sorted_answers = answers.order('RAND()').to_a
    raise 'Not enough answers to create a random response' if randomly_sorted_answers.length < 2
    first_answer = randomly_sorted_answers.first
    first_answer_rank = first_answer.rank
    second_answer = randomly_sorted_answers.find { |answer| answer.rank != first_answer_rank } ||
                    randomly_sorted_answers.last
    # If a generator has two answers of the same rank, those are more likely to
    # be first_answer here than second_answer. We randomly swap them, to ensure
    # questions are uniformly distributed.
    first_answer, second_answer = second_answer, first_answer if rand < 0.5
    which = first_answer_rank < second_answer.rank ? 0 : 1
    responses.create!(credence_game: game, first_answer: first_answer, second_answer: second_answer,
                      correct_index: which)
  end

  def self.create_from_xml_element!(generator, id_prefix)
    question_type = generator['Type'].to_s
    return if question_type != 'Sorted'

    question = CredenceQuestion.new(
      enabled: generator['Used'].to_s == 'y',
      text_id: "#{id_prefix}:#{generator['Id']}",
      question_type: question_type,
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

      question.answers.create!(text: answer['Text'], value: current_value, rank: rank)
    end

    question
  end
end
