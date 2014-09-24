require 'spec_helper'

describe Prediction do
  def described_type;Prediction;end
  include ModelFactory

  it 'should have a creator attribute that is initially nil' do
    Prediction.new.creator.should be_nil
  end

  it 'should have a description attribute that is initially nil' do
    Prediction.new.description.should be_nil
  end

  it 'should have an inital_confidence attribute that is nil initially' do
    Prediction.new.initial_confidence.should be_nil
    Prediction.new.should respond_to(:initial_confidence=)
  end

  describe 'validations' do
    describe 'with default values' do
      before(:each) do
        @prediction = Prediction.new
        @prediction.valid?
      end

      it 'should pass on objects from modelfactory' do
        valid_prediction.should be_valid
        create_valid_prediction.should be_valid
      end

      it 'should require a creator' do
        @prediction.valid?
        expect(@prediction.errors[:creator].length).to eq 1
      end

      it 'should require a deadline' do
        @prediction.valid?
        expect(@prediction.errors[:deadline].length).to eq 1
      end

      it 'should require a description' do
        @prediction.valid?
        expect(@prediction.errors[:description].length).to eq 1
      end
    end

    describe 'with invalid values' do
      it 'should not accept a deadline too far into the future to store' do
        date = 300000.years.from_now
        prediction = Prediction.new(:deadline => date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'should not accept a deadline too far in the past to store' do
        date = 300000.years.ago
        prediction = Prediction.new(:deadline => date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'should not accept an invalid deadline even after being created' do
        prediction = Prediction.new(:deadline => 2.months.from_now)
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 0
        prediction.deadline = 300000.years.from_now
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
    end
  end

  describe 'with uuid' do
    it 'should have a uuid attribute' do
      Prediction.new.should respond_to(:uuid)
    end

    def stub_uuid_create(string)
      uuid = UUID.parse(string)
      UUID.stub(:random_create).and_return(uuid)
    end

    it 'should set the UUID for a new record' do
      stub_uuid_create('21f7f8de-8051-5b89-8680-0195ef798b6a')
      Prediction.new.uuid.should == '21f7f8de-8051-5b89-8680-0195ef798b6a'
    end

    it 'should persist UUID set for the new record' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      prediction = valid_prediction
      prediction.uuid.should == '64a5189c-25b3-11da-a97b-00c04fd430c8'
      prediction.save!
      prediction.reload.uuid.should == '64a5189c-25b3-11da-a97b-00c04fd430c8'
    end

    it 'should allow write access to UUIDs on create' do
      prediction = create_valid_prediction(:uuid => '21f7f8de-8051-5b89-8680-0195ef798b6a')
      prediction.uuid.should == '21f7f8de-8051-5b89-8680-0195ef798b6a'
    end

    it 'should not allow write access to UUIDs loaded from DB' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      prediction = create_valid_prediction
      prediction.update_attributes! :uuid => 'other uuid'
      prediction.reload.uuid.should == '64a5189c-25b3-11da-a97b-00c04fd430c8'
    end

    it 'should raise DuplicateRecord on create if there is a record with that UUID already' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      create_valid_prediction
      lambda {create_valid_prediction}.should raise_error(Prediction::DuplicateRecord)
    end

  end

  describe "associations" do
    it { should have_many(:deadline_notifications).dependent(:destroy) }
    it { should have_many(:response_notifications).dependent(:destroy) }
    it { should have_many(:judgements).dependent(:destroy) }
    it { should have_many(:responses).dependent(:destroy) }
    it { should respond_to(:wagers) }
  end

  describe 'with responses' do
    describe 'initial response creation' do
      it 'should build a response before validation' do
        p = Prediction.new
        p.valid?
        p.responses.length.should eq 1
      end



      it 'should assign response user from creator' do
        u = User.new
        p = Prediction.new(:creator => u)
        p.valid?
        p.responses.first.user.should == u
      end

      it 'should assign initial confidence from passed value' do
        p = Prediction.new(:initial_confidence => 50)
        p.valid?
        p.responses.first.confidence.should == 50
      end
    end
  end

  describe '#judgement' do
    it 'should return most recent judgement' do
      prediction = create_valid_prediction
      prediction.judge!(:right)
      prediction.judge!(:wrong)
      prediction.judgement.outcome.should == false
      prediction.should be_wrong
    end
    it 'should return nil if no judgements' do
      create_valid_prediction.judgement.should be_nil
    end
  end

  describe '#judged_at' do
    it 'should return when judgement occured' do
      prediction = create_valid_prediction

      judged_at = 15.minutes.from_now
      Time.stub(:now).and_return(judged_at)
      prediction.judge!(:right)

      prediction.judged_at.should == judged_at
    end
  end

  describe 'finders and scopes' do
    it_should_behave_like 'model class with common scopes'

    before do
      Prediction.destroy_all
    end

    it 'should have a finder for the most recent predictions' do
      prediction1 = create_valid_prediction(:created_at => 2.weeks.ago)
      prediction2 = create_valid_prediction
      Prediction.recent.should == [prediction2, prediction1]
    end

    describe 'popular predictions' do

      it "should have a finder for recent popular predictions" do
        prediction1 = create_valid_prediction(:created_at => 1.week.ago, :deadline => 4.days.from_now)
        create_valid_response(:prediction => prediction1)
        prediction2 = create_valid_prediction(:created_at => 2.days.ago, :deadline => 2.days.from_now)
        prediction3 = create_valid_prediction(:created_at => 1.week.ago, :deadline => 3.days.from_now)
        create_valid_response(:prediction => prediction3)
        create_valid_response(:prediction => prediction3)
        prediction4 = create_valid_prediction(:created_at => 1.day.ago, :deadline => 1.day.from_now)
        Prediction.popular.should == [prediction3, prediction1, prediction4, prediction2]
      end

      it "excludes overdue predictions" do
        prediction1 = create_valid_prediction(:created_at => 1.week.ago, :deadline => 1.day.ago)
        prediction2 = create_valid_prediction(:created_at => 1.week.ago, :deadline => 1.day.from_now)
        Prediction.popular.should == [prediction2]
      end

      it "excludes judged (known) predictions" do
        prediction1 = create_valid_prediction(:created_at => 1.week.ago, :deadline => 1.day.from_now)
        create_valid_judgement(:prediction => prediction1, :outcome => false)
        prediction2 = create_valid_prediction(:created_at => 1.week.ago, :deadline => 1.day.from_now)
        Prediction.popular.should == [prediction2]
      end

      it "excludes predictions made more than 2 weeks ago" do
        create_valid_prediction(:created_at => 3.weeks.ago, :deadline => 1.day.from_now)
        create_valid_prediction(:created_at => 4.weeks.ago, :deadline => 2.days.from_now)
        create_valid_prediction(:created_at => 5.weeks.ago, :deadline => 3.days.from_now)
        Prediction.popular.should be_empty
      end

    end

    describe 'judged predictions' do
      it 'should order by most recently judged first' do
        first = create_valid_prediction
        last = create_valid_prediction

        first.judge!(:right)
        future = 10.minutes.from_now.time
        Time.stub(:now).and_return(future)
        last.judge!(:right)

        Prediction.judged.should == [last, first]
      end

      it 'should include judged predictions' do
        judged = create_valid_prediction
        judged.judge!(:right, nil)

        Prediction.judged.should == [judged]
      end

      it 'should not include unjudged predictions' do
        create_valid_prediction

        Prediction.judged.should == []
      end
    end

    describe 'for unjudged predictions' do
      it 'should not return judged predictions' do
        judged = create_valid_prediction
        judged.judge!(:right, nil)
        unjudged = create_valid_prediction

        Prediction.unjudged.should == [unjudged]
      end

      it 'should not return predictions whose deadline is in the future' do
        future = create_valid_prediction(:deadline => 2.years.from_now)
        past = create_valid_prediction(:deadline => 2.days.ago)

        Prediction.unjudged.should == [past]
      end

      it 'should order by deadline' do
        long_ago = create_valid_prediction(:deadline => 2.days.ago)
        longer_ago = create_valid_prediction(:deadline => 2.weeks.ago)

        Prediction.unjudged.should == [long_ago, longer_ago]
      end

      it 'should return currently unjudged predictions with previous judgements' do
        rejudged = create_valid_prediction
        rejudged.judge!(:right, nil)
        sleep 1 # second granularity on judgement created_at
        rejudged.judge!(nil, nil)

        Prediction.unjudged.should == [rejudged]
      end

      it 'should not return currently judged predictions with previous unknown judgements' do
        rejudged = create_valid_prediction
        rejudged.judge!(nil, nil)
        sleep 1 # second granularity on judgement created_at
        rejudged.judge!(:right, nil)

        Prediction.unjudged.should == []
      end
    end

    describe 'for future predictions' do
      it 'should not return judged predictions' do
        judged = create_valid_prediction(:deadline => 2.days.from_now)
        judged.judge!(:right, nil)
        unjudged = create_valid_prediction(:deadline => 2.days.from_now)

        Prediction.future.should == [unjudged]
      end

      it 'should not return predictions whose deadline is in the past' do
        future = create_valid_prediction(:deadline => 2.years.from_now)
        past = create_valid_prediction(:deadline => 2.days.ago)

        Prediction.future.should == [future]
      end

      it 'should order by ascending deadline' do
        further = create_valid_prediction(:deadline => 2.weeks.from_now)
        sooner = create_valid_prediction(:deadline => 2.days.from_now)

        Prediction.future.should == [sooner,further]
      end
    end

    describe 'sorting scope' do
      it 'should default to creation date order' do
        older = create_valid_prediction(:created_at => 2.years.ago)
        newest = create_valid_prediction
        Prediction.sort.should contain_in_order([older,newest])
      end

      it 'should order according to optional first arg' do
        a = create_valid_prediction(:description => 'aaaaaaartghhh')
        y = create_valid_prediction(:description => 'yaaaaaahhh')

        Prediction.sort(:description).should contain_in_order([a, y])
      end
    end
    describe 'reverse sorting scope' do
      it 'should default to creation date order' do
        older = create_valid_prediction(:created_at => 2.years.ago)
        newest = create_valid_prediction
        Prediction.rsort.should contain_in_order([newest,older])
      end

      it 'should order according to optional first arg' do
        a = create_valid_prediction(:description => 'aaaaaaartghhh')
        y = create_valid_prediction(:description => 'yaaaaaahhh')

        Prediction.rsort(:description).should contain_in_order([y, a])
      end
    end
  end

  describe 'notify creator' do
    describe 'default' do
      describe 'when has creator' do
        before do
          @user = User.new
          @prediction = Prediction.new(:creator => @user)
        end
        it 'should be true if user has email' do
          @user.stub(:notify_on_overdue?).and_return true
          @prediction.notify_creator.should be true
        end
        it 'should be false if creator does not have email' do
          @user.stub(:notify_on_overdue?).and_return false
          @prediction.notify_creator.should be false
        end
      end
      describe 'when has creator and notify creator' do
        describe 'is false' do
          before do
            @user = User.new
            @prediction = Prediction.new(:creator => @user, :notify_creator => false)
          end
          it 'should be false even if user has email' do
            @user.stub(:notify_on_overdue?).and_return true
            @prediction.notify_creator.should be false
          end
          it 'should be false even if does not have email' do
            @user.stub(:notify_on_overdue?).and_return false
            @prediction.notify_creator.should be false
          end
        end
        describe 'is true' do
          before do
            @user = User.new
            @prediction = Prediction.new(:creator => @user, :notify_creator => true)
          end
          it 'should be true even if user has email' do
            @user.stub(:notify_on_overdue?).and_return true
            @prediction.notify_creator.should be true
          end
          it 'should be true even if does not have email' do
            @user.stub(:notify_on_overdue?).and_return false
            @prediction.notify_creator.should be true
          end
        end
      end
    end
    it 'should be assignable' do
      Prediction.new(:notify_creator => true).notify_creator.should be true
      Prediction.new(:notify_creator => false).notify_creator.should be false
    end
    it 'should accept checkbox form values' do
      Prediction.new(:notify_creator => "1").notify_creator.should be true
      Prediction.new(:notify_creator => "0").notify_creator.should be false
    end
  end
  describe 'initial deadline notification' do
    it 'should exist when notify creator is true' do
      prediction = Prediction.new(:notify_creator => true)
      prediction.valid?
      prediction.deadline_notifications.should_not be_empty
    end

    it 'should not exist when notify creator is false' do
      Prediction.new(:notify_creator => false).deadline_notifications.should be_empty
    end
  end

  describe 'deadline' do
    it 'should have a deadline attribute that is initially nil' do
      Prediction.new.deadline.should be_nil
    end

    it 'should be a date field' do
      date = 5.weeks.from_now
      prediction = Prediction.new(:deadline => date)
      prediction.deadline.to_s(:db).should == date.to_s(:db)
    end

    it 'should transform natural language date "tomorrow" to date' do
      prediction = Prediction.new
      prediction.deadline_text = 'tomorrow'
      prediction.deadline.to_s(:db).should == 1.day.from_now.noon.to_s(:db)
    end

    it 'should have an error on deadline_text if invalid' do
      prediction = Prediction.new
      prediction.save
      prediction.errors.keys.should include(:deadline_text)
    end

    describe 'prettied' do
      it 'should look nice' do
        prediction = Prediction.new
        prediction.deadline_text = 'Fri Aug 15 13:17:07 +1000 2008'
        prediction.prettied_deadline.should == "August 15, 2008 03:17"
      end
    end
  end
  describe 'due for judgement?' do
    it 'should be true when outcome unknown and past deadline' do
      prediction = Prediction.new(:deadline => 10.minutes.ago)
      prediction.stub(:outcome).and_return(nil)
      prediction.should be_due_for_judgement
    end
    it 'should be false when outcome known and past deadline' do
      prediction = Prediction.new(:deadline => 10.minutes.ago)
      prediction.stub(:outcome).and_return(true)
      prediction.should_not be_due_for_judgement
    end
    it 'should be false when outcome unknown and not past deadline' do
      prediction = Prediction.new(:deadline => 10.minutes.from_now)
      prediction.stub(:outcome).and_return(nil)
      prediction.should_not be_due_for_judgement
    end
    it 'should be false when outcome known and not past deadline' do
      prediction = Prediction.new(:deadline => 10.minutes.from_now)
      prediction.stub(:outcome).and_return(true)
      prediction.should_not be_due_for_judgement
    end
    it 'should be false when withdrawn' do
      prediction = Prediction.new(:deadline => 10.minutes.ago)
      prediction.stub(:outcome).and_return(nil)
      prediction.stub(:withdrawn?).and_return(true)
      prediction.should_not be_due_for_judgement
    end
  end

  describe 'outcome' do
    it 'should have an outcome attribute that is initially nil' do
      Prediction.new.outcome.should be_nil
    end

    describe 'with versioning' do
      it 'should have a list of judgements' do
        Prediction.new.judgements.should == []
      end

      describe 'delegate' do
        it 'should delegate outcome to judgement' do
          prediction = Prediction.new
          prediction.stub(:judgement).and_return(mock_model(Judgement, :outcome => true))
          prediction.outcome.should == true
        end
        it 'should return nil if unjudged' do
          Prediction.new.outcome.should be_nil
        end
      end

      describe '#judge' do
        before(:each) do
          @prediction = create_valid_prediction
          @user = mock_model(User)
        end

        it 'should set the outcome to true' do
          @prediction.judge!('right', @user)
          @prediction.outcome.should == true
        end

        it 'should have a new judgement associated with the judging user' do
          @prediction.judge!('wrong', @user)
          @prediction.judgements.first.user.should == @user
        end

        it 'should create a new judgement' do
          @prediction.judge!('wrong', @user)
          @prediction.reload
          @prediction.judgements.size.should == 1
        end
      end
    end

    describe 'withdraw modifier' do
      before(:each) do
        @prediction = create_valid_prediction
      end

      it 'should not be withdrawn by default' do
        @prediction.should_not be_withdrawn
      end

      it 'should set the withdrawn boolean to true when withdraw! called' do
        @prediction.should_receive(:update_attribute).with(:withdrawn, true)
        @prediction.withdraw!
      end

      it 'should still be withdrawn after reloading' do
        @prediction.withdraw!
        @prediction.reload.should be_withdrawn
      end

      it 'should not withdraw if the prediction is not open' do
        @prediction.stub(:open?).and_return(false)
        lambda { @prediction.withdraw! }.should raise_error(ArgumentError)
      end
    end

    describe 'query methods' do
      before(:each) do
        @prediction = Prediction.new
      end

      it 'should return true for right? when outcome is true' do
        @prediction.stub(:outcome).and_return(true)
        @prediction.right?.should be true
      end
      it 'should return true for wrong? when outcome is false' do
        @prediction.stub(:outcome).and_return(false)
        @prediction.wrong?.should be true
      end
      it 'should return true for unknown? when outcome is nil' do
        @prediction.stub(:outcome).and_return(nil)
        @prediction.unknown?.should be true
      end

      describe 'open' do
        it 'should be true when outcome is unknown and not withdrawn?' do
          @prediction.stub(:withdrawn?).and_return(false)
          @prediction.stub(:unknown?).and_return(true)
          @prediction.should be_open
        end
        it 'should be false when withdrawn?' do
          @prediction.stub(:withdrawn?).and_return(true)
          @prediction.should_not be_open
        end
        it 'should be false when outcome is known' do
          @prediction.stub(:unknown?).and_return(false)
          @prediction.should_not be_open
        end
      end
    end

    describe 'accessor for readable outcome' do
      it 'should delegate to the judgement' do
        prediction = Prediction.new
        judgement = mock_model(Judgement)
        prediction.stub(:judgement).and_return(judgement)
        judgement.should_receive(:outcome_in_words)
        prediction.readable_outcome
      end
      it 'should return nil if no judgement' do
        Prediction.new.readable_outcome.should be_nil
      end
      it 'should return withdrawn if so' do
        p = Prediction.new
        p.stub(:withdrawn?).and_return(true)
        p.readable_outcome.should == 'withdrawn'
      end
    end
  end

  describe 'confidence aggregation' do
    it 'should delegate to wagers' do
      prediction = Prediction.new
      wagers = double('wagers')
      prediction.stub(:wagers).and_return(wagers)
      wagers.should_receive(:mean_confidence).and_return(:mean_confidence)
      prediction.mean_confidence.should == :mean_confidence
    end
  end

  describe 'events collection' do
    before(:each) do
      @prediction = Prediction.new
      @r1 = double('', :created_at => 10.days.ago)
      @v1 = double('', :created_at => 10.days.ago)
      @j1 = double('', :created_at => 6.days.ago)
      @v2 = double('', :created_at => 5.days.ago)
      @j2 = double('', :created_at => 4.days.ago)
      @v3 = double('', :created_at => 3.days.ago)
      @r2 = double('', :created_at => 1.day.ago)
      @prediction.stub(:responses).and_return([@r1, @r2])
      @prediction.stub(:versions).and_return([@v1, @v2, @v3])
      @prediction.stub(:judgements).and_return([@j1, @j2])
    end

    it 'should return all responses' do
      @prediction.events.should include(@r1, @r2)
    end

    it 'should return all judgments' do
      @prediction.events.should include(@j1, @j2)
    end

    it 'should include all subsequent versions after the initial creation' do
      @prediction.events.should include(@v2, @v3)
      @prediction.events.should_not include(@v1)
    end

    it 'should sort all by created_at date' do
      @prediction.events.should == [@r1, @j1, @v2, @j2, @v3, @r2]
    end
  end
end
