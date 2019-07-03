class UserPseudonymizer
  CREATOR_ASSOCIATIONS = [Prediction, PredictionVersion]
  USER_ASSOCIATIONS = [Judgement, Response]

  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    ApplicationRecord.transaction do
      update_creator_associations
      update_user_associations
    end
  end

  private

  attr_reader :user

  def update_creator_associations
    CREATOR_ASSOCIATIONS.each do |model|
      model
        .where(creator_id: user.id)
        .update_all(creator_id: pseudonymous_user.id)
    end
  end

  def update_user_associations
    USER_ASSOCIATIONS.each do |model|
      model.where(user_id: user.id).update_all(user_id: pseudonymous_user.id)
    end
  end

  def pseudonymous_user
    @pseudonymous_user ||= User.pseudonymous_user
  end
end
