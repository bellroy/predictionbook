# frozen_string_literal: true

class Judgement < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :prediction

  def outcome=(value)
    outcome = boolean_from_value(value)
    self[:outcome] = outcome
  end

  def outcome_in_words
    case outcome
    when true then 'right'
    when false then 'wrong'
    else 'unknown'
    end
  end

  def worthless?
    outcome.nil? && user.nil?
  end

  private

  def boolean_from_value(value)
    case value.to_s.downcase
    when 'right', 'true', '1' then true
    when 'wrong', 'false', '0' then false
    end
  end
end
