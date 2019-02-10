# frozen_string_literal: true

require 'spec_helper'

describe ScoreCalculator do
  let(:user) { FactoryBot.create(:user) }
  let(:today) { Time.zone.today }
  let(:calculator) do
    described_class.new(user, start_date: 3.months.ago.to_date, interval: 1.month)
  end
  let(:default_score) { { score: 1, count: 0, error: 0 } }

  describe '.score' do
    subject { calculator.score }

    context 'without any wagers' do
      let(:wagers) { Response.none }

      it { is_expected.to eq(1) }
    end

    context 'with a wager on an unjudged prediction' do
      let(:wager) { FactoryBot.create(:response, confidence: 50, user: user) }
      let(:wagers) { wager.user.wagers }
      let(:judgment) do
        FactoryBot.create(
          :judgement,
          prediction: wager.prediction,
          outcome: nil
        )
      end

      it { is_expected.to eq(1) }
    end

    context 'with a wager on a judged prediction' do
      let(:wager) do
        FactoryBot.create(:response, confidence: 80, user: user, created_at: 1.day.ago)
      end
      let(:wagers) { wager.user.wagers }

      before do
        FactoryBot.create(
          :judgement,
          prediction: wager.prediction,
          outcome: 'right'
        )
      end

      it { is_expected.to eq(0.04) }
    end

    context 'with a 100% wager on a judged prediction' do
      let(:wager) do
        FactoryBot.create(:response, confidence: 100, user: user, created_at: 1.day.ago)
      end
      let(:wagers) { wager.user.wagers }

      before do
        FactoryBot.create(
          :judgement,
          prediction: wager.prediction,
          outcome: 'right'
        )
      end

      it { is_expected.to eq(0) }
    end

    context 'with multiple wagers on judged predictions' do
      let(:first_wager) do
        FactoryBot.create(:response, confidence: 90, user: user, created_at: 1.day.ago)
      end
      let(:second_wager) do
        FactoryBot.create(:response, confidence: 70, user: user, created_at: 1.day.ago)
      end
      let(:third_wager) do
        FactoryBot.create(:response, confidence: 30, user: user, created_at: 1.day.ago)
      end

      before do
        FactoryBot.create(
          :judgement,
          prediction: first_wager.prediction,
          outcome: 'wrong'
        )
        FactoryBot.create(
          :judgement,
          prediction: second_wager.prediction,
          outcome: 'right'
        )
        FactoryBot.create(
          :judgement,
          prediction: third_wager.prediction,
          outcome: 'wrong'
        )
      end

      it { is_expected.to eq(0.33) }
    end
  end

  describe '.time_series' do
    subject(:time_series) { calculator.time_series }

    context 'without any wagers' do
      let(:wagers) { Response.none }

      specify do
        expect(time_series).to eq(
          (today - 3.months) => default_score,
          (today - 2.months) => default_score,
          (today - 1.month) => default_score,
          today => default_score
        )
      end
    end

    context 'with a wager on an unjudged prediction' do
      let(:wager) { FactoryBot.create(:response, confidence: 50, user: user) }
      let(:wagers) { wager.user.wagers }

      before do
        FactoryBot.create(
          :judgement,
          prediction: wager.prediction,
          outcome: nil
        )
      end

      specify do
        expect(time_series).to eq(
          (today - 3.months) => default_score,
          (today - 2.months) => default_score,
          (today - 1.month) => default_score,
          today => default_score
        )
      end
    end

    context 'with a wager on a judged prediction' do
      let(:wager) do
        FactoryBot.create(:response, confidence: 80, user: user, created_at: 1.day.ago)
      end
      let(:wagers) { wager.user.wagers }

      before do
        FactoryBot.create(
          :judgement,
          prediction: wager.prediction,
          outcome: 'right'
        )
      end

      specify do
        expect(time_series).to eq(
          (today - 3.months) => default_score,
          (today - 2.months) => default_score,
          (today - 1.month) => default_score,
          today => { score: 0.04, count: 1, error: 1.0 }
        )
      end
    end

    context 'with multiple wagers on judged predictions' do
      let(:user) { FactoryBot.create(:user) }
      let(:first_wager) do
        FactoryBot.create(:response, confidence: 90, user: user, created_at: 2.months.ago)
      end
      let(:second_wager) do
        FactoryBot.create(:response, confidence: 70, user: user, created_at: 1.month.ago)
      end
      let(:third_wager) do
        FactoryBot.create(:response, confidence: 30, user: user, created_at: 24.hours.ago)
      end
      let(:wagers) { user.wagers }

      before do
        FactoryBot.create(
          :judgement,
          prediction: first_wager.prediction,
          outcome: 'wrong'
        )

        FactoryBot.create(
          :judgement,
          prediction: second_wager.prediction,
          outcome: 'right'
        )

        FactoryBot.create(
          :judgement,
          prediction: third_wager.prediction,
          outcome: 'wrong'
        )
      end

      specify do
        expect(time_series).to eq(
          (today - 3.months) => default_score,
          (today - 2.months) => { score: 0.81, count: 1, error: 1.0 },
          (today - 1.month) => { score: 0.45, count: 2, error: 0.7071 },
          today => { score: 0.33, count: 3, error: 0.5774 }
        )
      end
    end
  end
end
