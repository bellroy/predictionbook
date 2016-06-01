require 'spec_helper'

describe CredenceQuestion do
  let(:game) { FactoryGirl.create(:credence_game) }

  it 'should be able to create random questions' do
    question = FactoryGirl.create(:credence_question)
    (0..9).each do |rank|
      FactoryGirl.create(:credence_answer, credence_question: question, rank: rank)
    end

    response = question.create_random_response(game)
    expect(response.class).to eq CredenceGameResponse
  end

  it 'should uniformly distribute responses in answer-space' do
    # gen.create_random_response(game) is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?
    puts
    puts 'Running uniform distribution test for credence games. Usually takes about 30 seconds.'

    question = FactoryGirl.create(:credence_question)
    FactoryGirl.create_list(:credence_answer, 3, credence_question: question)

    counts = Hash.new(0)
    10_000.times do
      response = question.create_random_response(game)
      counts[response.first_answer_id * 100 + response.second_answer_id] += 1
    end

    # If the responses are uniformly distributed, then the number of entries in
    # the first bucket follows a Binomial(10000, 0.25) distribution.
    lower_bound = 1566
    upper_bound = 1766
    counts.each do |_k, v|
      expect(v).to be_between(lower_bound, upper_bound), 'Expected question counts between ' \
                                                         "#{lower_bound} and #{upper_bound}, " \
                                                         "inclusive. Actual counts: #{counts}."
    end
  end

  it 'should create questions from parsed XML' do
    parsed = Nokogiri::XML(<<-XML).root
      <QuestionGenerator Id="text-id" Tags="" Used="y" Type="Sorted" Weight="0.5" QuestionText="question" AdjacentWithin="-1" InfoPrefix="prefix" InfoSuffix="suffix">
        <Answer Text="first" Value="B" />
        <Answer Text="second" Value="A" />
      </QuestionGenerator>
    XML
    question = CredenceQuestion.create_from_xml_element!(parsed, 'id-prefix')

    expect(question.enabled).to eq true
    expect(question.text_id).to eq 'id-prefix:text-id'
    expect(question.question_type).to eq 'Sorted'
    expect(question.text).to eq 'question'
    expect(question.prefix).to eq 'prefix'
    expect(question.suffix).to eq 'suffix'
    expect(question.adjacent_within).to eq(-1)
    expect(question.weight).to eq 0.5

    answer_0 = question. answers[0]
    expect(answer_0.rank).to eq 0
    expect(answer_0.text).to eq 'first'
    expect(answer_0.value).to eq 'B'

    answer_1 = question. answers[1]
    expect(answer_1.rank).to eq 1
    expect(answer_1.text).to eq 'second'
    expect(answer_1.value).to eq 'A'
  end
end
