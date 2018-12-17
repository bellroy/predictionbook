# frozen_string_literal: true

require 'spec_helper'

describe CredenceQuestion do
  let(:game) { FactoryBot.create(:credence_game) }

  it 'is able to create random questions' do
    question = FactoryBot.create(:credence_question)
    (0..9).each do |rank|
      FactoryBot.create(:credence_answer, credence_question: question, rank: rank)
    end

    response = question.build_random_response(game)
    expect(response.class).to eq CredenceGameResponse
  end

  it 'distributes responses uniformly in answer-space' do
    # gen.build_random_response(game) is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?
    question = FactoryBot.create(:credence_question)
    FactoryBot.create_list(:credence_answer, 3, credence_question: question)

    counts = Hash.new(0)
    10_000.times do |i|
      response = question.build_random_response(game)
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

  it 'creates questions from parsed XML' do
    parsed = Nokogiri::XML(<<-XML).root
      <QuestionGenerator Id="text-id" Tags="" Used="y" Type="Sorted" Weight="0.5" QuestionText="question" AdjacentWithin="-1" InfoPrefix="prefix" InfoSuffix="suffix">
        <Answer Text="first" Value="B" />
        <Answer Text="second" Value="A" />
      </QuestionGenerator>
    XML
    question = described_class.create_from_xml_element!(parsed, 'id-prefix')

    expect(question.enabled).to eq true
    expect(question.text_id).to eq 'id-prefix:text-id'
    expect(question.question_type).to eq 'Sorted'
    expect(question.text).to eq 'question'
    expect(question.prefix).to eq 'prefix'
    expect(question.suffix).to eq 'suffix'
    expect(question.adjacent_within).to eq(-1)
    expect(question.weight).to eq 0.5

    first_answer = question.answers[0]
    expect(first_answer.rank).to eq 0
    expect(first_answer.text).to eq 'first'
    expect(first_answer.value).to eq 'B'

    second_answer = question.answers[1]
    expect(second_answer.rank).to eq 1
    expect(second_answer.text).to eq 'second'
    expect(second_answer.value).to eq 'A'
  end
end
