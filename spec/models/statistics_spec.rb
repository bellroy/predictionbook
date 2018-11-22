# frozen_string_literal: true

require 'spec_helper'

describe Statistics do
  describe 'initialization' do
    let(:stats) { described_class.new }

    before do
      first_response = FactoryBot.create(:response, confidence: 50)
      FactoryBot.create(:judgement, prediction: first_response.prediction, outcome: 0)
      second_response = FactoryBot.create(:response, confidence: 40)
      FactoryBot.create(:judgement, prediction: second_response.prediction, outcome: 0)
      third_response = FactoryBot.create(:response, confidence: 70)
      FactoryBot.create(:judgement, prediction: third_response.prediction, outcome: 1)
      FactoryBot.create(:response, confidence: nil)
      FactoryBot.create(:judgement, prediction: first_response.prediction, outcome: 1)
      FactoryBot.create(:response, confidence: 80)
    end

    it 'creates all intervals' do
      expect(stats.headings).to eq %w[50% 60% 70% 80% 90% 100%]
    end

    it 'has correct accuracies' do
      expect(stats.accuracies).to eq [100, 100, 100, 0, 0, 67]
    end

    it 'has correct sample sizes' do
      expect(stats.sizes).to eq [1, 1, 1, 0, 0, 3]
    end
  end
end

describe Statistics::Interval do
  describe 'initialization and update' do
    let(:interval) { described_class.new(80) }

    before do
      interval.update([80, 491, 0.4921])
    end

    describe 'heading' do
      it 'is descriptive of the range' do
        expect(interval.heading).to eq '80%'
      end
    end

    describe 'count' do
      # TODO: make these not depend on indecipherable setup code
      it 'equals the argument' do
        expect(interval.count).to eq 491
      end
    end

    describe 'accuracy' do
      it 'equals the argument' do
        expect(interval.accuracy).to eq 49
      end
    end
  end
end
