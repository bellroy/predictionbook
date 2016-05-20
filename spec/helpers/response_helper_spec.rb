require 'spec_helper'

describe ResponseHelper do
  include ResponseHelper

  describe '#comment_for' do
    let(:response) { Response.new(comment: comment) }

    subject { comment_for(response) }

    context 'no comment' do
      let(:comment) { nil }
      it { is_expected.to be_nil }
    end

    describe 'has comment' do
      let(:comment) { 'comment' }

      before { allow(self).to receive(:markup).and_return(comment) }

      it { is_expected.not_to have_selector('span[class="action-comment"]') }

      describe 'action comment' do
        let(:comment) { '/me shakes head' }


        it { is_expected.to have_selector('span[class="action-comment"]', text: 'shakes head') }
      end
    end
  end
end
