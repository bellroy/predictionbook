# frozen_string_literal: true

module UserHelper
  def tag_name_options(user)
    Gutentag::Tag
      .where(
        id: Gutentag::Tagging.where(
          taggable_id: user.predictions.pluck(:id),
          taggable_type: Prediction.name
        ).pluck(:tag_id)
      )
      .order(:name)
      .pluck(:name)
  end
end
