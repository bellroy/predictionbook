class CredenceQuestion < ActiveRecord::Base
  has_many :answers, class_name: CredenceAnswer.name, dependent: :destroy, autosave: true
  has_many :responses, class_name: CredenceGameResponse.name, dependent: :destroy, autosave: true

  def build_random_response(game)
    random_answers = []
    answer_count = answers.size
    while answer_count >= 0 && random_answers.length < [answer_count, 5].minmax.first
      random_index = Random.rand(answer_count)
      random_answer = answers[random_index]
      random_answers << random_answer unless random_answers.include?(random_answer)
    end
    raise 'Not enough answers to create a random response' unless random_answers.length >= 2

    first_answer = random_answers.first
    second_answer = random_answers.find { |answer| answer.value != first_answer.value }
    which = first_answer.rank < second_answer.rank ? 0 : 1
    responses.new(credence_game: game, first_answer: first_answer, second_answer: second_answer,
                  correct_index: which)
  end

  def self.create_from_xml_element!(generator, id_prefix)
    question_type = generator['Type'].to_s
    return if question_type != 'Sorted'

    question = CredenceQuestion.create(
      enabled: generator['Used'].to_s == 'y', text_id: "#{id_prefix}:#{generator['Id']}",
      question_type: question_type, text: generator['QuestionText'].to_s,
      prefix: generator['InfoPrefix'].to_s, suffix: generator['InfoSuffix'].to_s,
      adjacent_within: generator['AdjacentWithin'].to_s.to_i, weight: generator['Weight'].to_s.to_f
    )
    generator.search('Answer').each_with_index do |answer, index|
      question.answers.create!(text: answer['Text'], value: answer['Value'].to_s, rank: index)
    end
    question
  end
end
