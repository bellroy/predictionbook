require 'spec_helper'

describe 'routing to responses' do
  it 'should route responses/preview to preview action' do
    {:get => '/responses/preview'}.should route_to(:controller=> 'responses', :action=> 'preview')
  end
end
