# encoding: utf-8

require 'spec_helper'

describe Response do
  def described_type;Response;end
  include ModelFactory

  it 'should belong to a prediction' do
    Response.new.should respond_to(:prediction)
  end
  it 'should have a user association that is initially nil' do
    Response.new.user.should be_nil
  end

  it 'should have a confidence attribute that is initially nil' do
    Response.new.confidence.should be_nil
  end

  it 'should store an empty confidence string "" as nil' do
    Response.new(:confidence => '').confidence.should == nil
  end

  it 'should have a comment attritute that is initially nil' do
    Response.new.comment.should be_nil
  end

  describe 'finders' do
    it_should_behave_like 'model class with common scopes'

    describe '“limit” scope' do
      before(:each) do
        5.times{create_valid_response}
      end
      it 'should return specified collection size' do
        Response.limit(4).size.should == 4
      end
    end

    describe 'reverse ordering scope' do
      it 'should default to creation date order' do
        older = create_valid_response(:created_at => 2.years.ago)
        newest = create_valid_response
        Response.rsort.should contain_in_order([newest,older])
      end

      it 'should order according to optional first arg' do
        a = create_valid_response(:comment => 'aaaaaaartghhh')
        y = create_valid_response(:comment => 'yaaaaaahhh')

        Response.rsort(:comment).should contain_in_order([y, a])
      end
    end

    describe 'recent' do
      before do
        @rs = Response
      end
      it 'should call rsort and public scopes' do
        Response.should_receive(:rsort).and_return(@rs)
        Response.should_receive(:not_private).and_return(@rs)
        Response.recent.should == @rs
      end
    end

    describe 'wagers' do
      it 'should return responses with confidences' do
        with_confidence_0 = create_valid_response(:confidence => 0)
        with_confidence_50 = create_valid_response(:confidence => 50)
        with_confidence_100 = create_valid_response(:confidence => 100)
        without_confidence = create_valid_response(:confidence => nil)
        Response.wagers.should include(with_confidence_0)
        Response.wagers.should include(with_confidence_50)
        Response.wagers.should include(with_confidence_100)
        Response.wagers.should_not include(without_confidence)
      end

      describe 'confidence aggregation' do
        before(:each) do
          @wagers = Response.wagers
        end

        it 'should return nil if there are no wagers' do
          @wagers.should_receive(:empty?).and_return true
          @wagers.mean_confidence.should == nil
        end

        describe 'when not empty' do
          before do
            @wagers.stub(:empty?).and_return false
          end

          it 'should calculate the mean of all wager confidences as mean_confidence' do
            @wagers.should_receive(:average).and_return(30.0)
            @wagers.mean_confidence
          end

          it 'should convert the mean to an integer' do
            @wagers.stub(:average).and_return(51.3)
            @wagers.mean_confidence.should == 51
          end

          it 'should round the mean' do
            @wagers.stub(:average).and_return(51.8)
            @wagers.mean_confidence.should == 52
          end
        end
      end

      describe 'statistics' do
        it 'should have a "statistics" collection' do
          #HACK: respond_to? bug workaraound, fix in rails > August 13, 2008
          # Response.wagers.should respond_to(:statistics)
          expect {Response.wagers.statistics}.not_to raise_error
        end
        it 'should be a conversion of wagers into Statistics' do
          wagers = Response.wagers
          Statistics.should_receive(:new).with(wagers)

          wagers.statistics
        end
        it 'should return the new Statistics collection' do
          stats = double('statistics')
          Statistics.stub(:new).and_return(stats)

          Response.wagers.statistics.should ==  stats
        end
      end
    end
  end

  describe 'relative confidence' do
    it 'should be same as confidence if agrees' do
      response = Response.new(:confidence => 70)
      response.stub(:agree?).and_return(true)
      response.relative_confidence.should == 70
    end
    it 'should be inverted condidence if disagree' do
      response = Response.new(:confidence => 70)
      response.stub(:agree?).and_return(false)
      response.relative_confidence.should == 30
    end
    it 'should be nil when confidence is nil' do
      Response.new(:confidence => nil).relative_confidence.should be_nil
    end
  end

  describe 'correctness' do
    before(:each) do
      @prediction = Prediction.new
      @response = Response.new(:prediction => @prediction)
    end
    it 'should ask prediction if it is known' do
      @prediction.should_receive(:unknown?).and_return(true)
      @response.correct?
    end
    it 'should be nil if prediction is unknown' do
      @prediction.stub(:unknown?).and_return(true)
      @response.correct?.should be_nil
    end
    describe 'when prediction is known' do
      before(:each) do
        @prediction.stub(:unknown?).and_return(false)
      end
      it 'should ask itself if it agrees with the prediction' do
        @response.should_receive(:agree?)
        @response.correct?
      end
      it 'should be true if prediction is right and response agrees' do
        @prediction.stub(:right?).and_return(true)
        @response.stub(:agree?).and_return(true)
        @response.correct?.should be true
      end
      it 'should be false if prediction is right and response does not agree' do
        @prediction.stub(:right?).and_return(true)
        @response.stub(:agree?).and_return(false)
        @response.correct?.should be false
      end
      it 'should be false if prediction is not right and response agrees' do
        @prediction.stub(:right?).and_return(false)
        @response.stub(:agree?).and_return(true)
        @response.correct?.should be false
      end
      it 'should be true if prediction is not right and response does not agree' do
        @prediction.stub(:right?).and_return(false)
        @response.stub(:agree?).and_return(false)
        @response.correct?.should be true
      end
    end
  end

  describe 'validations' do
    let(:response) { valid_response(@attributes) }
    let(:errors) { response.valid?; response.errors }

    it 'should validate belong to a prediction' do
      @attributes = { prediction: nil }
      expect(errors[:prediction].length).to eq 1
    end

    it 'should require a name' do
      @attributes = { user: nil }
      expect(errors[:user].length).to eq 1
    end

    it 'should not require a confidence' do
      @attributes = { confidence: nil }
      expect(errors[:confidence]).to be_empty
    end

    it 'should require the prediction have an unknown outcome when submitting confidence' do
      @attributes = {}
      response.prediction = mock_model(Prediction, :unknown? => false)
      expect(errors[:prediction].length).to eq 1
    end

    it 'should require the confidence to be <= 100' do
      @attributes =  { confidence: '101' }
      expect(errors[:confidence].length).to eq 1
    end

    it 'should require the confidence to be >= 0' do
      @attributes = { :confidence => '-4' }
      expect(errors[:confidence].length).to eq 1
    end

    it 'should have no error on prediction if prediciton has unknown outcome' do
      @attributes = {}
      response.prediction = mock_model(Prediction, :unknown? => true)
      expect(errors[:prediction]).to be_empty
    end

    it 'should have no error on prediction when submitting comment only' do
      @attributes = { confidence: nil }
      response.prediction = mock_model(Prediction, :unknown? => false)
      response.should be_valid
    end

    it 'should limit comments to 250 characters' do
      @attributes = { comment: "A" * 251 }
      expect(errors[:comment].length).to eq 1
    end

    it 'should allow html that would still display less than 250 characters' do
      @attributes = { comment: %Q{A "link":http://www.google.com/#{'a' * 251}} }
      expect(errors[:comment]).to be_empty
    end

    it 'should require either a confidence or a comment' do
      @attributes = {comment: nil, confidence: nil}
      response.should_not be_valid
    end

    it 'should allow nil comments' do
      @attributes = { comment: nil }
      response.should be_valid
    end
  end

  describe 'comment?' do
    before(:each) do
      @response = Response.new(:comment => @comment = double('comment'))
    end
    it 'should ask the comment if it is blank' do
      @comment.should_receive(:blank?)

      @response.comment?
    end
    it 'should be false if comment is blank' do
      @comment.stub(:blank?).and_return true

      @response.comment?.should be false
    end
    it 'should be true if comment is not blank' do
      @comment.stub(:blank?).and_return false

      @response.comment?.should be true
    end
  end

  describe 'comment' do
    it 'should return nil of comment is nil' do
      Response.new(:comment => nil).comment.should == nil
    end
    describe 'text only' do
      it 'should remove html tags' do
        Response.new(:comment => '"link":http://google.com').text_only_comment.should == 'link'
      end
    end
    describe 'when not nil' do
      before(:each) do
        @comment = ' a silly comment! '
        @response = Response.new(:comment => @comment)
      end
      it 'should return the comment' do
        @response.comment.should == @comment
      end
      it 'should be a string' do
        @response.comment.should be_kind_of(String)
      end
      it 'should respond to to_html' do
        @response.comment.respond_to?(:to_html).should be true
      end
      describe 'action comment?' do
        it 'should be false if starts with /me but nothing else' do
          @response.comment = '/me      '
          @response.action_comment?.should be false
        end
        it 'should be false if does not start with /me' do
          @response.comment = 'me is actionable'
          @response.action_comment?.should be false
        end
        it 'should be true if starts with /me and has other stuff' do
          @response.comment = '/me  is action'
          @response.action_comment?.should be true
        end
        describe 'is true' do
          before(:each) do
            @response.stub(:action_comment?).and_return(true)
          end
          describe 'action comment' do
            it 'should return the comment with /me removed and stripped' do
              @response.comment = '/me     is the best'
              @response.action_comment.should == "is the best"
            end
          end
        end
      end
      describe 'to html' do
        it 'should make the comment a clean cloth' do
          CleanCloth.should_receive(:new).with(@comment)

          @response.comment
        end
        it 'should return the clean clothed comment' do
          CleanCloth.stub(:new).and_return(:comment)

          @response.comment.should == :comment
        end
      end
    end
  end

  describe 'agreement' do
    describe 'confidence is < 50' do
      it 'should not agree' do
        @response = Response.new(:confidence => 45)
        @response.agree?.should be false
      end
    end
    describe 'confidence is > 50' do
      it 'should agree' do
        @response = Response.new(:confidence => 80)
        @response.agree?.should be true
      end
    end
    describe 'confidence is 50' do
      it 'should agree' do
        Response.new(:confidence => 80).agree?.should be true
      end
    end
    describe 'confidence is nil' do
      it 'should agree' do
        Response.new(:confidence => nil).agree?.should be true
      end
    end
  end

end
