require 'spec_helper'

RSpec.describe Group, type: :model do
  let(:group) { FactoryGirl.build(:group, name: 'something', email_domains: email_domains) }

  describe 'validations' do
    subject { group.valid? }

    context 'nil email_domains' do
      let(:email_domains) { nil }

      it { is_expected.to be true }
    end

    context 'invalid email_domains' do
      let(:email_domains) { 'some string' }

      it { is_expected.to be false }
    end

    context 'single email_domain' do
      let(:email_domains) { 'trikeapps.com' }

      it { is_expected.to be true }
    end

    context 'multiple email_domains' do
      let(:email_domains) { 'trikeapps.com,some.other.com' }

      it { is_expected.to be true }
    end
  end

  describe 'user_is_a_member?' do
    subject(:user_is_a_member?) { group.user_is_a_member?(user) }

    let(:user) { FactoryGirl.build(:user, email: 'big.billy.bob@trikeapps.com') }
    let(:email_domains) { 'trikeapps.com,some.other.com' }

    context 'no email domains' do
      let(:email_domains) { nil }

      it { is_expected.to be false }
    end

    context 'mismatching email domains' do
      let(:email_domains) { 'gmail.com,yahoo.com' }

      it { is_expected.to be false }
    end

    context 'matching email domains' do
      let(:email_domains) { 'trikeapps.com,some.other.com' }

      it { is_expected.to be true }
    end

    context 'matching email domains at end of list' do
      let(:email_domains) { 'some.other.com,trikeapps.com' }

      it { is_expected.to be true }
    end
  end
end
