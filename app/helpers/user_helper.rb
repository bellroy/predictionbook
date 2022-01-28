# frozen_string_literal: true

module UserHelper
  def tag_name_options      
    Gutentag::Tag.pluck(:name)
  end
end
  