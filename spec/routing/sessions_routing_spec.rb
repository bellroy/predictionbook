require 'spec_helper'

describe "routing to session" do
  it "should generate params from GET /login correctly" do
    {:get, '/login'}.should route_to(:controller => 'sessions', :action => 'new')
  end
  it "should generate params from POST /session correctly" do
    {:post, '/session'}.should route_to(:controller => 'sessions', :action => 'create')
  end
  it "should generate params from DELETE /session correctly" do
    {:delete, '/logout'}.should route_to(:controller => 'sessions', :action => 'destroy')
  end

  it "should route session_path() correctly" do
    session_path.should == "/session"
  end
  it "should route new_session_path() correctly" do
    new_session_path.should == "/session/new"
  end
end
