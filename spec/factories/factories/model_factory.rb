module ModelFactory

  def valid_prediction(attributes={})
    merged = {
      creator: valid_user(name: 'predictor'),
      description: 'The world will end tomorrow!',
      deadline: 1.day.ago,
      initial_confidence: '100'
    }.merge(attributes)
    p = Prediction.new(merged)
  end

  def valid_response(attributes = {})
    merged = {
      prediction: valid_prediction,
      user: valid_user(name: 'responder'),
      confidence: 60,
      comment: "Yehar."
    }.merge(attributes)
    Response.new(merged)
  end

  def valid_judgement(attributes = {})
    merged = {
      prediction: valid_prediction,
      user: valid_user,
    }.merge(attributes)
    Judgement.new(merged)
  end

  def valid_user(attributes = {})
    password = attributes.delete(:password) || '123456'
    password_confirmation = attributes.delete(:password_confirmation) || password
    merged = {
      login: 'zippy',
      password: password,
      password_confirmation: password_confirmation
    }.merge(attributes)
    User.new(merged)
  end

  def valid_deadline_notification(attributes={})
    merged = {
      user: valid_user(email: 'zippy@predictionbook.com'),
      prediction: valid_prediction
    }.merge(attributes)
    DeadlineNotification.new(merged)
  end

  def valid_response_notification(attributes={})
    merged = {
      user: valid_user(email: 'zippy@predictionbook.com'),
      prediction: valid_prediction
    }.merge(attributes)
    ResponseNotification.new(merged)
  end

  def valid_credence_question(attributes={})
    merged = {
      enabled: true,
      text: "Which thing comes sooner?",
      prefix: "The ",
      suffix: " thing",
      weight: 1
    }.merge(attributes)
    CredenceQuestion.new(merged)
  end

  def valid_credence_answer(attributes={})
    merged = {
      credence_question: valid_credence_question
    }.merge(attributes)
    CredenceAnswer.new(merged)
  end

  def valid_credence_game_response(attributes={})
    ci = attributes[:correct_index] || 0
    first_rank = ci
    second_rank = 1 - ci
    merged = {
      credence_question: valid_credence_question,
      first_answer: valid_credence_answer(text: "B", rank: first_rank, value: "this"),
      second_answer: valid_credence_answer(text: "A", rank: second_rank, value: "that"),
      correct_index: ci,
      asked_at: '2014-01-01 12:00:00'
    }.merge(attributes)

    CredenceGameResponse.new(merged)
  end

  def valid_answered_credence_question(attributes={})
    merged = {
      answered_at: '2014-01-01 12:00:01',
      given_answer: 0,
      answer_credence: 60
    }.merge(attributes)
    valid_credence_game_response(merged)
  end

  def valid_credence_game(attributes={})
    merged = {
      score: 0,
      num_answered: 0,
      current_response: valid_credence_game_response
    }.merge(attributes)
    g = CredenceGame.new(merged)

    if not g.current_response.nil?
      g.current_response.credence_game = g
    end

    g
  end

  def self.produced_models
    instance_methods.grep(/^valid_/).collect{|method| method.to_s.gsub(/^valid_/,'')}
  end

  produced_models.each do |model_name|
    define_method "create_valid_#{model_name}" do |*args|
      attributes = args.first || {}
      model = send("valid_#{model_name}", attributes)
      model.save!
      model
    end
  end

  # For shared example groups
  def create_described_type(attrs={})
    send("create_valid_#{described_type.to_s.underscore}", attrs)
  end

end
