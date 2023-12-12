# frozen_string_literal: true

require 'spec_helper'

describe 'users/settings' do
  describe 'visibility_default checkbox' do
    before do
      assigns[:user] = @user = FactoryBot.create(:user)
      allow(view).to receive(:current_user).and_return(@user)
      allow(@user).to receive(:api_token).and_return('token')
      allow(@user).to receive(:id).and_return(1)
    end

    it 'displays API token' do
      allow(@user).to receive(:visibility_default).and_return(false)
      render
      expect(rendered).to have_content('token')
    end
  end
end
