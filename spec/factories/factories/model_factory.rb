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
  
  def self.produced_models
    instance_methods.grep(/^valid_/).collect{|method| method.gsub(/^valid_/,'')}
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
