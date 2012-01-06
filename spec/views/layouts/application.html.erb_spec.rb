require 'spec_helper'

describe 'Application Layout' do
  def render_me!
    render 'layouts/application.html.erb'
  end
  
  describe 'when user not logged in' do
    before(:each) do
      template.stub!(:logged_in?).and_return(false)
    end
    
    it 'should not show username' do
      template.should_not_receive(:show_user)
      render_me!
    end
    
    it 'should not show logout link' do
      render_me!
      response.should_not have_tag(%Q{a[href="#{logout_path}"]})
    end
  end
  
  describe 'for a logged in user' do
    before(:each) do
      template.stub!(:logged_in?).and_return(true)
    end
    
    it 'should show link to username' do
      template.should_receive(:show_user)
      render_me!
    end
    
    it 'should show link to settings page' do
      template.should_receive(:settings_user_path).and_return ''
      render_me!
    end
    
    it 'should show logout link' do
      render_me!
      response.should have_tag(%Q{a[href="#{logout_path}"]})
    end
  end
end
