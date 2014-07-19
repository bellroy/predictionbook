module ModelFactory
  
  def valid_prediction(attributes={})
    p = Prediction.new({
      :creator => valid_user(:name => 'predictor'),
      :description => 'The world will end tomorrow!',
      :deadline => 1.day.ago,
      :initial_confidence => '100'
    }.merge(attributes))
  end
  
  def valid_response(attributes = {})
    Response.new({
      :prediction => valid_prediction,
      :user => valid_user(:name => 'responder'),
      :confidence => 60,
      :comment => "Yehar."
    }.merge(attributes))
  end
  
  def valid_judgement(attributes = {})
    Judgement.new({
      :prediction => valid_prediction,
      :user => valid_user,
    }.merge(attributes))
  end
  
  def valid_user(attributes = {})
    password = attributes.delete(:password) || '123456'
    password_confirmation = attributes.delete(:password_confirmation) || password
    User.new({:login => 'zippy', :password => password, :password_confirmation => password_confirmation}.merge(attributes))
  end
  
  def valid_deadline_notification(attributes={})
    DeadlineNotification.new({
      :user=> valid_user(:email=> 'zippy@predictionbook.com'),
      :prediction=> valid_prediction
    }.merge(attributes))
  end

  def valid_response_notification(attributes={})
    ResponseNotification.new({
      :user=> valid_user(:email=> 'zippy@predictionbook.com'),
      :prediction=> valid_prediction
    }.merge(attributes))
  end

  def valid_credence_question_generator(attributes={})
    CredenceQuestionGenerator.new({
      text: "Which thing comes sooner?",
      prefix: "The ",
      suffix: " thing"
    }.merge(attributes))
  end

  def valid_credence_answer(attributes={})
    CredenceAnswer.new({
      credence_question_generator: valid_credence_question_generator
    }.merge(attributes))
  end

  def valid_credence_question(attributes={})
    ci = attributes[:correct_index] || 0
    rank0 = ci
    rank1 = 1 - ci

    CredenceQuestion.new({
      credence_question_generator: valid_credence_question_generator,
      answer0: valid_credence_answer(text: "B", rank: rank0, value: "this"),
      answer1: valid_credence_answer(text: "A", rank: rank1, value: "that"),
      correct_index: ci,
      asked_at: '2014-01-01 12:00:00'
    }.merge(attributes))
  end

  def valid_answered_credence_question(attributes={})
    valid_credence_question(answered_at: '2014-01-01 12:00:01',
                            given_answer: 0,
                            answer_credence: 60)
  end

  def valid_credence_game(attributes={})
    g = CredenceGame.new({
      score: 0,
      num_answered: 0,
      current_question: valid_credence_question
    }.merge(attributes))

    if not g.current_question.nil?
      g.current_question.credence_game = g
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
