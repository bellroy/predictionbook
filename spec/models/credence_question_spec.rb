require 'spec_helper'

describe CredenceQuestion do
  it 'should be able to create random questions' do
    question = create_valid_credence_question
    (0..9).each do |rank|
      create_valid_credence_answer(credence_question: question, rank: rank)
    end

    response = question.create_random_question
    expect(response.class).to eq CredenceGameResponse
  end

  it 'should not create a question where both answers have the same rank' do
    question = create_valid_credence_question
    [1, 1, 1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question: question, rank: rank)
    end

    100.times do
      response = question.create_random_question
      expect(response.first_answer.rank).to_not eq response.second_answer.rank
    end
  end

  it 'should uniformly distribute questions in aswer-space' do
    pending "work out a good test to use"
    raise "not yet implemented"

    # gen.create_random_question is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?

    question = create_valid_credence_question
    [1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question: question, rank: rank)
    end

    counts = Hash.new(0)
    400.times do
      response = question.create_random_question
      key = [response.first_answer.id, response.second_answer.id]
      counts[key] += 1
    end

    # What tests do we apply to counts?
  end

  it 'should create questions from parsed XML' do
    parsed = Nokogiri::XML(<<-XML).root
      <QuestionGenerator Id="text-id" Tags="" Used="y" Type="Sorted" Weight="0.5" QuestionText="question" AdjacentWithin="-1" InfoPrefix="prefix" InfoSuffix="suffix">
        <Answer Text="first" Value="B" />
        <Answer Text="second" Value="A" />
      </QuestionGenerator>
    XML
    question = CredenceQuestion.create_from_xml_element!(parsed, "id-prefix")

    expect(question.enabled).to eq true
    expect(question.text_id).to eq "id-prefix:text-id"
    expect(question.question_type).to eq "Sorted"
    expect(question.text).to eq "question"
    expect(question.prefix).to eq "prefix"
    expect(question.suffix).to eq "suffix"
    expect(question.adjacent_within).to eq -1
    expect(question.weight).to eq 0.5

    answer_0 = question.credence_answers[0]
    expect(answer_0.rank).to eq 0
    expect(answer_0.text).to eq "first"
    expect(answer_0.value).to eq "B"

    answer_1 = question.credence_answers[1]
    expect(answer_1.rank).to eq 1
    expect(answer_1.text).to eq "second"
    expect(answer_1.value).to eq "A"
  end

  it 'should assign adjacent answers equal ranks when they have equal value' do
    parsed = Nokogiri::XML(<<-XML).root
      <QuestionGenerator Tags="" Used="y" Type="Sorted" Weight="0.5" QuestionText="question" AdjacentWithin="-1" InfoPrefix="prefix" InfoSuffix="suffix">
        <Answer Text="first" Value="A" />
        <Answer Text="second" Value="A" />
        <Answer Text="third" Value="B" />
        <Answer Text="fourth" Value="A" />
      </QuestionGenerator>
    XML
    question = CredenceQuestion.create_from_xml_element!(parsed, "id-prefix")

    expect(question.credence_answers.map(&:rank)).to eq [0, 0, 1, 2]
  end
end
