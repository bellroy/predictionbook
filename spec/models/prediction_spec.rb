require 'spec_helper'

describe Prediction do
  it 'has a creator attribute that is initially nil' do
    expect(Prediction.new.creator).to be_nil
  end

  it 'has a description attribute that is initially nil' do
    expect(Prediction.new.description).to be_nil
  end

  it 'has an inital_confidence attribute that is nil initially' do
    expect(Prediction.new.initial_confidence).to be_nil
    expect(Prediction.new).to respond_to(:initial_confidence=)
  end

  describe 'validations' do
    describe 'with default values' do
      before(:each) do
        @prediction = Prediction.new
        @prediction.valid?
      end

      it 'passes on objects from modelfactory' do
        expect(FactoryGirl.build(:prediction)).to be_valid
        expect(FactoryGirl.create(:prediction)).to be_valid
      end

      it 'requires a creator' do
        @prediction.valid?
        expect(@prediction.errors[:creator].length).to eq 1
      end

      it 'requires a deadline' do
        @prediction.valid?
        expect(@prediction.errors[:deadline].length).to eq 1
      end

      it 'requires a description' do
        @prediction.valid?
        expect(@prediction.errors[:description].length).to eq 1
      end
    end

    describe 'with invalid values' do
      it 'does not accept a deadline too far into the future to store' do
        date = 300_000.years.from_now
        prediction = Prediction.new(deadline: date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'does not accept retrodictions' do
        date = 1.month.ago
        prediction = Prediction.new(deadline: date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'does not accept a deadline too far in the past to store' do
        date = 300_000.years.ago
        prediction = Prediction.new(deadline: date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'does not accept an invalid deadline even after being created' do
        prediction = Prediction.new(deadline: 2.months.from_now)
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 0
        prediction.deadline = 300_000.years.from_now
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
    end
  end

  describe 'with uuid' do
    it 'has a uuid attribute' do
      expect(Prediction.new).to respond_to(:uuid)
    end

    def stub_uuid_create(string)
      uuid = UUIDTools::UUID.parse(string)
      allow(UUIDTools::UUID).to receive(:random_create).and_return(uuid)
    end

    it 'sets the UUID for a new record' do
      stub_uuid_create('21f7f8de-8051-5b89-8680-0195ef798b6a')
      expect(Prediction.new.uuid).to eq '21f7f8de-8051-5b89-8680-0195ef798b6a'
    end

    it 'persists UUID set for the new record' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      prediction = FactoryGirl.build(:prediction)
      expect(prediction.uuid).to eq '64a5189c-25b3-11da-a97b-00c04fd430c8'
      prediction.save!
      expect(prediction.reload.uuid).to eq '64a5189c-25b3-11da-a97b-00c04fd430c8'
    end

    it 'allows write access to UUIDs on create' do
      prediction = FactoryGirl.create(:prediction, uuid: '21f7f8de-8051-5b89-8680-0195ef798b6a')
      expect(prediction.uuid).to eq '21f7f8de-8051-5b89-8680-0195ef798b6a'
    end

    it 'does not allow write access to UUIDs loaded from DB' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      prediction = FactoryGirl.create(:prediction)
      prediction.update_attributes! uuid: 'other uuid'
      expect(prediction.reload.uuid).to eq '64a5189c-25b3-11da-a97b-00c04fd430c8'
    end

    it 'raises DuplicateRecord on create if there is a record with that UUID already' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      FactoryGirl.create(:prediction)
      expect { FactoryGirl.create(:prediction) }.to raise_error(Prediction::DuplicateRecord)
    end
  end

  describe 'with responses' do
    describe 'initial response creation' do
      it 'builds a response before validation' do
        p = Prediction.new
        p.valid?
        expect(p.responses.length).to eq 1
      end

      it 'assigns response user from creator' do
        u = User.new
        p = Prediction.new(creator: u)
        p.valid?
        expect(p.responses.first.user).to eq u
      end

      it 'assigns initial confidence from passed value' do
        p = Prediction.new(initial_confidence: 50)
        p.valid?
        expect(p.responses.first.confidence).to eq 50
      end
    end
  end

  describe '#judgement' do
    it 'returns most recent judgement' do
      prediction = FactoryGirl.create(:prediction)
      prediction.judge!(:right)
      prediction.judge!(:wrong)
      expect(prediction.judgement.outcome).to eq false
      expect(prediction).to be_wrong
    end
    it 'returns nil if no judgements' do
      expect(FactoryGirl.create(:prediction).judgement).to be_nil
    end
  end

  describe '#judged_at' do
    it 'returns when judgement occured' do
      prediction = FactoryGirl.create(:prediction)

      judged_at = 15.minutes.from_now
      allow(Time).to receive(:now).and_return(judged_at)
      prediction.judge!(:right)

      expect(prediction.judged_at).to eq judged_at
    end
  end

  describe 'finders and scopes' do
    it_behaves_like 'model class with common scopes'

    before do
      Prediction.destroy_all
    end

    it 'has a finder for the most recent predictions' do
      prediction1 = FactoryGirl.create(:prediction, created_at: 2.weeks.ago)
      prediction2 = FactoryGirl.create(:prediction)
      expect(Prediction.recent).to eq [prediction2, prediction1]
    end

    describe 'popular predictions' do
      it 'has a finder for recent popular predictions' do
        prediction1 = FactoryGirl.create(:prediction, created_at: 1.week.ago, deadline: 4.days.from_now)
        FactoryGirl.create(:response, prediction: prediction1)
        prediction2 = FactoryGirl.create(:prediction, created_at: 2.days.ago, deadline: 2.days.from_now)
        prediction3 = FactoryGirl.create(:prediction, created_at: 1.week.ago, deadline: 3.days.from_now)
        FactoryGirl.create(:response, prediction: prediction3)
        FactoryGirl.create(:response, prediction: prediction3)
        prediction4 = FactoryGirl.create(:prediction, created_at: 1.day.ago, deadline: 1.day.from_now)
        expect(Prediction.popular).to eq [prediction3, prediction1, prediction4, prediction2]
      end

      it 'excludes overdue predictions' do
        FactoryGirl.create(:prediction, created_at: 1.week.ago, deadline: 1.day.ago)
        prediction2 = FactoryGirl.create(:prediction, created_at: 1.week.ago, deadline: 1.day.from_now)
        expect(Prediction.popular).to eq [prediction2]
      end

      it 'excludes judged (known) predictions' do
        prediction1 = FactoryGirl.create(:prediction, created_at: 1.week.ago, deadline: 1.day.from_now)
        FactoryGirl.create(:judgement, prediction: prediction1, outcome: false)
        prediction2 = FactoryGirl.create(:prediction, created_at: 1.week.ago, deadline: 1.day.from_now)
        expect(Prediction.popular).to eq [prediction2]
      end

      it 'excludes predictions made more than 2 weeks ago' do
        FactoryGirl.create(:prediction, created_at: 3.weeks.ago, deadline: 1.day.from_now)
        FactoryGirl.create(:prediction, created_at: 4.weeks.ago, deadline: 2.days.from_now)
        FactoryGirl.create(:prediction, created_at: 5.weeks.ago, deadline: 3.days.from_now)
        expect(Prediction.popular).to be_empty
      end
    end

    describe 'judged predictions' do
      it 'orders by most recently judged first' do
        first = FactoryGirl.create(:prediction)
        last = FactoryGirl.create(:prediction)

        first.judge!(:right)
        future = 10.minutes.from_now.time
        allow(Time).to receive(:now).and_return(future)
        last.judge!(:right)

        expect(Prediction.judged).to eq [last, first]
      end

      it 'includes judged predictions' do
        judged = FactoryGirl.create(:prediction)
        judged.judge!(:right, nil)

        expect(Prediction.judged).to eq [judged]
      end

      it 'does not include unjudged predictions' do
        FactoryGirl.create(:prediction)

        expect(Prediction.judged).to eq []
      end
    end

    describe 'for unjudged predictions' do
      it 'does not return judged predictions' do
        judged = FactoryGirl.create(:prediction)
        judged.judge!(:right, nil)
        unjudged = FactoryGirl.create(:prediction)

        expect(Prediction.unjudged).to eq [unjudged]
      end

      it 'does not return predictions whose deadline is in the future' do
        FactoryGirl.create(:prediction, deadline: 2.years.from_now)
        past = FactoryGirl.create(:prediction, deadline: 2.days.ago)

        expect(Prediction.unjudged).to eq [past]
      end

      it 'orders by deadline' do
        long_ago = FactoryGirl.create(:prediction, deadline: 2.days.ago)
        longer_ago = FactoryGirl.create(:prediction, deadline: 2.weeks.ago)

        expect(Prediction.unjudged).to eq [long_ago, longer_ago]
      end

      it 'returns currently unjudged predictions with previous judgements' do
        rejudged = FactoryGirl.create(:prediction)
        rejudged.judge!(:right, nil)
        sleep 1 # second granularity on judgement created_at
        rejudged.judge!(nil, nil)

        expect(Prediction.unjudged).to eq [rejudged]
      end

      it 'does not return currently judged predictions with previous unknown judgements' do
        rejudged = FactoryGirl.create(:prediction)
        rejudged.judge!(nil, nil)
        sleep 1 # second granularity on judgement created_at
        rejudged.judge!(:right, nil)

        expect(Prediction.unjudged).to eq []
      end
    end

    describe 'for future predictions' do
      it 'does not return judged predictions' do
        judged = FactoryGirl.create(:prediction, deadline: 2.days.from_now)
        judged.judge!(:right, nil)
        unjudged = FactoryGirl.create(:prediction, deadline: 2.days.from_now)

        expect(Prediction.future).to eq [unjudged]
      end

      it 'does not return predictions whose deadline is in the past' do
        future = FactoryGirl.create(:prediction, deadline: 2.years.from_now)
        FactoryGirl.create(:prediction, deadline: 2.days.ago)

        expect(Prediction.future).to eq [future]
      end

      it 'orders by ascending deadline' do
        further = FactoryGirl.create(:prediction, deadline: 2.weeks.from_now)
        sooner = FactoryGirl.create(:prediction, deadline: 2.days.from_now)

        expect(Prediction.future).to eq [sooner, further]
      end
    end
  end

  describe 'notify creator' do
    describe 'default' do
      describe 'when has creator' do
        before do
          @user = User.new
          @prediction = Prediction.new(creator: @user)
        end

        it 'is true if user has email' do
          expect(@user).to receive(:notify_on_overdue?).and_return true
          expect(@prediction.notify_creator).to be true
        end

        it 'is false if creator does not have email' do
          expect(@user).to receive(:notify_on_overdue?).and_return false
          expect(@prediction.notify_creator).to be false
        end
      end

      describe 'when has creator and notify creator' do
        describe 'is false' do
          before do
            @user = User.new
            @prediction = Prediction.new(creator: @user, notify_creator: false)
          end

          it 'is false even if user has email' do
            expect(@prediction.notify_creator).to be false
          end

          it 'is false even if does not have email' do
            expect(@prediction.notify_creator).to be false
          end
        end

        describe 'is true' do
          before do
            @user = User.new
            @prediction = Prediction.new(creator: @user, notify_creator: true)
          end

          it 'is true even if user has email' do
            expect(@prediction.notify_creator).to be true
          end

          it 'is true even if does not have email' do
            expect(@prediction.notify_creator).to be true
          end
        end
      end
    end

    it 'is assignable' do
      expect(Prediction.new(notify_creator: true).notify_creator).to be true
      expect(Prediction.new(notify_creator: false).notify_creator).to be false
    end

    it 'accepts checkbox form values' do
      expect(Prediction.new(notify_creator: '1').notify_creator).to be true
      expect(Prediction.new(notify_creator: '0').notify_creator).to be false
    end
  end

  describe 'initial deadline notification' do
    it 'exists when notify creator is true' do
      prediction = Prediction.new(notify_creator: true)
      prediction.valid?
      expect(prediction.deadline_notifications).not_to be_empty
    end

    it 'does not exist when notify creator is false' do
      expect(Prediction.new(notify_creator: false).deadline_notifications).to be_empty
    end
  end

  describe 'deadline' do
    it 'has a deadline attribute that is initially nil' do
      expect(Prediction.new.deadline).to be_nil
    end

    it 'is a date field' do
      date = 5.weeks.from_now
      prediction = Prediction.new(deadline: date)
      expect(prediction.deadline.to_s(:db)).to eq date.to_s(:db)
    end

    it 'transforms natural language date "tomorrow" to date' do
      prediction = Prediction.new
      prediction.deadline_text = 'tomorrow'
      expect(prediction.deadline.to_s(:db)).to eq 1.day.from_now.noon.to_s(:db)
    end

    it 'has an error on deadline_text if invalid' do
      prediction = Prediction.new
      prediction.save
      expect(prediction.errors.keys).to include(:deadline_text)
    end

    describe 'prettied' do
      it 'looks nice' do
        prediction = Prediction.new
        prediction.deadline_text = 'Fri Aug 15 13:17:07 +1000 2008'
        expect(prediction.prettied_deadline).to eq 'August 15, 2008 03:17'
      end
    end
  end

  describe 'due for judgement?' do
    it 'is true when outcome unknown and past deadline' do
      prediction = Prediction.new(deadline: 10.minutes.ago)
      expect(prediction).to receive(:outcome).and_return(nil)
      expect(prediction).to be_due_for_judgement
    end

    it 'is false when outcome known and past deadline' do
      prediction = Prediction.new(deadline: 10.minutes.ago)
      expect(prediction).to receive(:outcome).and_return(true)
      expect(prediction).not_to be_due_for_judgement
    end

    it 'is false when outcome unknown and not past deadline' do
      prediction = Prediction.new(deadline: 10.minutes.from_now)
      expect(prediction).not_to be_due_for_judgement
    end

    it 'is false when outcome known and not past deadline' do
      prediction = Prediction.new(deadline: 10.minutes.from_now)
      expect(prediction).not_to be_due_for_judgement
    end

    it 'is false when withdrawn' do
      prediction = Prediction.new(deadline: 10.minutes.ago)
      expect(prediction).to receive(:withdrawn?).and_return(true)
      expect(prediction).not_to be_due_for_judgement
    end
  end

  describe 'outcome' do
    it 'has an outcome attribute that is initially nil' do
      expect(Prediction.new.outcome).to be_nil
    end

    describe 'with versioning' do
      it 'has a list of judgements' do
        expect(Prediction.new.judgements).to eq []
      end

      describe 'delegate' do
        it 'delegates outcome to judgement' do
          prediction = Prediction.new
          allow(prediction).to receive(:judgement).and_return(mock_model(Judgement, outcome: true))
          expect(prediction.outcome).to eq true
        end
        it 'returns nil if unjudged' do
          expect(Prediction.new.outcome).to be_nil
        end
      end

      describe '#judge' do
        before(:each) do
          @prediction = FactoryGirl.create(:prediction)
          @user = mock_model(User)
        end

        it 'sets the outcome to true' do
          @prediction.judge!('right', @user)
          expect(@prediction.outcome).to eq true
        end

        it 'has a new judgement associated with the judging user' do
          @prediction.judge!('wrong', @user)
          expect(@prediction.judgements.first.user).to eq @user
        end

        it 'creates a new judgement' do
          @prediction.judge!('wrong', @user)
          @prediction.reload
          expect(@prediction.judgements.size).to eq 1
        end
      end
    end

    describe 'withdraw modifier' do
      before(:each) do
        @prediction = FactoryGirl.create(:prediction)
      end

      it 'is not be withdrawn by default' do
        expect(@prediction).not_to be_withdrawn
      end

      it 'sets the withdrawn boolean to true when withdraw! called' do
        expect(@prediction).to receive(:update_attribute).with(:withdrawn, true)
        @prediction.withdraw!
      end

      it 'is still withdrawn after reloading' do
        @prediction.withdraw!
        expect(@prediction.reload).to be_withdrawn
      end

      it 'does not withdraw if the prediction is not open' do
        expect(@prediction).to receive(:open?).and_return(false)
        expect { @prediction.withdraw! }.to raise_error(ArgumentError)
      end
    end

    describe 'query methods' do
      before(:each) do
        @prediction = Prediction.new
      end

      it 'returns true for right? when outcome is true' do
        expect(@prediction).to receive(:outcome).and_return(true)
        expect(@prediction.right?).to be true
      end
      it 'returns true for wrong? when outcome is false' do
        expect(@prediction).to receive(:outcome).and_return(false)
        expect(@prediction.wrong?).to be true
      end
      it 'returns true for unknown? when outcome is nil' do
        expect(@prediction).to receive(:outcome).and_return(nil)
        expect(@prediction.unknown?).to be true
      end

      describe 'open' do
        it 'is true when outcome is unknown and not withdrawn?' do
          expect(@prediction).to receive(:withdrawn?).and_return(false)
          expect(@prediction).to receive(:unknown?).and_return(true)
          expect(@prediction).to be_open
        end
        it 'is false when withdrawn?' do
          expect(@prediction).to receive(:withdrawn?).and_return(true)
          expect(@prediction).not_to be_open
        end
        it 'is false when outcome is known' do
          expect(@prediction).to receive(:unknown?).and_return(false)
          expect(@prediction).not_to be_open
        end
      end
    end

    describe 'accessor for readable outcome' do
      it 'delegates to the judgement' do
        prediction = Prediction.new
        judgement = mock_model(Judgement)
        allow(prediction).to receive(:judgement).and_return(judgement)
        expect(judgement).to receive(:outcome_in_words)
        prediction.readable_outcome
      end
      it 'returns nil if no judgement' do
        expect(Prediction.new.readable_outcome).to be_nil
      end
      it 'returns withdrawn if so' do
        p = Prediction.new
        expect(p).to receive(:withdrawn?).and_return(true)
        expect(p.readable_outcome).to eq 'withdrawn'
      end
    end
  end

  describe 'confidence aggregation' do
    it 'calculates correctly' do
      prediction = FactoryGirl.create(:prediction)
      prediction.responses.first.update_attributes(confidence: 50)
      FactoryGirl.create(:response, prediction: prediction, confidence: 56)
      FactoryGirl.create(:response, prediction: prediction, confidence: 83)
      expect(prediction.mean_confidence).to eq 63
    end
  end

  describe 'events collection' do
    before(:each) do
      @prediction = Prediction.new
      @r1 = instance_double(Response, created_at: 10.days.ago)
      @v1 = instance_double(Prediction, created_at: 10.days.ago)
      @j1 = instance_double(Judgement, created_at: 6.days.ago)
      @v2 = instance_double(Prediction, created_at: 5.days.ago)
      @j2 = instance_double(Judgement, created_at: 4.days.ago)
      @v3 = instance_double(Prediction, created_at: 3.days.ago)
      @r2 = instance_double(Response, created_at: 1.day.ago)
      allow(@prediction).to receive(:responses).and_return([@r1, @r2])
      allow(@prediction).to receive(:versions).and_return([@v1, @v2, @v3])
      allow(@prediction).to receive(:judgements).and_return([@j1, @j2])
    end

    it 'returns all responses' do
      expect(@prediction.events).to include(@r1, @r2)
    end

    it 'returns all judgments' do
      expect(@prediction.events).to include(@j1, @j2)
    end

    it 'includes all subsequent versions after the initial creation' do
      expect(@prediction.events).to include(@v2, @v3)
      expect(@prediction.events).not_to include(@v1)
    end

    it 'sorts all by created_at date' do
      expect(@prediction.events).to eq [@r1, @j1, @v2, @j2, @v3, @r2]
    end
  end
end
