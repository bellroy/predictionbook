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
      user.save(:validate => false)
      prediction = Prediction.new
      prediction.save(:validate=> false)
      Notification.create!(:user => user, :prediction => prediction)
      lambda { Notification.create!(:user => user, :prediction => prediction)
      }.should raise_error(ActiveRecord::RecordInvalid, /already been taken/)
    end
  end

  describe 'unique identifier' do
    before(:each) do
      @dn = Notification.new
      @dn.stub(:valid?).and_return(true)
    end
    it 'should be a uuid' do
      @dn.uuid.should_not be_blank
    end
    it 'should persist over saves' do
      @dn.save
      Notification.find(@dn.id).uuid.should == @dn.uuid
    end
  end

  describe 'use_token!' do
    before(:each) do
      @dn = Notification.new
    end
    it 'should lookup by uuid' do
      Notification.should_receive(:find_by_uuid).with('token')
      Notification.use_token!('token')
    end
    it 'should yield if token unused' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      (b = double('block test')).should_receive(:called!)
      Notification.use_token!(:token) { |dn| b.called! }
    end
    it 'should yield the deadline notification' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      Notification.use_token!(:token) { |dn| dn.should == @dn }
    end
    it 'should not yield if no token' do
      Notification.should_receive(:find_by_uuid).and_return(nil)
      (b = double('block test')).should_not_receive(:called!)
      Notification.use_token!(:token) { |dn| b.called! }
    end
    it 'should not yield if token already used' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      @dn.stub(:token_used?).and_return(true)
      (b = double('block test')).should_not_receive(:called!)
      Notification.use_token!(:token) { |dn| b.called! }
    end
    it 'should mark the token used if yielded' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      @dn.should_receive(:use_token!)
      Notification.use_token!(:token) { |hai| }
    end
  end

  describe 'token used marker' do
    before(:each) do
      @dn = Notification.new
    end
    it 'should be false by default' do
      @dn.token_used?.should be false
    end
    it 'should be set to true once marked as used' do
      @dn.use_token!
      @dn.token_used?.should be true
    end
    it 'should persist over saves' do
      @dn.use_token!
      @dn.save
      Notification.find(@dn.id).token_used?.should be true
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
      user.save(:validate=> false)
      prediction = Prediction.new
      prediction.save(:validate=> false)
      Notification.create!(:user => user, :prediction => prediction)
      lambda { Notification.create!(:user => user, :prediction => prediction)
      }.should raise_error(ActiveRecord::RecordInvalid, /already been taken/)
    end
  end

  describe 'unique identifier' do
    before(:each) do
      @dn = Notification.new
      @dn.stub(:valid?).and_return(true)
    end
    it 'should be a uuid' do
      @dn.uuid.should_not be_blank
    end
    it 'should persist over saves' do
      @dn.save
      Notification.find(@dn.id).uuid.should == @dn.uuid
    end
  end

  describe 'use_token!' do
    before(:each) do
      @dn = Notification.new
    end
    it 'should lookup by uuid' do
      Notification.should_receive(:find_by_uuid).with('token')
      Notification.use_token!('token')
    end
    it 'should yield if token unused' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      (b = double('block test')).should_receive(:called!)
      Notification.use_token!(:token) { |dn| b.called! }
    end
    it 'should yield the deadline notification' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      Notification.use_token!(:token) { |dn| dn.should == @dn }
    end
    it 'should not yield if no token' do
      Notification.should_receive(:find_by_uuid).and_return(nil)
      (b = double('block test')).should_not_receive(:called!)
      Notification.use_token!(:token) { |dn| b.called! }
    end
    it 'should not yield if token already used' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      @dn.stub(:token_used?).and_return(true)
      (b = double('block test')).should_not_receive(:called!)
      Notification.use_token!(:token) { |dn| b.called! }
    end
    it 'should mark the token used if yielded' do
      Notification.should_receive(:find_by_uuid).and_return(@dn)
      @dn.should_receive(:use_token!)
      Notification.use_token!(:token) { |hai| }
    end
  end

  describe 'token used marker' do
    before(:each) do
      @dn = Notification.new
    end
    it 'should be false by default' do
      @dn.token_used?.should be false
    end
    it 'should be set to true once marked as used' do
      @dn.use_token!
      @dn.token_used?.should be true
    end
    it 'should persist over saves' do
      @dn.use_token!
      @dn.save
      Notification.find(@dn.id).token_used?.should be true
    end
  end

end
