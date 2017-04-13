require 'spec_helper'

describe VersionHelper do
  include VersionHelper

  describe 'changes' do
    let(:deadline) { Time.zone.now.to_s }
    let(:attributes_before) { { 'deadline' => deadline, 'withdrawn' => 'true' } }
    let(:first_version) { instance_double(PredictionVersion, attributes: attributes_before) }
    let(:attributes_now) { { 'deadline' => deadline, 'withdrawn' => 'false' } }
    let(:second_version) do
      instance_double(PredictionVersion, previous_version: first_version, attributes: attributes_now)
    end

    subject { changes(second_version) }

    it { is_expected.to include('withdrew the prediction') }
    it { is_expected.not_to include('deadline') }
  end

  describe 'changed_detail' do
    subject { changed_detail(field, new_value, old_value) }

    context 'changed description' do
      let(:field) { :description }
      let(:new_value) { 'new desc' }
      let(:old_value) { 'old desc' }
      it { is_expected.to match(/changed their prediction from.*old desc.*/) }
    end

    context 'changed deadline' do
      let(:field) { :deadline }
      let(:new_value) { 10.minutes.from_now }
      let(:old_value) { 40.minutes.ago }
      it { is_expected.to match(/changed the deadline from.+40 minutes ago.*/) }
    end

    context 'withdrew prediction' do
      let(:field) { :withdrawn }
      let(:new_value) { true }
      let(:old_value) { false }
      it { is_expected.to eq 'withdrew the prediction' }
    end

    context 'visibility is changing' do
      let(:field) { :visibility }
      let(:old_value) { 0 }

      context 'made private' do
        let(:new_value) { 1 }
        it { is_expected.to eq 'made the prediction visible to creator' }
      end

      context 'made visible to group' do
        let(:new_value) { 2 }
        it { is_expected.to eq 'made the prediction visible to group' }
      end
    end
  end
end
