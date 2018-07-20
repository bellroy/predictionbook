# encoding: utf-8

require 'spec_helper'

describe Response do
  it 'should belong to a prediction' do
    expect(Response.new).to respond_to(:prediction)
  end
  it 'has a user association that is initially nil' do
    expect(Response.new.user).to be_nil
  end

  it 'has a confidence attribute that is initially nil' do
    expect(Response.new.confidence).to be_nil
  end

  it 'should store an empty confidence string "" as nil' do
    expect(Response.new(confidence: '').confidence).to be_nil
  end

  it 'has a comment attritute that is initially nil' do
    expect(Response.new.comment).to be_nil
  end

  describe 'finders' do
    describe 'recent' do
      before do
        @rs = Response
      end
      it 'calls rsort and public scopes' do
        expect(Response).to receive(:order).and_return(@rs)
        expect(Response).to receive(:visible_to_everyone).and_return(@rs)
        expect(Response).to receive(:limit).and_return(@rs)
        expect(Response.recent).to eq @rs
      end
    end

    describe 'wagers' do
      it 'returns responses with confidences' do
        with_confidence_0 = FactoryBot.create(:response, confidence: 0)
        with_confidence_50 = FactoryBot.create(:response, confidence: 50)
        with_confidence_100 = FactoryBot.create(:response, confidence: 100)
        without_confidence = FactoryBot.create(:response, confidence: nil)
        expect(Response.wagers).to include(with_confidence_0)
        expect(Response.wagers).to include(with_confidence_50)
        expect(Response.wagers).to include(with_confidence_100)
        expect(Response.wagers).to_not include(without_confidence)
      end

      describe 'confidence aggregation' do
        before(:each) do
          @wagers = Response.wagers
        end

        it 'returns nil if there are no wagers' do
          expect(@wagers).to receive(:count).and_return 0
          expect(@wagers.mean_confidence).to be_nil
        end

        describe 'when not empty' do
          before do
            allow(@wagers).to receive(:count).and_return 1
          end

          it 'should calculate the mean of all wager confidences as mean_confidence' do
            expect(@wagers).to receive(:average).and_return(30.0)
            @wagers.mean_confidence
          end

          it 'should convert the mean to an integer' do
            expect(@wagers).to receive(:average).and_return(51.3)
            expect(@wagers.mean_confidence).to eq 51
          end

          it 'should round the mean' do
            expect(@wagers).to receive(:average).and_return(51.8)
            expect(@wagers.mean_confidence).to eq 52
          end
        end
      end
    end
  end

  describe 'relative confidence' do
    it 'is same as confidence if agrees' do
      response = Response.new(confidence: 70)
      expect(response).to receive(:agree?).and_return(true)
      expect(response.relative_confidence).to eq 70
    end
    it 'is inverted condidence if disagree' do
      response = Response.new(confidence: 70)
      expect(response).to receive(:agree?).and_return(false)
      expect(response.relative_confidence).to eq 30
    end
    it 'is nil when confidence is nil' do
      expect(Response.new(confidence: nil).relative_confidence).to be_nil
    end
  end

  describe 'correctness' do
    before(:each) do
      @prediction = Prediction.new
      @response = Response.new(prediction: @prediction)
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
      before(:each) do
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

    it 'should validate belong to a prediction' do
      @attributes = { prediction: nil }
      expect(errors[:prediction].length).to eq 1
    end

    it 'requires a name' do
      @attributes = { user: nil }
      expect(errors[:user].length).to eq 1
    end

    it 'should not require a confidence' do
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

    it 'should limit comments to 250 characters' do
      @attributes = { comment: 'A' * 251 }
      expect(errors[:comment].length).to eq 1
    end

    it 'should allow html that would still display less than 250 characters' do
      @attributes = { comment: %(A "link":http://www.google.com/#{'a' * 251}) }
      expect(errors[:comment]).to be_empty
    end

    it 'requires either a confidence or a comment' do
      @attributes = { comment: nil, confidence: nil }
      expect(response).to_not be_valid
    end

    it 'should allow nil comments' do
      @attributes = { comment: nil }
      expect(response).to be_valid
    end
  end

  describe 'comment?' do
    let(:response) { Response.new(comment: comment) }
    subject { response.comment? }

    context 'blank comment' do
      let(:comment) { '' }
      it { is_expected.to be false }
    end

    context 'comment exists' do
      let(:comment) { 'smelly' }
      it { is_expected.to be true }
    end
  end

  describe 'comment' do
    it 'returns nil of comment is nil' do
      expect(Response.new(comment: nil).comment).to be_nil
    end
    describe 'text only' do
      it 'should remove html tags' do
        expect(Response.new(comment: '"link":http://google.com').text_only_comment).to eq 'link'
      end
    end
    describe 'when not nil' do
      before(:each) do
        @comment = ' a silly comment! '
        @response = Response.new(comment: @comment)
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
        it 'should make the comment a clean cloth' do
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
      it 'should not agree' do
        @response = Response.new(confidence: 45)
        expect(@response.agree?).to be false
      end
    end

    describe 'confidence is > 50' do
      it 'should agree' do
        @response = Response.new(confidence: 80)
        expect(@response.agree?).to be true
      end
    end

    describe 'confidence is 50' do
      it 'should agree' do
        expect(Response.new(confidence: 80).agree?).to be true
      end
    end

    describe 'confidence is nil' do
      it 'should agree' do
        expect(Response.new(confidence: nil).agree?).to be true
      end
    end
  end
end
