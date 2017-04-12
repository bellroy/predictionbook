require 'spec_helper'

describe PredictionVersion do
  describe '.create_from_current_prediction_if_required' do
    subject(:create) { PredictionVersion.create_from_current_prediction_if_required(prediction) }

    context 'prediction has not changed' do
      let!(:prediction) { FactoryGirl.create(:prediction) }
      specify { expect { create }.not_to change { prediction.versions.length } }
    end

    context 'prediction is new' do
      let(:user) { FactoryGirl.create(:user) }
      let!(:prediction) do
        FactoryGirl.build(:prediction, description: 'A description', deadline: Date.yesterday,
                                       creator: user, uuid: 'uuid1', withdrawn: true)
      end

      specify do
        create
        version = prediction.versions.first
        expect(prediction.version).to eq 1
        expect(version.version).to eq 1
        expect(version.description).to eq 'A description'
        expect(version.deadline).to eq Date.yesterday
        expect(version.withdrawn).to be true
        expect(version.visibility).to eq 'visible_to_everyone'
      end
    end
  end

  describe '#previous_version' do
    let(:prediction) { FactoryGirl.create(:prediction, description: 'old description') }
    let(:most_recent_version) { prediction.versions.last }

    subject(:previous_version) { most_recent_version.previous_version }

    specify do
      prediction.update_attributes(description: 'new description')
      expect(most_recent_version.description).to eq 'new description'
      expect(previous_version.description).to eq 'old description'
    end
  end
end
