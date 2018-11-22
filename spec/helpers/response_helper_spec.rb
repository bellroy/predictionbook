# frozen_string_literal: true

require 'spec_helper'

describe ResponseHelper do
  include described_class

  describe '#comment_for' do
    subject { comment_for(response) }

    let(:response) { Response.new(comment: comment) }

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
