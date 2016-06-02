class CredenceAnswer < ActiveRecord::Base
  belongs_to :credence_question

  validates :rank, uniqueness: { scope: :credence_question_id }

  def format
    # Would be nice to format the text in bold.
    "#{text} (#{credence_question.prefix}#{value}#{credence_question.suffix})"
  end
end
