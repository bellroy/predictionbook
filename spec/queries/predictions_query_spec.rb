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
      predictions = described_class.new(creator: creator, tag_names: ['covid']).call
      expect(predictions).to include(covid_prediction)
      expect(predictions).to_not include(sports_prediction)
    end
  end
end
