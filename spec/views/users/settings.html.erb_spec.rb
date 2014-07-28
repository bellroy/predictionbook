require 'spec_helper'

describe 'users/settings' do
  describe 'private_default checkbox' do
    before do
      assigns[:user] = @user = valid_user
      view.stub(:current_user).and_return(@user)
    end
    it 'should exist' do
      render
      rendered.should have_field('user[private_default]')
    end
    it 'should be checked if the user wishes it' do
      @user.stub(:private_default).and_return(true)
      render
      rendered.should have_checked_field('user[private_default]')
    end
    it 'should not be checked if the user does not wish it' do
      @user.stub(:private_default).and_return(false)
      render
      rendered.should have_unchecked_field('user[private_default]')
    end
  end
end
