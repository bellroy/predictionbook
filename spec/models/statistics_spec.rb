require 'spec_helper'

describe Statistics do
  describe 'initialization' do
    let(:stats) { Statistics.new }

    before :each do
      first_response = FactoryGirl.create(:response, confidence: 50)
      FactoryGirl.create(:judgement, prediction: first_response.prediction, outcome: 0)
      second_response = FactoryGirl.create(:response, confidence: 40)
      FactoryGirl.create(:judgement, prediction: second_response.prediction, outcome: 0)
      third_response = FactoryGirl.create(:response, confidence: 70)
      FactoryGirl.create(:judgement, prediction: third_response.prediction, outcome: 1)
      FactoryGirl.create(:response, confidence: nil)
      FactoryGirl.create(:judgement, prediction: first_response.prediction, outcome: 1)
      FactoryGirl.create(:response, confidence: 80)
    end

    it 'creates all intervals' do
      expect(stats.headings).to eq ['50%', '60%', '70%', '80%', '90%', '100%']
    end

    it 'should have correct accuracies' do
      expect(stats.accuracies).to eq [100, 100, 100, 0, 0, 67]
    end

    it 'should have correct sample sizes' do
      expect(stats.sizes).to eq [1, 1, 1, 0, 0, 3]
    end
  end
end

describe Statistics::Interval do
  describe 'initialization and update' do
    let(:interval) { Statistics::Interval.new(80) }

    before(:each) do
      interval.update([80, 491, 0.4921])
    end

    describe 'heading' do
      it 'is descriptive of the range' do
        expect(interval.heading).to eq '80%'
      end
    end
    describe 'count' do
      # TODO: make these not depend on indecipherable setup code
      it 'should equal the argument' do
        expect(interval.count).to eq 491
      end
    end
    describe 'accuracy' do
      it 'should equal the argument' do
        expect(interval.accuracy).to eq 49
      end
    end
  end
end
