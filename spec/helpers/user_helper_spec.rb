# frozen_string_literal: true

require 'spec_helper'

describe UserHelper do
  include described_class

  describe '#tag_name_options' do
    let(:duplicative_prediction) do
      FactoryBot.build(:prediction, creator: user).tap do |prediction|
        prediction.tag_names << "esportes"
        prediction.save
      end
    end
    let(:other_prediction) do
      FactoryBot.build(:prediction).tap do |prediction|
        prediction.tag_names << "ciência"
        prediction.save
      end
    end
    let(:prediction) do
      FactoryBot.build(:prediction, creator: user).tap do |prediction|
        prediction.tag_names << "esportes"
        prediction.save
      end
    end
    let(:user) { create(:user) }

    it 'returns the tag names' do
      prediction
      expect(helper.tag_name_options(user)).to include("esportes")
    end

    it "doesn't return tag names associated with predictions the user hasn't interacted with" do
      prediction && other_prediction
      expect(helper.tag_name_options(user)).to_not include("ciência")
    end

    it "lists each tag name only once" do
      prediction && duplicative_prediction
      count = helper.tag_name_options(user).count { |name| name == "esportes" }
      expect(count).to eq(1)
    end
  end
end
