require 'spec_helper'

describe 'settings form' do
  describe 'private_default checkbox' do
    before do
      assigns[:user] = @user = valid_user
    end
    it 'should exist' do
      render 'users/settings'
      response.should have_tag('input[name=?]', 'user[private_default]')
    end
    it 'should be checked if the user wishes it' do
      @user.stub!(:private_default).and_return(true)
      render 'users/settings'
      response.should have_tag('input[type="checkbox"][name=?][checked=?]', 'user[private_default]', "checked")
    end
    it 'should not be checked if the user does not wish it' do
      @user.stub!(:private_default).and_return(false)
      render 'users/settings'
      response.should_not have_tag('input[type="checkbox"][name=?][checked=?]', 'user[private_default]', "checked")
    end
  end
end
