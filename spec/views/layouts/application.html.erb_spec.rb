require 'spec_helper'

describe 'layouts/application.html.erb' do
  describe 'when user not logged in' do
    before(:each) do
      allow(view).to receive(:current_user).and_return nil
    end

    it 'does not show username' do
      expect(view).not_to receive(:show_user)
      render
    end

    it 'does not show logout link' do
      render
      expect(rendered).not_to have_link('Logout', href: destroy_user_session_path)
    end
  end

  describe 'for a logged in user' do
    before(:each) do
      allow(view).to receive(:current_user).and_return FactoryGirl.build(:user)
    end

    it 'should show link to username' do
      expect(view).to receive(:show_user)
      render
    end

    it 'should show link to settings page' do
      render
      expect(rendered).to have_link('Settings', href: users_settings_path)
    end

    it 'should show logout link' do
      render
      expect(rendered).to have_link('Logout', href: destroy_user_session_path)
    end
  end
end
