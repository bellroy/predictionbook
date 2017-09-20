# frozen_string_literal: true

require 'spec_helper'

describe ContentController do
  describe '#healthcheck' do
    subject(:healthcheck) { get :healthcheck }

    specify { expect(response).to be_ok }
  end
end
