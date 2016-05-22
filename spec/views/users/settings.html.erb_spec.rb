require 'spec_helper'

describe 'users/settings' do
  describe 'private_default checkbox' do
    before do
      assigns[:user] = @user = FactoryGirl.create(:user)
      view.stub(:current_user).and_return(@user)
      @user.stub(:api_token).and_return('token')
      @user.stub(:id).and_return(1)
    end
    it 'should exist' do
      render
      rendered.should have_field('user[private_default]')
    end
    it 'is checked if the user wishes it' do
      @user.stub(:private_default).and_return(true)
      render
      rendered.should have_checked_field('user[private_default]')
    end
    it 'should not be checked if the user does not wish it' do
      @user.stub(:private_default).and_return(false)
      render
      rendered.should have_unchecked_field('user[private_default]')
    end
    it 'should display API token' do
      @user.stub(:private_default).and_return(false)
      render
      rendered.should have_content('token')
    end
  end
end
