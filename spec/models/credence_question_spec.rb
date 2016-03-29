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
    t = Time.now

    # gen.create_random_question is sufficiently slow that we don't want to do
    # it loads of times. But if we don't do it enough, our test will be prone to
    # failing randomly.
    #   Is it possible to only have this test run if we request it explicitly?

    question = create_valid_credence_question

    answers = [1, 1, 2].map do |rank|
      create_valid_credence_answer(credence_question: question, rank: rank)
    end

    question.stub(:credence_answer_ids).and_return([0, 1, 2])
    CredenceAnswer.stub(:find) do |id|
      answers[id]
    end
    CredenceGameResponse.stub(:create) do |args|
      [args[:first_answer].id, args[:second_answer].id]
    end

    counts = Hash.new(0)
    10000.times do
      response = question.create_random_question
      counts[response] += 1
    end

    # If the questions are uniformly distributed, then the number of entries in
    # the first bucket follows a Binomial(10000, 0.25) distribution. This will
    # almost certainly fall within the range [2095, 2919] (probability less than
    # 10^-21 of falling out on each end).

    # The probability that the count in *any* bucket falls outside this range is
    # less than four times the probability of the first bucket falling outside;
    # thus, less than 8 * 10^-21, or less than 10^-20.

    # If that happens, we can be confident that the distribution isn't uniform.

    lower_bound = 2095
    upper_bound = 2919

    counts.each do |k,v|
      expect(v).to be_between(lower_bound, upper_bound), "Expected question counts between #{lower_bound} and #{upper_bound}, inclusive. Actual counts: #{counts}."
    end
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
