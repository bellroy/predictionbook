require 'spec_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    subject { group.valid? }

    let(:group) { FactoryGirl.build(:group, name: 'something', email_domains: email_domains) }

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
end
