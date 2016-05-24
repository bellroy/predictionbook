require 'spec_helper'

describe CredenceAnswer do
  it 'should include the text and value when displayed' do
    a = FactoryGirl.create(:credence_answer, text: 'xyzzy', value: 'FlibbertY')
    expect(a.format.include?(a.text)).to eq true
    expect(a.format.include?(a.value)).to eq true
  end
end
