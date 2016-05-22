require 'spec_helper'

describe 'users/settings' do
  describe 'private_default checkbox' do
    before do
      assigns[:user] = @user = FactoryGirl.create(:user)
      allow(view).to receive(:current_user).and_return(@user)
      allow(@user).to receive(:api_token).and_return('token')
      allow(@user).to receive(:id).and_return(1)
    end
    
    it 'exists' do
      render
      expect(rendered).to have_field('user[private_default]')
    end

    it 'is checked if the user wishes it' do
      allow(@user).to receive(:private_default).and_return(true)
      render
      expect(rendered).to have_checked_field('user[private_default]')
    end

    it 'is not checked if the user does not wish it' do
      allow(@user).to receive(:private_default).and_return(false)
      render
      expect(rendered).to have_unchecked_field('user[private_default]')
    end

    it 'displays API token' do
      allow(@user).to receive(:private_default).and_return(false)
      render
      expect(rendered).to have_content('token')
    end
  end
end
