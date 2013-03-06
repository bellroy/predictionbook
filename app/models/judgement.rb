class Judgement < ActiveRecord::Base
  belongs_to :user
  belongs_to :prediction
  
  def outcome=(string_or_boolean)
    write_attribute :outcome, string_or_boolean.is_a?(String) ? boolean_from_string(string_or_boolean) : string_or_boolean
  end
  
  def outcome_in_words
    case(outcome)
    when true then 'right'
    when false then 'wrong'
    else 'unknown'
    end
  end
  
  def worthless?
    outcome.nil? && user.nil?
  end
  
private
  def boolean_from_string(str)
    case(str.downcase)
    when 'right' then true
    when 'wrong' then false
    else nil
    end
  end
end
