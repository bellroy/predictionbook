class CredenceAnswer < ActiveRecord::Base
  belongs_to :credence_question

  def format
    # Would be nice to format the text in bold.
    "#{text} (#{credence_question.prefix}#{value}#{credence_question.suffix})"
  end
end
