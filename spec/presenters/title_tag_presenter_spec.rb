require 'spec_helper'

describe TitleTagPresenter do
  let(:presenter) { described_class.new(text) }

  describe '#tag' do
    subject { presenter.tag }

    context 'encodes html' do
      let(:text) { "<a href='http://www.pbook.com'>test</a>" }
      it { is_expected.to eq '&lt;a href=&apos;http://www.pbook.com&apos;&gt;test&lt;/a&gt;' }
    end

    context 'encodes other symbols' do
      let(:text) { 'Prediction & Book' }
      it { is_expected.to eq 'Prediction &amp; Book' }
    end
  end
end
