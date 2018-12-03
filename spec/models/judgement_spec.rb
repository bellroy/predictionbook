# frozen_string_literal: true

require 'spec_helper'

describe Judgement do
  it 'has an associated user' do
    judgement = described_class.new
    expect(judgement.user).to eq nil
    expect(judgement).to respond_to(:user_id)
    expect(judgement).to respond_to(:user=)
  end

  it 'has an associated prediction' do
    judgement = described_class.new
    expect(judgement.prediction).to eq nil
    expect(judgement).to respond_to(:prediction)
    expect(judgement).to respond_to(:prediction=)
  end

  describe '#outcome' do
    it 'is true when assigned string “right”' do
      expect(described_class.new(outcome: 'right').outcome).to eq true
    end

    it 'is false when assigned string “wrong”' do
      expect(described_class.new(outcome: 'wrong').outcome).to eq false
    end

    it 'is nil when assigned string “unknown”' do
      expect(described_class.new(outcome: 'unknown').outcome).to eq nil
    end

    { 'wrong' => false, 'right' => true, 'unknown' => nil }.each do |outcome, bool|
      it "should map #{outcome} string to boolean #{bool}" do
        expect(described_class.new(outcome: outcome).outcome).to eq bool
      end
      it "should ignore cases for #{outcome.humanize} methods" do
        expect(described_class.new(outcome: outcome.humanize).outcome).to eq bool
      end
    end

    [true, false, nil].each do |bool|
      it "should be #{bool} when assigned #{bool}" do
        expect(described_class.new(outcome: bool).outcome).to eq bool
      end
    end
  end

  describe '#outcome in words' do
    it 'is "right" when outcome is true' do
      expect(described_class.new(outcome: true).outcome_in_words).to match(/^right/)
    end
    it 'is "wrong" when outcome is false' do
      expect(described_class.new(outcome: false).outcome_in_words).to match(/^wrong/)
    end
    it 'is "unknown" when outcome is nil' do
      expect(described_class.new(outcome: nil).outcome_in_words).to match(/^unknown/)
    end
  end
end
