require 'spec_helper'

describe "routing to users" do

  describe "route recognition" do
    it "should generate params for users's index action from GET /users" do
      {:get=> '/users'}.should route_to(:controller => 'users', :action => 'index')
      {:get=> '/users.xml'}.should route_to(:controller => 'users', :action => 'index', :format => 'xml')
      {:get=> '/users.json'}.should route_to(:controller => 'users', :action => 'index', :format => 'json')
    end

    it "should generate params for users's new action from GET /users" do
      {:get=> '/users/new'}.should route_to(:controller => 'users', :action => 'new')
      {:get=> '/users/new.xml'}.should route_to(:controller => 'users', :action => 'new', :format => 'xml')
      {:get=> '/users/new.json'}.should route_to(:controller => 'users', :action => 'new', :format => 'json')
    end

    it "should generate params for users's create action from POST /users" do
      {:post=> '/users'}.should route_to(:controller => 'users', :action => 'create')
      {:post=> '/users.xml'}.should route_to(:controller => 'users', :action => 'create', :format => 'xml')
      {:post=> '/users.json'}.should route_to(:controller => 'users', :action => 'create', :format => 'json')
    end

    it "should generate params for users's show action from GET /users/1" do
      {:get=> '/users/1'}.should route_to(:controller => 'users', :action => 'show', :id => '1')
      {:get=> '/users/1.xml'}.should route_to(:controller => 'users', :action => 'show', :id => '1', :format => 'xml')
      {:get=> '/users/1.json'}.should route_to(:controller => 'users', :action => 'show', :id => '1', :format => 'json')
    end

    it "should generate params for users's edit action from GET /users/1/edit" do
      {:get=> '/users/1/edit'}.should route_to(:controller => 'users', :action => 'edit', :id => '1')
    end

    it "should generate params {:controller => 'users', :action => update', :id => '1'} from PUT /users/1" do
      {:put=> '/users/1'}.should route_to(:controller => 'users', :action => 'update', :id => '1')
      {:put=> '/users/1.xml'}.should route_to(:controller => 'users', :action => 'update', :id => '1', :format => 'xml')
      {:put=> '/users/1.json'}.should route_to(:controller => 'users', :action => 'update', :id => '1', :format => 'json')
    end

    it "should generate params for users's destroy action from DELETE /users/1" do
      {:delete=> '/users/1'}.should route_to(:controller => 'users', :action => 'destroy', :id => '1')
      {:delete=> '/users/1.xml'}.should route_to(:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml')
      {:delete=> '/users/1.json'}.should route_to(:controller => 'users', :action => 'destroy', :id => '1', :format => 'json')
    end
  end

  describe "named routing" do
    it "should route users_path() to /users" do
      users_path().should == "/users"
      users_path(:format => 'xml').should == "/users.xml"
      users_path(:format => 'json').should == "/users.json"
    end

    it "should route new_user_path() to /users/new" do
      new_user_path().should == "/users/new"
      new_user_path(:format => 'xml').should == "/users/new.xml"
      new_user_path(:format => 'json').should == "/users/new.json"
    end

    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
      user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end

    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
end

