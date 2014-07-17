require 'spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe SessionsController do
  before do
    @user  = mock_user
    @login_params = { :login => 'quentin', :password => 'test' }
    User.stub(:authenticate).with(@login_params[:login], @login_params[:password]).and_return(@user)
  end
  def do_create
    post :create, :user => @login_params
  end
  describe "on successful login," do
    [ [:nil,       nil,            nil],
      [:expired,   'valid_token',  15.minutes.ago],
      [:different, 'i_haxxor_joo', 15.minutes.from_now],
      [:valid,     'valid_token',  15.minutes.from_now]
        ].each do |has_request_token, token_value, token_expiry|
      [ true, false ].each do |want_remember_me|
        describe "my request cookie token is #{has_request_token.to_s}," do
          describe "and ask #{want_remember_me ? 'to' : 'not to'} be remembered" do
            before do
              @ccookies = double('cookies')
              controller.stub(:cookies).and_return(@ccookies)
              @ccookies.stub(:[]).with(:auth_token).and_return(token_value)
              @ccookies.stub(:delete).with(:auth_token)
              @ccookies.stub(:[]=)
              @user.stub(:remember_me)
              @user.stub(:refresh_token)
              @user.stub(:forget_me)
              @user.stub(:remember_token).and_return(token_value)
              @user.stub(:remember_token_expires_at).and_return(token_expiry)
              @user.stub(:remember_token?).and_return(has_request_token == :valid)
              if want_remember_me
                @login_params[:remember_me] = '1'
              else
                @login_params[:remember_me] = '0'
              end
            end
            it "kills existing login"        do controller.should_receive(:logout_keeping_session!); do_create; end
            it "authorizes me"               do do_create; controller.send(:authorized?).should be true;   end
            it "logs me in"                  do do_create; controller.send(:logged_in?).should  be true  end
            it "greets me nicely"            do do_create; flash[:notice].should =~ /success/i   end
            it "sets/resets/expires cookie"  do controller.should_receive(:handle_remember_cookie!).with(want_remember_me); do_create end
            it "sends a cookie"              do controller.should_receive(:send_remember_cookie!);  do_create end
            it 'redirects to the home page'  do do_create; response.should redirect_to('/')   end
            it "does not reset my session"   do controller.should_not_receive(:reset_session); do_create end # change if you uncomment the reset_session path
            if (has_request_token == :valid)
              it 'does not make new token'   do @user.should_not_receive(:remember_me);   do_create end
              it 'does refresh token'        do @user.should_receive(:refresh_token);     do_create end
              it "sets an auth cookie"       do do_create;  end
            else
              if want_remember_me
                it 'makes a new token'       do @user.should_receive(:remember_me);       do_create end
                it "does not refresh token"  do @user.should_not_receive(:refresh_token); do_create end
                it "sets an auth cookie"       do do_create;  end
              else
                it 'does not make new token' do @user.should_not_receive(:remember_me);   do_create end
                it 'does not refresh token'  do @user.should_not_receive(:refresh_token); do_create end
                it 'kills user token'        do @user.should_receive(:forget_me);         do_create end
              end
            end
          end # inner describe
        end
      end
    end
  end

  describe "on failed login" do
    before do
      User.should_receive(:authenticate).with(anything(), anything()).and_return(nil)
      login_as :quentin
    end
    it 'logs out keeping session'   do controller.should_receive(:logout_keeping_session!); do_create end
    it 'flashes an error'           do do_create; flash[:error].should =~ /Couldn't log you in as 'quentin'/ end
    it 'renders the log in page'    do do_create; response.should render_template('new')  end
    it "doesn't log me in"          do do_create; controller.send(:logged_in?).should == false end
    it "doesn't send password back" do
      @login_params[:password] = 'FROBNOZZ'
      do_create
      response.should_not have_content(/FROBNOZZ/i)
    end
  end

  describe "on signout" do
    def do_destroy
      get :destroy
    end
    before do
      login_as :quentin
    end
    it 'logs me out'                   do controller.should_receive(:logout_killing_session!); do_destroy end
    it 'redirects me to the home page' do do_destroy; response.should be_redirect     end
  end

end

describe SessionsController do

  describe 'remebering destination' do
    describe 'on login' do
      it 'should store the referer when rendering login page if no destination is already stored' do
        controller.should_receive :store_referer_if_no_destination
        get :new
      end
    end
    describe 'on logout' do
      it 'should store the referer when rendering login page' do
        controller.should_receive :store_referer_if_no_destination
        delete :destroy
      end
      it 'should not store the destination if the page requires a login' do
        controller.stub(:referer_requires_login?).and_return(true)
        controller.should_not_receive :store_referer_if_no_destination
        delete :destroy
      end
    end
  end

end
