require 'spec_helper'

describe TimeInContentTagPresenter do
  let(:presenter) { described_class.new(time, css_class) }

  describe '#tag' do
    let(:time) { Time.zone.local(2016, 5, 18, 17, 23) }
    let(:css_class) { 'thermonuclear' }

    before do
      expect_any_instance_of(TimeInWordsWithContextPresenter).to receive(:format).and_return('boyo')
    end

    subject { presenter.tag }

    specify do
      time_bit = '2016-05-18 17:23:00 UTC'
      expect(subject).to eq "<span title=\"#{time_bit}\" class=\"date thermonuclear\">boyo</span>"
    end
  end
end
