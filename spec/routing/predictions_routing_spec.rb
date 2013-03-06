require 'spec_helper'

describe "routing to predictions" do

  it 'should map GET / to home action' do
    {:get=> '/' }.should route_to(:controller => 'predictions', :action => 'home')
  end

  it 'should map /predictions to "index" action' do
    {:get => '/predictions'}.should route_to(:controller => 'predictions', :action => 'index')
  end

  it 'should map GET to /predictions/new to "new" action' do
    {:get => '/predictions/new'}.should route_to(:controller => 'predictions', :action => 'new')
  end

  it 'should map GET to / to "index" action' do
    {:get => '/'}.should route_to(:controller => 'predictions', :action => 'home')
  end

  it 'should map GET /preditions/:id to show' do
    {:get => '/predictions/1'}.should route_to(:controller => 'predictions', :action => 'show', :id => '1')
  end

  it 'should map POST to /predictions/:id/judge to "judge" action' do
    {:post => '/predictions/1/judge'}.should route_to(:controller => 'predictions', :action => 'judge', :id => '1')
  end

  it 'should map POST to /predictions/:id/withdraw to update action' do
    {:post => '/predictions/1/withdraw'}.should route_to(:controller => 'predictions', :action => 'withdraw', :id => '1')
  end

  it 'should map GET /preditions/:id to show' do
    {:get => '/predictions/1'}.should route_to(:controller => 'predictions', :action => 'show', :id => '1')
  end

  it 'should map POST to /predictions to "create" action' do
    {:post => '/predictions'}.should route_to(:controller => 'predictions', :action => 'create')
  end

end
