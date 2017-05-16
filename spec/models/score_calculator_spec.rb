require 'spec_helper'

describe ScoreCalculator do
  let(:user) { FactoryGirl.create(:user) }
  let(:calculator) { described_class.new(user) }

  describe '.calculate' do
    subject { calculator.calculate }

    context 'without any wagers' do
      let(:wagers) { Response.none }

      it { is_expected.to eq(1) }
    end

    context 'with a wager on an unjudged prediction' do
      let!(:wager) { FactoryGirl.create(:response, confidence: 50, user: user) }
      let!(:judgment) do
        FactoryGirl.create(
          :judgement,
          prediction: wager.prediction,
          outcome: nil
        )
      end
      let!(:wagers) { wager.user.wagers }

      it { is_expected.to eq(1) }
    end

    context 'with a wager on a judged prediction' do
      let!(:wager) { FactoryGirl.create(:response, confidence: 80, user: user) }
      let!(:judgment) do
        FactoryGirl.create(
          :judgement,
          prediction: wager.prediction,
          outcome: 'right'
        )
      end
      let!(:wagers) { wager.user.wagers }

      it { is_expected.to eq(3.11) }
    end

    context 'with multiple wagers on judged predictions' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:first_wager) do
        FactoryGirl.create(:response, confidence: 90, user: user)
      end
      let!(:first_judgment) do
        FactoryGirl.create(
          :judgement,
          prediction: first_wager.prediction,
          outcome: 'wrong'
        )
      end
      let!(:second_wager) do
        FactoryGirl.create(:response, confidence: 70, user: user)
      end
      let!(:second_judgment) do
        FactoryGirl.create(
          :judgement,
          prediction: second_wager.prediction,
          outcome: 'right'
        )
      end
      let!(:third_wager) do
        FactoryGirl.create(:response, confidence: 30, user: user)
      end
      let!(:third_judgment) do
        FactoryGirl.create(
          :judgement,
          prediction: third_wager.prediction,
          outcome: 'wrong'
        )
      end
      let!(:wagers) { user.wagers }

      it { is_expected.to eq(0.69) }
    end
  end
end
