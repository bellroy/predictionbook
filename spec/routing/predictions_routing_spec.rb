# frozen_string_literal: true

require 'spec_helper'

describe 'routing to predictions' do
  it 'maps  GET / to home action' do
    expect(get: '/').to route_to(controller: 'predictions', action: 'home')
  end

  it 'maps  /predictions to "index" action' do
    expect(get: '/predictions').to route_to(controller: 'predictions', action: 'index')
  end

  it 'maps  GET to /predictions/new to "new" action' do
    expect(get: '/predictions/new').to route_to(controller: 'predictions', action: 'new')
  end

  it 'maps  GET to / to "index" action' do
    expect(get: '/').to route_to(controller: 'predictions', action: 'home')
  end

  it 'maps  GET /preditions/:id to show' do
    expect(get: '/predictions/1').to route_to(controller: 'predictions', action: 'show', id: '1')
  end

  it 'maps  POST to /predictions/:id/judge to "judge" action' do
    expect(post: '/predictions/1/judge').to route_to(
      controller: 'predictions', action: 'judge', id: '1'
    )
  end

  it 'maps  POST to /predictions/:id/withdraw to update action' do
    expect(post: '/predictions/1/withdraw').to route_to(
      controller: 'predictions', action: 'withdraw', id: '1'
    )
  end

  it 'maps  GET /preditions/:id to show' do
    expect(get: '/predictions/1').to route_to(controller: 'predictions', action: 'show', id: '1')
  end

  it 'maps  POST to /predictions to "create" action' do
    expect(post: '/predictions').to route_to(controller: 'predictions', action: 'create')
  end
end
