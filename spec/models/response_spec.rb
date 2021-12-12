# frozen_string_literal: true

require 'spec_helper'

describe Response do
  it 'belongs to a prediction' do
    expect(described_class.new).to respond_to(:prediction)
  end
  it 'has a user association that is initially nil' do
    expect(described_class.new.user).to be_nil
  end

  it 'has a confidence attribute that is initially nil' do
    expect(described_class.new.confidence).to be_nil
  end

  it 'stores an empty confidence string "" as nil' do
    expect(described_class.new(confidence: '').confidence).to be_nil
  end

  it 'has a comment attritute that is initially nil' do
    expect(described_class.new.comment).to be_nil
  end

  describe 'finders' do
    describe 'recent' do
      before do
        @rs = described_class
      end

      it 'calls rsort and public scopes' do
        expect(described_class).to receive(:order).and_return(@rs)
        expect(described_class).to receive(:visible_to_everyone).and_return(@rs)
        expect(described_class).to receive(:limit).and_return(@rs)
        expect(described_class.recent).to eq @rs
      end
    end

    describe 'wagers' do
      it 'returns responses with confidences' do
        with_confidence_0 = FactoryBot.create(:response, confidence: 0)
        with_confidence_50 = FactoryBot.create(:response, confidence: 50)
        with_confidence_100 = FactoryBot.create(:response, confidence: 100)
        without_confidence = FactoryBot.create(:response, confidence: nil)
        expect(described_class.wagers).to include(with_confidence_0)
        expect(described_class.wagers).to include(with_confidence_50)
        expect(described_class.wagers).to include(with_confidence_100)
        expect(described_class.wagers).not_to include(without_confidence)
      end

      describe 'confidence aggregation' do
        before do
          @wagers = described_class.wagers
        end

        it 'returns nil if there are no wagers' do
          expect(@wagers).to receive(:count).and_return 0
          expect(@wagers.mean_confidence).to be_nil
        end

        describe 'when not empty' do
          before do
            allow(@wagers).to receive(:count).and_return 1
          end

          it 'calculates the mean of all wager confidences as mean_confidence' do
            expect(@wagers).to receive(:average).and_return(30.0)
            @wagers.mean_confidence
          end

          it 'converts the mean to an integer' do
            expect(@wagers).to receive(:average).and_return(51.3)
            expect(@wagers.mean_confidence).to eq 51
          end

          it 'rounds the mean' do
            expect(@wagers).to receive(:average).and_return(51.8)
            expect(@wagers.mean_confidence).to eq 52
          end
        end
      end
    end
  end

  describe 'relative confidence' do
    it 'is same as confidence if agrees' do
      response = described_class.new(confidence: 70)
      expect(response).to receive(:agree?).and_return(true)
      expect(response.relative_confidence).to eq 70
    end
    it 'is inverted condidence if disagree' do
      response = described_class.new(confidence: 70)
      expect(response).to receive(:agree?).and_return(false)
      expect(response.relative_confidence).to eq 30
    end
    it 'is nil when confidence is nil' do
      expect(described_class.new(confidence: nil).relative_confidence).to be_nil
    end
  end

  describe 'correctness' do
    before do
      @prediction = Prediction.new
      @response = described_class.new(prediction: @prediction)
    end

    it 'asks prediction if it is known' do
      expect(@prediction).to receive(:unknown?).and_return(true)
      @response.correct?
    end
    it 'is nil if prediction is unknown' do
      expect(@prediction).to receive(:unknown?).and_return(true)
      expect(@response.correct?).to be_nil
    end
    describe 'when prediction is known' do
      before do
        expect(@prediction).to receive(:unknown?).and_return(false)
      end

      it 'asks itself if it agrees with the prediction' do
        expect(@response).to receive(:agree?)
        @response.correct?
      end
      it 'is true if prediction is right and response agrees' do
        expect(@prediction).to receive(:right?).and_return(true)
        expect(@response).to receive(:agree?).and_return(true)
        expect(@response.correct?).to be true
      end
      it 'is false if prediction is right and response does not agree' do
        expect(@prediction).to receive(:right?).and_return(true)
        expect(@response).to receive(:agree?).and_return(false)
        expect(@response.correct?).to be false
      end
      it 'is false if prediction is not right and response agrees' do
        expect(@prediction).to receive(:right?).and_return(false)
        expect(@response).to receive(:agree?).and_return(true)
        expect(@response.correct?).to be false
      end
      it 'is true if prediction is not right and response does not agree' do
        expect(@prediction).to receive(:right?).and_return(false)
        expect(@response).to receive(:agree?).and_return(false)
        expect(@response.correct?).to be true
      end
    end
  end

  describe 'validations' do
    let(:response) { FactoryBot.build(:response, @attributes) }
    let(:errors) do
      response.valid?
      response.errors
    end

    it 'validates belong to a prediction' do
      @attributes = { prediction: nil }
      expect(errors[:prediction].length).to eq 1
    end

    it 'requires a name' do
      @attributes = { user: nil }
      expect(errors[:user].length).to eq 1
    end

    it 'does not require a confidence' do
      @attributes = { confidence: nil }
      expect(errors[:confidence]).to be_empty
    end

    it 'requires the prediction have an unknown outcome when submitting confidence' do
      @attributes = {}
      response.prediction = mock_model(Prediction, unknown?: false)
      expect(errors[:prediction].length).to eq 1
    end

    it 'requires the confidence to be <= 100' do
      @attributes = { confidence: '101' }
      expect(errors[:confidence].length).to eq 1
    end

    it 'requires the confidence to be >= 0' do
      @attributes = { confidence: '-4' }
      expect(errors[:confidence].length).to eq 1
    end

    it 'has no error on prediction if prediciton has unknown outcome' do
      @attributes = {}
      response.prediction = mock_model(Prediction, unknown?: true)
      expect(errors[:prediction]).to be_empty
    end

    it 'has no error on prediction when submitting comment only' do
      @attributes = { confidence: nil }
      response.prediction = mock_model(Prediction, unknown?: false)
      expect(response).to be_valid
    end

    it 'limits comments to 250 characters' do
      @attributes = { comment: 'A' * 251 }
      expect(errors[:comment].length).to eq 1
    end

    it 'allows html that would still display less than 250 characters' do
      @attributes = { comment: %(A "link":http://www.google.com/#{'a' * 251}) }
      expect(errors[:comment]).to be_empty
    end

    it 'requires either a confidence or a comment' do
      @attributes = { comment: nil, confidence: nil }
      expect(response).not_to be_valid
    end

    it 'allows nil comments' do
      @attributes = { comment: nil }
      expect(response).to be_valid
    end
  end

  describe 'comment?' do
    subject { response.comment? }

    let(:response) { described_class.new(comment: comment) }

    context 'blank comment' do
      let(:comment) { '' }

      it { is_expected.to be false }
    end

    context 'comment exists' do
      let(:comment) { 'smelly' }

      it { is_expected.to be true }
    end
  end

  describe '#comment' do
    it 'returns nil of comment is nil' do
      expect(described_class.new(comment: nil).comment).to be_nil
    end

    context 'when text only' do
      it 'removes html tags' do
        expect(described_class.new(comment: '"link":http://google.com').text_only_comment).to eq 'link'
      end

      context 'but contains hash tags' do
        let(:comment) { "Things are going to get bad #covid #pandemic" }
        let(:response) do
          FactoryBot.create(:response, comment: comment, prediction: prediction)
        end
        let(:prediction) { FactoryBot.create(:prediction) }

        it 'associates the prediction with the appropriate tags' do
          expect(prediction.tag_names).to be_empty
          response
          expect(prediction.reload.tag_names).to include('covid', 'pandemic')
        end
      end
    end

    describe 'when not nil' do
      before do
        @comment = ' a silly comment! '
        @response = described_class.new(comment: @comment)
      end

      it 'returns the comment' do
        expect(@response.comment).to eq @comment
      end

      it 'is a string' do
        expect(@response.comment).to be_kind_of(String)
      end

      it 'responds to to_html' do
        expect(@response.comment.respond_to?(:to_html)).to be true
      end

      describe 'action comment?' do
        it 'is false if starts with /me but nothing else' do
          @response.comment = '/me      '
          expect(@response.action_comment?).to be false
        end

        it 'is false if does not start with /me' do
          @response.comment = 'me is actionable'
          expect(@response.action_comment?).to be false
        end

        it 'is true if starts with /me and has other stuff' do
          @response.comment = '/me  is action'
          expect(@response.action_comment?).to be true
        end

        describe 'is true' do
          describe 'action comment' do
            it 'returns the comment with /me removed and stripped' do
              @response.comment = '/me     is the best'
              expect(@response.action_comment).to eq 'is the best'
            end
          end
        end
      end

      describe 'to html' do
        it 'makes the comment a clean cloth' do
          expect(CleanCloth).to receive(:new).with(@comment)

          @response.comment
        end
        it 'returns the clean clothed comment' do
          expect(CleanCloth).to receive(:new).and_return(:comment)

          expect(@response.comment).to eq :comment
        end
      end
    end
  end

  describe 'agreement' do
    describe 'confidence is < 50' do
      it 'does not agree' do
        @response = described_class.new(confidence: 45)
        expect(@response.agree?).to be false
      end
    end

    describe 'confidence is > 50' do
      it 'agrees' do
        @response = described_class.new(confidence: 80)
        expect(@response.agree?).to be true
      end
    end

    describe 'confidence is 50' do
      it 'agrees' do
        expect(described_class.new(confidence: 80).agree?).to be true
      end
    end

    describe 'confidence is nil' do
      it 'agrees' do
        expect(described_class.new(confidence: nil).agree?).to be true
      end
    end
  end
end
