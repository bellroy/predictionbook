require 'spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  let(:user) {
    post :create, :user => {
      :login => 'quire',
      :email => 'quire@example.com',
      :password => 'quire69',
      :password_confirmation => 'quire69'
    }.merge(@options)
    assigns[:user]
  }
  let(:errors) { user.valid?; user.errors }

  it 'allows signup' do
    @options = {}
    expect { user; response.should be_redirect }.to change(User, :count).by(1)
  end

  it 'requires login on signup' do
    @options = { login: nil }
    expect do
      errors[:login].should_not be_nil
      response.should be_success
    end.not_to change(User, :count)
  end

  it 'requires password on signup' do
    @options = { password: nil }
    expect do
      errors[:password].should_not be_nil
      response.should be_success
    end.not_to change(User, :count)
  end

  it 'requires password confirmation on signup' do
    @options = { password_confirmation: nil }
    expect do
      errors[:password_confirmation].should_not be_nil
      response.should be_success
    end.not_to change(User, :count)
  end

  describe 'email on signup' do
    it 'should allow nil' do
      @options = { email: nil }
      expect do
        errors[:email].should be_empty
        response.should be_redirect
      end.to change(User, :count)
    end

    it 'should allow empty string' do
      @options = { email: '' }
      expect do
        errors[:email].should be_empty
        response.should be_redirect
      end.to change(User, :count)
    end
  end

  describe 'name on signup' do
    it 'should allow nil' do
      @options = { name: nil }
      expect do
        errors[:name].should be_empty
        response.should be_redirect
      end.to change(User, :count)
    end

    it 'should allow empty string' do
      @options = { name: "" }
      expect do
        errors[:name].should be_empty
        response.should be_redirect
      end.to change(User, :count)
    end
  end
end
