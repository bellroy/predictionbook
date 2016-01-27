require 'spec_helper'

describe CredenceQuestion do
  it 'should be able to create random questions' do
    gen = create_valid_credence_question
    as = (0..9).map do |rank|
      create_valid_credence_answer(credence_question: gen, rank: rank)
    end

    q = gen.create_random_question
    expect(q.class).to eq CredenceGameResponse
  end

  it 'should not create a question where both answers have the same rank' do
    gen = create_valid_credence_question
    [1, 1, 1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question: gen, rank: rank)
    end

    100.times do
      q = gen.create_random_question
      expect(q.first_answer.rank).to_not eq q.second_answer.rank
    end
  end

  it 'should uniformly distribute questions in aswer-space' do
    pending "work out a good test to use"
    raise "not yet implemented"

    # gen.create_random_question is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?

    gen = create_valid_credence_question
    [1, 1, 2].each do |rank|
      create_valid_credence_answer(credence_question: gen, rank: rank)
    end

    counts = Hash.new(0)
    400.times do
      q = gen.create_random_question
      key = [q.first_answer.id, q.second_answer.id]
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
    cq = CredenceQuestion.create_from_element!(parsed, "id-prefix")

    expect(cq.enabled).to eq true
    expect(cq.text_id).to eq "id-prefix:text-id"
    expect(cq.question_type).to eq "Sorted"
    expect(cq.text).to eq "question"
    expect(cq.prefix).to eq "prefix"
    expect(cq.suffix).to eq "suffix"
    expect(cq.adjacent_within).to eq -1
    expect(cq.weight).to eq 0.5

    a0 = cq.credence_answers[0]
    expect(a0.rank).to eq 0
    expect(a0.text).to eq "first"
    expect(a0.value).to eq "B"

    a1 = cq.credence_answers[1]
    expect(a1.rank).to eq 1
    expect(a1.text).to eq "second"
    expect(a1.value).to eq "A"
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
    cq = CredenceQuestion.create_from_element!(parsed, "id-prefix")

    expect(cq.credence_answers.map(&:rank)).to eq [0, 0, 1, 2]
  end
end
