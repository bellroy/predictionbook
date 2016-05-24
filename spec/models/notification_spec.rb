require 'spec_helper'

describe Notification do
  describe 'validations' do
    before(:each) do
      @dn = Notification.new
      @dn.valid?
    end

    it 'must have a prediction' do
      @dn.valid?
      expect(@dn.errors[:prediction].length).to eq 1
    end

    it 'must have a user' do
      @dn.valid?
      expect(@dn.errors[:user].length).to eq 1
    end

    it 'must be unique per user and prediction' do
      user = User.new
      user.save(validate: false)
      prediction = Prediction.new
      prediction.save(validate: false)
      Notification.create!(user: user, prediction: prediction)
      expect { Notification.create!(user: user, prediction: prediction) }
        .to raise_error(ActiveRecord::RecordInvalid, /already been taken/)
    end
  end

  describe 'unique identifier' do
    before(:each) do
      @dn = Notification.new
      allow(@dn).to receive(:valid?).and_return(true)
    end

    it 'is a uuid' do
      expect(@dn.uuid).not_to be_blank
    end

    it 'persists over saves' do
      @dn.save
      expect(Notification.find(@dn.id).uuid).to eq @dn.uuid
    end
  end

  describe 'use_token!' do
    before(:each) do
      @dn = Notification.new
    end

    it 'looks up by uuid' do
      expect(Notification).to receive(:find_by_uuid).with('token')
      Notification.use_token!('token')
    end

    it 'yields if token unused' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      expect((b = double('block test'))).to receive(:called!)
      Notification.use_token!(:token) { |_dn| b.called! }
    end

    it 'yields the deadline notification' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      Notification.use_token!(:token) { |dn| expect(dn).to eq @dn }
    end

    it 'does not yield if no token' do
      expect(Notification).to receive(:find_by_uuid).and_return(nil)
      expect((b = double('block test'))).not_to receive(:called!)
      Notification.use_token!(:token) { |_dn| b.called! }
    end

    it 'does not yield if token already used' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      expect(@dn).to receive(:token_used?).and_return(true)
      expect((b = double('block test'))).not_to receive(:called!)
      Notification.use_token!(:token) { |_dn| b.called! }
    end

    it 'marks the token used if yielded' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      expect(@dn).to receive(:use_token!)
      Notification.use_token!(:token) { |_hai| }
    end
  end

  describe 'token used marker' do
    before(:each) do
      @dn = Notification.new
    end

    it 'is false by default' do
      expect(@dn.token_used?).to be false
    end

    it 'is set to true once marked as used' do
      @dn.use_token!
      expect(@dn.token_used?).to be true
    end

    it 'persists over saves' do
      @dn.use_token!
      @dn.save
      expect(Notification.find(@dn.id).token_used?).to be true
    end
  end

  describe 'validations' do
    before(:each) do
      @dn = Notification.new
      @dn.valid?
    end

    it 'must have a prediction' do
      @dn.valid?
      expect(@dn.errors[:prediction].length).to eq 1
    end

    it 'must have a user' do
      @dn.valid?
      expect(@dn.errors[:user].length).to eq 1
    end

    it 'must be unique per user and prediction' do
      user = User.new
      user.save(validate: false)
      prediction = Prediction.new
      prediction.save(validate: false)
      Notification.create!(user: user, prediction: prediction)
      expect { Notification.create!(user: user, prediction: prediction) }
        .to raise_error(ActiveRecord::RecordInvalid, /already been taken/)
    end
  end

  describe 'unique identifier' do
    before(:each) do
      @dn = Notification.new
      allow(@dn).to receive(:valid?).and_return(true)
    end

    it 'is a uuid' do
      expect(@dn.uuid).not_to be_blank
    end

    it 'persists over saves' do
      @dn.save
      expect(Notification.find(@dn.id).uuid).to eq @dn.uuid
    end
  end

  describe 'use_token!' do
    before(:each) do
      @dn = Notification.new
    end

    it 'looks up by uuid' do
      expect(Notification).to receive(:find_by_uuid).with('token')
      Notification.use_token!('token')
    end

    it 'yields if token unused' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      expect((b = double('block test'))).to receive(:called!)
      Notification.use_token!(:token) { |_dn| b.called! }
    end

    it 'yields the deadline notification' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      Notification.use_token!(:token) { |dn| expect(dn).to eq @dn }
    end

    it 'does not yield if no token' do
      expect(Notification).to receive(:find_by_uuid).and_return(nil)
      expect((b = double('block test'))).not_to receive(:called!)
      Notification.use_token!(:token) { |_dn| b.called! }
    end

    it 'does not yield if token already used' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      expect(@dn).to receive(:token_used?).and_return(true)
      expect((b = double('block test'))).not_to receive(:called!)
      Notification.use_token!(:token) { |_dn| b.called! }
    end

    it 'marks the token used if yielded' do
      expect(Notification).to receive(:find_by_uuid).and_return(@dn)
      expect(@dn).to receive(:use_token!)
      Notification.use_token!(:token) { |_hai| }
    end
  end

  describe 'token used marker' do
    before(:each) do
      @dn = Notification.new
    end

    it 'is false by default' do
      expect(@dn.token_used?).to be false
    end

    it 'is set to true once marked as used' do
      @dn.use_token!
      expect(@dn.token_used?).to be true
    end

    it 'persists over saves' do
      @dn.use_token!
      @dn.save
      expect(Notification.find(@dn.id).token_used?).to be true
    end
  end
end
