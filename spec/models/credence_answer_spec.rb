# frozen_string_literal: true

require 'spec_helper'

describe CredenceAnswer do
  it 'includes the text and value when displayed' do
    answer = FactoryBot.create(:credence_answer, text: 'xyzzy', value: 'FlibbertY')
    expect(answer.format.include?(answer.text)).to eq true
    expect(answer.format.include?(answer.value)).to eq true
  end
end
