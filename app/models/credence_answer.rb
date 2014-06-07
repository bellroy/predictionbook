class CredenceAnswer < ActiveRecord::Base
  belongs_to :credence_question_generator

  def format()
    # Would be nice to format the text in bold.
    gen = self.credence_question_generator
    "#{self.text} (#{gen.prefix}#{self.value}#{gen.suffix})"
  end
end
