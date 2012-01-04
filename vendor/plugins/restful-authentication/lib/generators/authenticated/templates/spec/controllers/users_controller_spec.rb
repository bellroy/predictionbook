require File.dirname(__FILE__) + '/../spec_helper'
  
# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  fixtures :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  


  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.get(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.get(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.get(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.get(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end

describe UsersController do
  describe "route recognition and generation" do
    it "should generate params for users's index action from GET /users" do
      {:get => '/users'}.should route_to(:controller => 'users', :action => 'index')
      {:get => '/users.xml'}.should route_to(:controller => 'users', :action => 'index', :format => 'xml')
      {:get => '/users.json'}.should route_to(:controller => 'users', :action => 'index', :format => 'json')
    end
    
    it "should generate params for users's new action from GET /users" do
      {:get => '/users/new'}.should route_to(:controller => 'users', :action => 'new')
      {:get => '/users/new.xml'}.should route_to(:controller => 'users', :action => 'new', :format => 'xml')
      {:get => '/users/new.json'}.should route_to(:controller => 'users', :action => 'new', :format => 'json')
    end
    
    it "should generate params for users's create action from POST /users" do
      {:post => '/users'}.should route_to(:controller => 'users', :action => 'create')
      {:post => '/users.xml'}.should route_to(:controller => 'users', :action => 'create', :format => 'xml')
      {:post => '/users.json'}.should route_to(:controller => 'users', :action => 'create', :format => 'json')
    end
    
    it "should generate params for users's show action from GET /users/1" do
      {:get => '/users/1'}.should route_to(:controller => 'users', :action => 'show', :id => '1')
      {:get => '/users/1.xml'}.should route_to(:controller => 'users', :action => 'show', :id => '1', :format => 'xml')
      {:get => '/users/1.json'}.should route_to(:controller => 'users', :action => 'show', :id => '1', :format => 'json')
    end
    
    it "should generate params for users's edit action from GET /users/1/edit" do
      {:get => '/users/1/edit'}.should route_to(:controller => 'users', :action => 'edit', :id => '1')
    end
    
    it "should generate params {:controller => 'users', :action => update', :id => '1'} from PUT /users/1" do
      {:put => '/users/1'}.should route_to(:controller => 'users', :action => 'update', :id => '1')
      {:put => '/users/1.xml'}.should route_to(:controller => 'users', :action => 'update', :id => '1', :format => 'xml')
      {:put => '/users/1.json'}.should route_to(:controller => 'users', :action => 'update', :id => '1', :format => 'json')
    end
    
    it "should generate params for users's destroy action from DELETE /users/1" do
      {:delete => '/users/1'}.should route_to(:controller => 'users', :action => 'destroy', :id => '1')
      {:delete => '/users/1.xml'}.should route_to(:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml')
      {:delete => '/users/1.json'}.should route_to(:controller => 'users', :action => 'destroy', :id => '1', :format => 'json')
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route users_path() to /users" do
      users_path().should == "/users"
      controller.users_path(:format => 'xml').should == "/users.xml"
      controller.users_path(:format => 'json').should == "/users.json"
    end
    
    it "should route new_user_path() to /users/new" do
      new_user_path().should == "/users/new"
      controller.new_user_path(:format => 'xml').should == "/users/new.xml"
      controller.new_user_path(:format => 'json').should == "/users/new.json"
    end
    
    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
      controller.user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      controller.user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end
    
    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      controller.edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
  
end
