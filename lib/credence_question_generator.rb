class CredenceQuestionGenerator
  def initialize(file, quiet: false)
    @file = file
    @quiet = quiet
  end

  def call
    destroy_old_questions

    document.search('QuestionGenerator').each do |generator|
      create_question(generator)
    end
  end

  private

  attr_reader :file, :quiet

  def create_question(generator)
    question = CredenceQuestion.create_from_xml_element!(generator, id_prefix)

    if question.present? && !quiet?
      puts "Created question with #{question.answers.count} answers: #{question.text}"
    end
  end

  def destroy_old_questions
    CredenceGame.destroy_all && CredenceQuestion.destroy_all
  end

  def document
    @document ||= Nokogiri::XML(open(file)) 
  end

  def id_prefix
    document.at('Questions')['IdPrefix']
  end

  def quiet?
    !!quiet
  end
end