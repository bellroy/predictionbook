class UserAuthorizer
  def self.call(user:, prediction:, action: 'show')
    new(user: user, prediction: prediction, action: action).call
  end

  def initialize(user:, prediction:, action: 'show')
    @user = user
    @prediction = prediction
    @action = action
  end

  def call
    return true if privileged_user?
    return false unless read_only_action?

    prediction.visible_to_everyone? || accessible_through_group?
  end

  private

  attr_reader :action, :prediction, :user

  def accessible_through_group?
    prediction.visible_to_group? && user_group.present?
  end

  def creator?
    user == prediction.creator
  end

  def privileged_user?
    creator? || user.admin? || user_group_role == 'admin'
  end

  def read_only_action?
    %w[index show].include?(action)
  end

  def user_group
    user.groups.find { |ug| ug.id == prediction.group_id }
  end

  def user_group_role
    user_group.user_role(user) if user_group.present?
  end
end
