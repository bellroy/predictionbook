require File.dirname(__FILE__) + '/../spec_helper'
  # Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

#
# A test controller with and without access controls
#
class AccessControlTestController < ApplicationController
  before_filter :login_required, :only => :login_is_required
  def login_is_required
    respond_to do |format|
      @foo = { 'success' => params[:format]||'no fmt given'}
      format.html do render :text => "success"             end
      format.xml  do render :xml  => @foo, :status => :ok  end
      format.json do render :json => @foo, :status => :ok  end
    end
  end
  def login_not_required
    respond_to do |format|
      @foo = { 'success' => params[:format]||'no fmt given'}
      format.html do render :text => "success"             end
      format.xml  do render :xml  => @foo, :status => :ok  end
      format.json do render :json => @foo, :status => :ok  end
    end
  end
end

#
# Access Control
#

ACCESS_CONTROL_FORMATS = [
  ['html',     "success"],
  ['xml',  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <success>xml</success>\n</hash>\n"],
  ['json', "{\"success\":\"json\"}"],]
ACCESS_CONTROL_AM_I_LOGGED_IN = [
  [:i_am_logged_in,     :quentin],
  [:i_am_not_logged_in, nil],]
ACCESS_CONTROL_IS_LOGIN_REQD = [
  :login_not_required,
  :login_is_required,]

describe AccessControlTestController do
  fixtures        :users
  before do
    # is there a better way to do this?
    begin
      _routes = Rails.application.class.routes
      _routes.disable_clear_and_finalize = true
      _routes.clear!
      Rails.application.class.routes_reloader.paths.each{ |path| load(path) }
      _routes.draw do
        match 'login_is_required'  => 'access_control_test#login_is_required'
        match 'login_not_required' => 'access_control_test#login_not_required'
    end  
      ActiveSupport.on_load(:action_controller) { _routes.finalize! }
    ensure
      _routes.disable_clear_and_finalize = false
    end
  end

  ACCESS_CONTROL_FORMATS.each do |format, success_text|
    ACCESS_CONTROL_AM_I_LOGGED_IN.each do |logged_in_status, user_login|
      ACCESS_CONTROL_IS_LOGIN_REQD.each do |login_reqd_status|
        describe "requesting #{format.blank? ? 'html' : format}; #{logged_in_status.to_s.humanize} and #{login_reqd_status.to_s.humanize}" do
          before do
            controller.send(:logout_keeping_session!)
            @user = format.blank? ? login_as(user_login) : authorize_as(user_login)
            get login_reqd_status.to_s, :format => format
          end

          if ((login_reqd_status == :login_not_required) ||
              (login_reqd_status == :login_is_required && logged_in_status == :i_am_logged_in))
            it "succeeds" do 
              response.body.should == success_text
              response.code.to_s.should == '200'
            end

          elsif (login_reqd_status == :login_is_required && logged_in_status == :i_am_not_logged_in)
            if ['html', ''].include? format
              it "redirects me to the log in page" do
                response.should redirect_to('/session/new')
              end
            else
              it "returns 'Access denied' and a 406 (Access Denied) status code" do
                response.should contain("HTTP Basic: Access denied.")
                response.code.to_s.should == '401'
              end
            end

          else
            warn "Oops no case for #{format} and #{logged_in_status.to_s.humanize} and #{login_reqd_status.to_s.humanize}"
          end
        end # describe

      end
    end
  end # cases

end
