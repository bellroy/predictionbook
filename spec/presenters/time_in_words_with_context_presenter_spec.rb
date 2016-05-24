require 'spec_helper'

describe TimeInWordsWithContextPresenter do
  let(:presenter) { described_class.new(time) }

  describe '#format' do
    subject { presenter.format }

    context 'two days from now' do
      let(:time) { 2.days.from_now }
      it { is_expected.to eq 'in 2 days' }
    end

    context '3 weeks ago' do
      let(:time) { 3.weeks.ago }
      it { is_expected.to eq '21 days ago' }
    end

    context 'more than a month ago' do
      let(:time) { 2.months.ago }
      it { is_expected.to match(/on [0-9]{4}-[0-9]{2}-[0-9]{2}/) }
    end
  end
end
