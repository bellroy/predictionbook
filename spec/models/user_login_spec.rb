require 'spec_helper'

describe UserLogin do
  let(:user_login) { described_class.new(login) }

  describe '#to_s' do
    subject { user_login.to_s }

    context 'a value' do
      let(:login) { 'something' }
      it { is_expected.to eq 'something' }
    end

    context 'a value with [dot] in it' do
      let(:login) { 'some[dot]thing' }
      it { is_expected.to eq 'some.thing' }
    end
  end
end
