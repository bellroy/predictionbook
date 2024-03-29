# frozen_string_literal: true

require 'spec_helper'

describe PredictionsQuery do
  describe '#call' do
    let(:creator) { FactoryBot.create(:user) }
    let(:covid_prediction) do
      FactoryBot.create(
        :prediction,
        creator: creator,
        deadline: 1.year.from_now,
	      tag_names: ['covid']
      )
    end
    let(:sports_prediction) do
      FactoryBot.create(
        :prediction,
        creator: creator,
        deadline: 1.year.from_now,
	      tag_names: ['sports']
      )
    end

    it 'returns only the specified tags' do
      covid_prediction && sports_prediction
      predictions = creator.predictions.not_withdrawn
      predictions = described_class.new(predictions: predictions, tag_names: ['covid']).call
      expect(predictions).to include(covid_prediction)
      expect(predictions).to_not include(sports_prediction)
    end

    it 'filters by status' do
      covid_prediction && sports_prediction
      covid_prediction.judge!(true, creator)
      query = described_class.new(predictions: creator.predictions.not_withdrawn, status: 'judged')
      predictions = query.call
      expect(predictions).to include(covid_prediction)
      expect(predictions).to_not include(sports_prediction)
    end
  end
end
