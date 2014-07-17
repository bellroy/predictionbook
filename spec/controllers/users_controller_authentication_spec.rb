require 'spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      user = assigns[:user]
      user.valid?
      user.errors[:login].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      user = assigns[:user]
      user.valid?
      user.errors[:password].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      user = assigns[:user]
      user.valid?
      user.errors[:password_confirmation].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  describe 'email on signup' do
    it 'should allow nil' do
      lambda do
        create_user(:email => nil)
        user = assigns[:user]
        user.valid?
        user.errors[:email].should be_empty
        response.should be_redirect
      end.should change(User, :count)
    end
    it 'should allow empty string' do
      lambda do
        create_user(:email => '')
        user = assigns[:user]
        user.valid?
        user.errors[:email].should be_empty
        response.should be_redirect
      end.should change(User, :count)
    end
  end

  describe 'name on signup' do
    it 'should allow nil' do
      lambda do
        create_user(:name => nil)
        user = assigns[:user]
        user.valid?
        user.errors[:name].should be_empty
        response.should be_redirect
      end.should change(User, :count)
    end
    it 'should allow empty string' do
      lambda do
        create_user(:name => '')
        user = assigns[:user]
        user.valid?
        user.errors[:name].should be_empty
        response.should be_redirect
      end.should change(User, :count)
    end
  end

  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end
