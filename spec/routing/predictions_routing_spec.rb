# frozen_string_literal: true

require 'spec_helper'

describe 'routing to predictions' do
  it 'maps  GET / to home action' do
    expect(get: '/').to route_to(controller: 'predictions', action: 'home')
  end

  it 'maps  /predictions to "index" action' do
    expect(get: '/predictions').to route_to(controller: 'predictions', action: 'index')
  end

  it 'maps  GET to / to "index" action' do
    expect(get: '/').to route_to(controller: 'predictions', action: 'home')
  end

  it 'maps  GET /preditions/:id to show' do
    expect(get: '/predictions/1').to route_to(controller: 'predictions', action: 'show', id: '1')
  end

  it 'maps  GET /preditions/:id to show' do
    expect(get: '/predictions/1').to route_to(controller: 'predictions', action: 'show', id: '1')
  end
end
