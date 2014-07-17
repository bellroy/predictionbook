require 'spec_helper'

describe 'layouts/application.html.erb' do
  describe 'when user not logged in' do
    before(:each) do
      view.stub(:authenticate_with_http_basic => nil)
      view.stub(:logged_in?).and_return(false)
      view.stub(:current_user).and_return nil
    end

    it 'should not show username' do
      view.should_not_receive(:show_user)
      render
    end

    it 'should not show logout link' do
      render
      rendered.should_not have_link('Logout', :href=>logout_path)
    end
  end

  describe 'for a logged in user' do
    before(:each) do
      view.stub(:logged_in?).and_return(true)
      view.stub(:current_user).and_return valid_user
    end

    it 'should show link to username' do
      view.should_receive(:show_user)
      render
    end

    it 'should show link to settings page' do
      view.should_receive(:settings_user_path).and_return ''
      render
    end

    it 'should show logout link' do
      render
      rendered.should have_link('Logout', :href=>logout_path)
    end
  end
end
