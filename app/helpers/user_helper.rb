# frozen_string_literal: true

module UserHelper
  def tag_name_options(user)
    user.predictions.includes(:tags).pluck(:name)
  end
end

