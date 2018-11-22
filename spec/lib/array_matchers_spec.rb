# frozen_string_literal: true

require 'spec_helper'

describe 'ArrayMatchers' do
  it 'checks the ordered containment matcher works' do
    expect([10, 20, 5, 11]).to contain_in_order([20, 5])
  end

  it 'checks the matcher catches a proper fail' do
    error_type = RSpec::Expectations::ExpectationNotMetError
    expect { expect([5, 3, 2, 1]).to contain_in_order([1, 2]) }.to raise_error error_type
  end
end
