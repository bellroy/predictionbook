# frozen_string_literal: true

require 'spec_helper'

describe User do
  it 'has a name accessor' do
    expect(described_class.new).to respond_to(:name)
    expect(described_class.new).to respond_to(:name=)
  end

  it 'has a private_default field which defaults to false' do
    expect(described_class.new.visible_to_everyone?).to be true
  end

  it 'has an email with name' do
    u = described_class.new(name: 'Tester', email: 'test@test.com')
    expect(u.email_with_name).to eq '"Tester" <test@test.com>'
  end

  it 'escapes dots in the username with [dot]' do
    expect(described_class.new(login: 'login.name').to_param).to eq 'login[dot]name'
  end

  describe 'with statistics' do
    it 'delegates statistics to wagers' do
      user = described_class.new
      user.id = 123
      stats = double(Statistics)
      expect(Statistics).to receive(:new).with('r.user_id = 123').and_return(stats)
      expect(user.statistics).to eq stats
    end
  end

  describe 'when given empty string' do
    before do
      @user = described_class.new
    end

    it 'stores empty name as nil' do
      @user.name = " \t \n "
      expect(@user.name).to be_nil
    end
    it 'stores email as nil' do
      @user.email = ''
      expect(@user.email).to be_nil
    end
  end

  describe '#pseudonymize!' do
    let!(:pseudonymous_user) { FactoryBot.create(:user, :pseudonymous) }
    let!(:user) { FactoryBot.create(:user) }

    context 'for a user with a judgement' do
      let(:judgement) { FactoryBot.create(:judgement, user: user) }

      it 'results in a judgement that references the pseudonymous user' do
        id = judgement.id
        user.pseudonymize!
        expect(Judgement.find(id).user).to eq(pseudonymous_user)
      end
    end

    context 'for a user with a prediction' do
      let(:prediction) { FactoryBot.create(:prediction, creator: user) }

      it 'results in a prediction that references the pseudonymous user' do
        id = prediction.id
        user.pseudonymize!
        expect(Prediction.find(id).creator).to eq(pseudonymous_user)
      end
    end

    context 'for a user with a prediction version' do
      let(:prediction) { FactoryBot.create(:prediction, creator: user) }
      let(:prediction_version) do
        PredictionVersion.create(
          creator_id: prediction.creator.id,
          prediction: prediction,
          version: prediction.version + 1
        )
      end

      it 'results in a version that references the pseudonymous user' do
        id = prediction_version.id
        user.pseudonymize!
        expect(PredictionVersion.find(id).creator_id)
          .to eq(pseudonymous_user.id)
      end
    end

    context 'for a user with a response' do
      let(:response) { FactoryBot.create(:response, user: user) }

      it 'results in a response that references the pseudonymous user' do
        id = response.id
        user.pseudonymize!
        expect(Response.find(id).user).to eq(pseudonymous_user)
      end
    end
  end

  describe '#to_h' do
    subject { FactoryBot.create(:user) }

    it { expect(subject.to_h.keys).to include(:email, :name, :user_id) }
  end
end
