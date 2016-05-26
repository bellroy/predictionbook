require 'spec_helper'

describe TitleTagPresenter do
  let(:presenter) { described_class.new(text) }

  describe '#tag' do
    subject { presenter.tag }

    context 'encodes html' do
      let(:text) { "<a href='http://www.pbook.com'>test</a>" }
      it { is_expected.to eq '&lt;a href=\'http://www.pbook.com\'&gt;test&lt;/a&gt;' }
    end

    context 'encodes other symbols' do
      let(:text) { 'Prediction & Book' }
      it { is_expected.to eq 'Prediction &amp; Book' }
    end

    context 'adds strong and em' do
      let(:text) { '*This is bold* and _this is an em_' }
      it { is_expected.to eq '<strong>This is bold</strong> and <em>this is an em</em>' }
    end
  end
end
