require 'spec_helper'

describe 'routing to responses' do
  it 'should route responses/preview to preview action' do
    expect(get: '/responses/preview').to route_to(controller: 'responses', action: 'preview')
  end
end
