# frozen_string_literal: true

require 'spec_helper'

describe PredictionFilter do
  describe '.filter' do
    let(:creator) { FactoryBot.create(:user, api_token: 'creator-token') }
    # let(:visitor) { FactoryBot.create(:user, apt_token: 'visitor-token') }

    before do
      # TODO: make filtering include private predictions

      FactoryBot.create_list(
        :prediction,
        11,
        creator: creator,
        deadline: 1.year.from_now
      )

      FactoryBot.create_list(
        :prediction,
        5,
        creator: creator,
        deadline: 2.days.ago
      )

      judged =
        FactoryBot.create_list(
          :prediction,
          7,
          creator: creator,
          deadline: 2.days.ago
        )

      judged.each { |pred| pred.judge!([true, false].sample, creator) }
    end

    it 'expects predictions to exist' do
      expect(Prediction.where(creator: creator).count).to eq(23)
    end

    it "filters the user's own judged predictions" do
      predictions = described_class.filter(creator, creator, 'judged', 1)
      expect(predictions.count).to eq(7)
    end

    it "filters the user's own unjudged predictions" do
      predictions = described_class.filter(creator, creator, 'unjudged', 1)
      expect(predictions.count).to eq(5)
    end

    it "filters the user's own future predictions" do
      predictions = described_class.filter(creator, creator, 'future', 1)
      expect(predictions.count).to eq(11)
    end

    it 'can give all predictions' do
      predictions = described_class.filter(creator, creator, 'all predictions', 1)
      expect(predictions.count).to eq(23)
    end
  end
end
