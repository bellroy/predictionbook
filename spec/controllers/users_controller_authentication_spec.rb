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
      assigns[:user].errors_on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors_on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors_on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  describe 'email on signup' do
    it 'should allow nil' do
      lambda do
        create_user(:email => nil)
        assigns[:user].errors_on(:email).should be_nil
        response.should be_redirect
      end.should change(User, :count)  
    end
    it 'should allow empty string' do
      lambda do
        create_user(:email => '')
        assigns[:user].errors_on(:email).should be_nil
        response.should be_redirect
      end.should change(User, :count)
    end
  end
  
  describe 'name on signup' do
    it 'should allow nil' do
      lambda do
        create_user(:name => nil)
        assigns[:user].errors_on(:name).should be_nil
        response.should be_redirect
      end.should change(User, :count)  
    end
    it 'should allow empty string' do
      lambda do
        create_user(:name => '')
        assigns[:user].errors_on(:name).should be_nil
        response.should be_redirect
      end.should change(User, :count)
    end
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end
