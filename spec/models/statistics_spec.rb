require 'spec_helper'

describe Statistics do
  describe 'initialization' do
    let(:stats) { Statistics.new }

    before :each do
      first_response = valid_response(confidence: 50)
      first_response.save!
      valid_judgement(prediction: first_response.prediction, outcome: 0).save!
      second_response = valid_response(confidence: 40)
      second_response.save!
      valid_judgement(prediction: second_response.prediction, outcome: 0).save!
      third_response = valid_response(confidence: 70)
      third_response.save!
      valid_judgement(prediction: third_response.prediction, outcome: 1).save!
      fourth_response = valid_response(confidence: nil)
      fourth_response.save!
      valid_judgement(prediction: first_response.prediction, outcome: 1).save!
      fifth_response = valid_response(confidence: 80)
      fifth_response.save!
    end

    it 'creates all intervals' do
      expect(stats.headings).to eq ["50%", "60%", "70%", "80%", "90%", "100%"]
    end

    it "should have correct accuracies" do
      expect(stats.accuracies).to eq [100, 100, 100, 0, 0, 67]
    end

    it "should have correct sample sizes" do
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
        interval.heading.should == '80%'
      end
    end
    describe 'count' do
      #TODO: make these not depend on indecipherable setup code
      it 'should equal the argument' do
        interval.count.should == 491
      end
    end
    describe 'accuracy' do
      it 'should equal the argument' do
        interval.accuracy.should == 49
      end
    end
  end
end
