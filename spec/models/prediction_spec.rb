# frozen_string_literal: true

require 'spec_helper'

describe Prediction do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  it 'has a creator attribute that is initially nil' do
    expect(described_class.new.creator).to be_nil
  end

  it 'has a description attribute that is initially nil' do
    expect(described_class.new.description).to be_nil
  end

  it 'has an inital_confidence attribute that is nil initially' do
    expect(described_class.new.initial_confidence).to be_nil
    expect(described_class.new).to respond_to(:initial_confidence=)
  end

  describe 'callbacks' do
    let(:prediction_group) { FactoryBot.create(:prediction_group, predictions: 2) }
    let(:first_prediction) do
      prediction = prediction_group.predictions.first
      prediction.update(deadline: 1.day.ago, visibility: :visible_to_everyone)
      prediction
    end
    let(:second_prediction) do
      prediction = prediction_group.predictions.first
      prediction.update(deadline: 2.days.ago, visibility: :visible_to_creator)
      prediction
    end

    before do
      first_prediction
      second_prediction
    end

    it 'adds tags included in the description' do
      prediction = FactoryBot.build(
        :prediction,
        description: "Foo will bar before baz #foo #bar #baz"
      )
      prediction.save!
      prediction.reload
      expect(prediction.tag_names).to contain_exactly("foo", "bar", "baz")
    end

    it 'strips tags from the description' do
      prediction = FactoryBot.build(
        :prediction,
        description: "Foo will bar before baz #foo #bar #baz"
      )
      prediction.save!
      description = prediction.reload.description
      expect(description).not_to include("#foo")
      expect(description).not_to include("#bar")
      expect(description).not_to include("#baz")
    end

    it 'synchronises some properties for predictions in the same group' do
      first_prediction.reload
      expect(first_prediction.deadline).to be < 25.hours.ago
      expect(first_prediction).to be_visible_to_creator

      second_prediction.reload
      expect(second_prediction.deadline).to be < 25.hours.ago
      expect(second_prediction).to be_visible_to_creator
    end
  end

  describe 'validations' do
    describe 'with default values' do
      before do
        @prediction = described_class.new
        @prediction.valid?
      end

      it 'passes on objects from modelfactory' do
        expect(FactoryBot.build(:prediction)).to be_valid
        expect(FactoryBot.create(:prediction)).to be_valid
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
      context 'and a description over 255 characters' do
        let(:long_string) { 'a' * 256 }
        let(:prediction) do
          FactoryBot.build(:prediction, description: long_string)
        end

        before { prediction.save }

        it 'works', :aggregate_failures do
          expect(prediction).not_to be_valid
          expect(prediction.errors.full_messages).to include(/255/)
        end
      end

      it 'does not accept a deadline too far into the future to store' do
        date = 300_000.years.from_now
        prediction = described_class.new(deadline: date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'does not accept retrodictions' do
        date = 1.month.ago
        prediction = described_class.new(deadline: date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'does not accept a deadline too far in the past to store' do
        date = 300_000.years.ago
        prediction = described_class.new(deadline: date)
        prediction.valid?
        prediction.valid?
        expect(prediction.errors[:deadline].length).to eq 1
      end
      it 'does not accept an invalid deadline even after being created' do
        prediction = described_class.new(deadline: 2.months.from_now)
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
      expect(described_class.new).to respond_to(:uuid)
    end

    def stub_uuid_create(string)
      uuid = UUIDTools::UUID.parse(string)
      allow(UUIDTools::UUID).to receive(:random_create).and_return(uuid)
    end

    it 'sets the UUID for a new record' do
      stub_uuid_create('21f7f8de-8051-5b89-8680-0195ef798b6a')
      expect(described_class.new.uuid).to eq '21f7f8de-8051-5b89-8680-0195ef798b6a'
    end

    it 'persists UUID set for the new record' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      prediction = FactoryBot.build(:prediction)
      expect(prediction.uuid).to eq '64a5189c-25b3-11da-a97b-00c04fd430c8'
      prediction.save!
      expect(prediction.reload.uuid).to eq '64a5189c-25b3-11da-a97b-00c04fd430c8'
    end

    it 'allows write access to UUIDs on create' do
      prediction = FactoryBot.create(:prediction, uuid: '21f7f8de-8051-5b89-8680-0195ef798b6a')
      expect(prediction.uuid).to eq '21f7f8de-8051-5b89-8680-0195ef798b6a'
    end

    it 'does not allow write access to UUIDs loaded from DB' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      prediction = FactoryBot.create(:prediction)
      prediction.update! uuid: 'other uuid'
      expect(prediction.reload.uuid).to eq '64a5189c-25b3-11da-a97b-00c04fd430c8'
    end

    it 'raises DuplicateRecord on create if there is a record with that UUID already' do
      stub_uuid_create('64a5189c-25b3-11da-a97b-00c04fd430c8')
      FactoryBot.create(:prediction)
      expect { FactoryBot.create(:prediction) }.to raise_error(Prediction::DuplicateRecord)
    end
  end

  describe 'with responses' do
    describe 'initial response creation' do
      it 'builds a response before validation' do
        p = described_class.new
        p.valid?
        expect(p.responses.length).to eq 1
      end

      it 'assigns response user from creator' do
        u = User.new
        p = described_class.new(creator: u)
        p.valid?
        expect(p.responses.first.user).to eq u
      end

      it 'assigns initial confidence from passed value' do
        p = described_class.new(initial_confidence: 50)
        p.valid?
        expect(p.responses.first.confidence).to eq 50
      end
    end
  end

  describe '#tag_names' do
    it 'ignores duplicates' do
      prediction = FactoryBot.create(:prediction)
      prediction.tag_names << 'covid'
      prediction.tag_names << 'covid'
      prediction.save
      expect(prediction.reload.tag_names).to match_array(['covid'])
    end
  end

  describe '#judgement' do
    it 'returns most recent judgement' do
      prediction = FactoryBot.create(:prediction)
      prediction.judge!(:right)
      prediction.judge!(:wrong)
      expect(prediction.judgement.outcome).to eq false
      expect(prediction).to be_wrong
    end
    it 'returns nil if no judgements' do
      expect(FactoryBot.create(:prediction).judgement).to be_nil
    end
  end

  describe '#judged_at' do
    it 'returns when judgement occured' do
      prediction = FactoryBot.create(:prediction)

      judged_at = 15.minutes.from_now
      allow(Time).to receive(:now).and_return(judged_at)
      prediction.judge!(:right)

      expect(prediction.judged_at.strftime('%Y%m%d%H%M%S')).to eq judged_at.strftime('%Y%m%d%H%M%S')
    end
  end

  describe 'finders and scopes' do
    before do
      described_class.destroy_all
    end

    it 'has a finder for the most recent predictions' do
      prediction1 = FactoryBot.create(:prediction, created_at: 2.weeks.ago)
      prediction2 = FactoryBot.create(:prediction)
      expect(described_class.recent).to eq [prediction2, prediction1]
    end

    describe 'popular predictions' do
      it 'has a finder for recent popular predictions' do
        prediction1 = FactoryBot.create(:prediction, created_at: 1.week.ago, deadline: 4.days.from_now)
        FactoryBot.create(:response, prediction: prediction1)
        prediction2 = FactoryBot.create(:prediction, created_at: 2.days.ago, deadline: 2.days.from_now)
        prediction3 = FactoryBot.create(:prediction, created_at: 1.week.ago, deadline: 3.days.from_now)
        FactoryBot.create(:response, prediction: prediction3)
        FactoryBot.create(:response, prediction: prediction3)
        prediction4 = FactoryBot.create(:prediction, created_at: 1.day.ago, deadline: 1.day.from_now)
        expect(described_class.popular).to eq [prediction3, prediction1, prediction4, prediction2]
      end

      it 'excludes overdue predictions' do
        FactoryBot.create(:prediction, created_at: 1.week.ago, deadline: 1.day.ago)
        prediction2 = FactoryBot.create(:prediction, created_at: 1.week.ago, deadline: 1.day.from_now)
        expect(described_class.popular).to eq [prediction2]
      end

      it 'excludes judged (known) predictions' do
        prediction1 = FactoryBot.create(:prediction, created_at: 1.week.ago, deadline: 1.day.from_now)
        FactoryBot.create(:judgement, prediction: prediction1, outcome: false)
        prediction2 = FactoryBot.create(:prediction, created_at: 1.week.ago, deadline: 1.day.from_now)
        expect(described_class.popular).to eq [prediction2]
      end

      it 'excludes predictions made more than 2 weeks ago' do
        FactoryBot.create(:prediction, created_at: 3.weeks.ago, deadline: 1.day.from_now)
        FactoryBot.create(:prediction, created_at: 4.weeks.ago, deadline: 2.days.from_now)
        FactoryBot.create(:prediction, created_at: 5.weeks.ago, deadline: 3.days.from_now)
        expect(described_class.popular).to be_empty
      end
    end

    describe 'judged predictions' do
      it 'orders by most recently judged first' do
        first = FactoryBot.create(:prediction)
        last = FactoryBot.create(:prediction)

        first.judge!(:right)
        future = 10.minutes.from_now.time
        allow(Time).to receive(:now).and_return(future)
        last.judge!(:right)

        expect(described_class.judged).to eq [last, first]
      end

      it 'includes judged predictions' do
        judged = FactoryBot.create(:prediction)
        judged.judge!(:right, nil)

        expect(described_class.judged).to eq [judged]
      end

      it 'does not include unjudged predictions' do
        FactoryBot.create(:prediction)

        expect(described_class.judged).to eq []
      end
    end

    describe 'for unjudged predictions' do
      it 'does not return judged predictions' do
        judged = FactoryBot.create(:prediction)
        judged.judge!(:right, nil)
        unjudged = FactoryBot.create(:prediction)

        expect(described_class.unjudged).to eq [unjudged]
      end

      it 'does not return predictions whose deadline is in the future' do
        FactoryBot.create(:prediction, deadline: 2.years.from_now)
        past = FactoryBot.create(:prediction, deadline: 2.days.ago)

        expect(described_class.unjudged).to eq [past]
      end

      it 'orders by deadline' do
        long_ago = FactoryBot.create(:prediction, deadline: 2.days.ago)
        longer_ago = FactoryBot.create(:prediction, deadline: 2.weeks.ago)

        expect(described_class.unjudged).to eq [long_ago, longer_ago]
      end

      it 'returns currently unjudged predictions with previous judgements' do
        rejudged = FactoryBot.create(:prediction)
        rejudged.judge!(:right, nil)
        Timecop.travel(Time.zone.now + 1.second)
        rejudged.judge!(nil, nil)

        expect(described_class.unjudged).to eq [rejudged]
      end

      it 'does not return currently judged predictions with previous unknown judgements' do
        rejudged = FactoryBot.create(:prediction)
        rejudged.judge!(nil, nil)
        Timecop.travel(Time.zone.now + 1.second)
        rejudged.judge!(:right, nil)

        expect(described_class.unjudged).to eq []
      end
    end

    describe 'for future predictions' do
      it 'does not return judged predictions' do
        judged = FactoryBot.create(:prediction, deadline: 2.days.from_now)
        judged.judge!(:right, nil)
        unjudged = FactoryBot.create(:prediction, deadline: 2.days.from_now)

        expect(described_class.future).to eq [unjudged]
      end

      it 'does not return predictions whose deadline is in the past' do
        future = FactoryBot.create(:prediction, deadline: 2.years.from_now)
        FactoryBot.create(:prediction, deadline: 2.days.ago)

        expect(described_class.future).to eq [future]
      end

      it 'orders by ascending deadline' do
        further = FactoryBot.create(:prediction, deadline: 2.weeks.from_now)
        sooner = FactoryBot.create(:prediction, deadline: 2.days.from_now)

        expect(described_class.future).to eq [sooner, further]
      end
    end
  end

  describe 'notify creator' do
    describe 'default' do
      describe 'when has creator' do
        let(:user) { User.new }
        let(:prediction) { described_class.new(creator: user) }

        it 'is true if user has email' do
          allow(user).to receive(:notify_on_overdue?).and_return true
          expect(prediction.notify_creator).to be true
        end

        it 'is false if creator does not have email' do
          allow(user).to receive(:notify_on_overdue?).and_return false
          expect(prediction.notify_creator).to be false
        end
      end

      describe 'when has creator and notify creator' do
        describe 'is false' do
          before do
            @user = User.new
            @prediction = described_class.new(creator: @user, notify_creator: false)
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
            @prediction = described_class.new(creator: @user, notify_creator: true)
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
      expect(described_class.new(notify_creator: true).notify_creator).to be true
      expect(described_class.new(notify_creator: false).notify_creator).to be false
    end

    it 'accepts checkbox form values' do
      expect(described_class.new(notify_creator: '1').notify_creator).to be true
      expect(described_class.new(notify_creator: '0').notify_creator).to be false
    end
  end

  describe 'initial deadline notification' do
    it 'exists when notify creator is true' do
      prediction = described_class.new(notify_creator: true)
      prediction.valid?
      expect(prediction.deadline_notifications).not_to be_empty
    end

    it 'does not exist when notify creator is false' do
      expect(described_class.new(notify_creator: false).deadline_notifications).to be_empty
    end
  end

  describe 'deadline' do
    it 'has a deadline attribute that is initially nil' do
      expect(described_class.new.deadline).to be_nil
    end

    it 'is a date field' do
      date = 5.weeks.from_now
      prediction = described_class.new(deadline: date)
      expect(prediction.deadline.to_s(:db)).to eq date.to_s(:db)
    end

    it 'transforms natural language date "tomorrow" to date' do
      prediction = described_class.new
      prediction.deadline_text = 'tomorrow'
      expect(prediction.deadline.to_s(:db)).to eq 1.day.from_now.noon.to_s(:db)
    end

    it 'has an error on deadline_text if invalid' do
      prediction = described_class.new
      prediction.save
      expect(prediction.errors.attribute_names).to include(:deadline_text)
    end

    describe 'prettied' do
      it 'looks nice' do
        prediction = described_class.new
        prediction.deadline_text = 'Fri Aug 15 13:17:07 +1000 2008'
        expect(prediction.prettied_deadline).to eq 'August 15, 2008 03:17'
      end
    end
  end

  describe 'due for judgement?' do
    it 'is true when outcome unknown and past deadline' do
      prediction = described_class.new(deadline: 10.minutes.ago)
      expect(prediction).to receive(:outcome).and_return(nil)
      expect(prediction).to be_due_for_judgement
    end

    it 'is false when outcome known and past deadline' do
      prediction = described_class.new(deadline: 10.minutes.ago)
      expect(prediction).to receive(:outcome).and_return(true)
      expect(prediction).not_to be_due_for_judgement
    end

    it 'is false when outcome unknown and not past deadline' do
      prediction = described_class.new(deadline: 10.minutes.from_now)
      expect(prediction).not_to be_due_for_judgement
    end

    it 'is false when outcome known and not past deadline' do
      prediction = described_class.new(deadline: 10.minutes.from_now)
      expect(prediction).not_to be_due_for_judgement
    end

    it 'is false when withdrawn' do
      prediction = described_class.new(deadline: 10.minutes.ago)
      expect(prediction).to receive(:withdrawn?).and_return(true)
      expect(prediction).not_to be_due_for_judgement
    end
  end

  describe 'outcome' do
    it 'has an outcome attribute that is initially nil' do
      expect(described_class.new.outcome).to be_nil
    end

    describe 'with versioning' do
      it 'has a list of judgements' do
        expect(described_class.new.judgements).to eq []
      end

      describe 'delegate' do
        it 'delegates outcome to judgement' do
          prediction = described_class.new
          allow(prediction).to receive(:judgement).and_return(mock_model(Judgement, outcome: true))
          expect(prediction.outcome).to eq true
        end
        it 'returns nil if unjudged' do
          expect(described_class.new.outcome).to be_nil
        end
      end

      describe '#judge' do
        before do
          @prediction = FactoryBot.create(:prediction)
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
      before do
        @prediction = FactoryBot.create(:prediction)
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
      before do
        @prediction = described_class.new
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
        prediction = described_class.new
        judgement = mock_model(Judgement)
        allow(prediction).to receive(:judgement).and_return(judgement)
        expect(judgement).to receive(:outcome_in_words)
        prediction.readable_outcome
      end
      it 'returns nil if no judgement' do
        expect(described_class.new.readable_outcome).to be_nil
      end
      it 'returns withdrawn if so' do
        p = described_class.new
        expect(p).to receive(:withdrawn?).and_return(true)
        expect(p.readable_outcome).to eq 'withdrawn'
      end
    end
  end

  describe 'confidence aggregation' do
    it 'calculates correctly' do
      prediction = FactoryBot.create(:prediction)
      prediction.responses.first.update(confidence: 50)
      FactoryBot.create(:response, prediction: prediction, confidence: 56)
      FactoryBot.create(:response, prediction: prediction, confidence: 83)
      expect(prediction.mean_confidence).to eq 63
    end
  end

  describe 'events collection' do
    before do
      @prediction = described_class.new
      @r1 = instance_double(Response, created_at: 10.days.ago)
      @v1 = instance_double(described_class, created_at: 10.days.ago)
      @j1 = instance_double(Judgement, created_at: 6.days.ago)
      @v2 = instance_double(described_class, created_at: 5.days.ago)
      @j2 = instance_double(Judgement, created_at: 4.days.ago)
      @v3 = instance_double(described_class, created_at: 3.days.ago)
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
