require 'spec_helper'

describe "routing to session" do
  it "should route session_path() correctly" do
    session_path.should == "/session"
  end
  it "should route new_session_path() correctly" do
    new_session_path.should == "/session/new"
  end
end
