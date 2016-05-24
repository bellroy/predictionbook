class CredenceAnswer < ActiveRecord::Base
  belongs_to :credence_question

  def format
    # Would be nice to format the text in bold.
    question = credence_question
    "#{text} (#{question.prefix}#{value}#{question.suffix})"
  end
end
