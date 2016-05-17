class CredenceAnswer < ActiveRecord::Base
  belongs_to :credence_question

  def format
    # Would be nice to format the text in bold.
    question = self.credence_question
    "#{self.text} (#{question.prefix}#{self.value}#{question.suffix})"
  end
end
