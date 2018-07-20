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
    let(:user) { FactoryBot.build(:user) }
    before(:each) do
      allow(view).to receive(:current_user).and_return user
    end

    it 'should show link to username' do
      render
      expect(rendered).to have_link('Your profile', href: user_path(user))
    end

    it 'should show link to settings page' do
      render
      expect(rendered).to have_link('Settings', href: settings_user_path(user))
    end

    it 'should show logout link' do
      render
      expect(rendered).to have_link('Logout', href: destroy_user_session_path)
    end
  end
end
